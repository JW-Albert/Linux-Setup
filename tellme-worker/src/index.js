// TellMe Cloudflare Worker
// OTP Registration + Token Event Notification Gateway

// Helper: JSON response
function json(data, status = 200, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...headers,
    },
  });
}

// Helper: Read JSON from request
async function readJSON(request) {
  try {
    return await request.json();
  } catch (e) {
    return null;
  }
}

// Helper: SHA256 hash
async function sha256(message) {
  const msgBuffer = new TextEncoder().encode(message);
  const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Helper: Generate 6-digit OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Helper: Generate client token
function generateToken() {
  // Generate 4 UUIDs and concatenate for 128+ character token
  const uuid1 = crypto.randomUUID().replace(/-/g, '');
  const uuid2 = crypto.randomUUID().replace(/-/g, '');
  const uuid3 = crypto.randomUUID().replace(/-/g, '');
  const uuid4 = crypto.randomUUID().replace(/-/g, '');
  return `tm_${uuid1}${uuid2}${uuid3}${uuid4}`;
}

// Helper: Generate request ID
function generateRequestId() {
  return crypto.randomUUID();
}

// Helper: Send email via Resend
async function sendOTPEmail(env, otp, hostname, machineId) {
  const maskedMachineId = machineId.length > 8 
    ? `${machineId.substring(0, 4)}...${machineId.substring(machineId.length - 4)}`
    : '***';
  
  const emailBody = {
    from: env.EMAIL_FROM,
    to: env.EMAIL_TO,
    subject: `TellMe Registration OTP - ${hostname}`,
    html: `
      <h2>TellMe Registration OTP</h2>
      <p>You have requested to register a new machine:</p>
      <ul>
        <li><strong>Hostname:</strong> ${hostname}</li>
        <li><strong>Machine ID:</strong> ${maskedMachineId}</li>
      </ul>
      <p><strong>Your OTP code is: <code style="font-size: 24px; font-weight: bold;">${otp}</code></strong></p>
      <p>This code will expire in 10 minutes.</p>
      <p><small>If you did not request this, please ignore this email.</small></p>
    `,
    text: `TellMe Registration OTP\n\nHostname: ${hostname}\nMachine ID: ${maskedMachineId}\n\nYour OTP code is: ${otp}\n\nThis code will expire in 10 minutes.`,
  };

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${env.RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(emailBody),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error('Resend API error:', response.status, errorText);
    throw new Error(`Email send failed: ${response.status}`);
  }

  return await response.json();
}

// Helper: Send Discord webhook
async function sendDiscordWebhook(env, event, hostname, user, time, ip, message) {
  const timestamp = new Date(time * 1000).toISOString();
  const discordMessage = {
    username: 'Tell_Me Bot',
    avatar_url: 'https://raw.githubusercontent.com/JW-Albert/Linux-Setup/refs/heads/main/Tell_Me/config/icon.png',
    content: `🔔 **${event.toUpperCase()} Event**\n\n` +
      `**Hostname:** ${hostname}\n` +
      `**User:** ${user}\n` +
      `**Time:** ${timestamp}\n` +
      `**IP:** ${ip || 'N/A'}\n` +
      (message ? `**Message:** ${message}\n` : ''),
  };

  const response = await fetch(env.DISCORD_WEBHOOK, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(discordMessage),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error('Discord webhook error:', response.status, errorText);
    throw new Error(`Discord webhook failed: ${response.status}`);
  }

  return await response.json();
}

// CORS headers
function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}

// Handle OPTIONS for CORS
function handleOptions() {
  return new Response(null, {
    status: 204,
    headers: corsHeaders(),
  });
}

// POST /register/request
async function handleRegisterRequest(request, env) {
  const body = await readJSON(request);
  if (!body || !body.hostname || !body.user || !body.machine_id) {
    return json({ error: 'Missing required fields: hostname, user, machine_id' }, 400);
  }

  const registrationId = crypto.randomUUID();
  const otp = generateOTP();
  const otpHash = await sha256(otp);
  const expiresAt = Math.floor(Date.now() / 1000) + 600; // 10 minutes

  const regData = {
    otp_hash: otpHash,
    expires_at: expiresAt,
    attempts: 0,
    hostname: body.hostname,
    machine_id: body.machine_id,
  };

  try {
    // Store registration data in KV with 600s TTL
    await env.REG_KV.put(
      `reg:${registrationId}`,
      JSON.stringify(regData),
      { expirationTtl: 600 }
    );

    // Send OTP email
    try {
      await sendOTPEmail(env, otp, body.hostname, body.machine_id);
    } catch (emailError) {
      // If email fails, delete the registration record
      await env.REG_KV.delete(`reg:${registrationId}`);
      console.error('Email send failed:', emailError);
      return json({ error: 'Failed to send OTP email' }, 502);
    }

    return json({
      registration_id: registrationId,
      message: 'OTP sent',
    });
  } catch (error) {
    console.error('Register request error:', error);
    return json({ error: 'Internal server error' }, 500);
  }
}

// POST /register/confirm
async function handleRegisterConfirm(request, env) {
  const body = await readJSON(request);
  if (!body || !body.registration_id || !body.otp) {
    return json({ error: 'Missing required fields: registration_id, otp' }, 400);
  }

  const regKey = `reg:${body.registration_id}`;
  const regDataStr = await env.REG_KV.get(regKey);

  if (!regDataStr) {
    return json({ error: 'Registration not found or expired' }, 400);
  }

  const regData = JSON.parse(regDataStr);
  const now = Math.floor(Date.now() / 1000);

  // Check expiration
  if (regData.expires_at < now) {
    await env.REG_KV.delete(regKey);
    return json({ error: 'Registration expired' }, 400);
  }

  // Check attempts
  if (regData.attempts >= 5) {
    await env.REG_KV.delete(regKey);
    return json({ error: 'Too many failed attempts' }, 403);
  }

  // Verify OTP
  const otpHash = await sha256(body.otp);
  if (otpHash !== regData.otp_hash) {
    regData.attempts += 1;
    await env.REG_KV.put(regKey, JSON.stringify(regData), { expirationTtl: 600 });
    return json({ error: 'Invalid OTP' }, 401);
  }

  // OTP verified, generate token
  const token = generateToken();
  const tokenData = {
    hostname: regData.hostname,
    machine_id: regData.machine_id,
    enabled: true,
    events: ['boot', 'login'],
    created_at: now,
  };

  // Store token in KV (no expiration for tokens)
  await env.TOKEN_KV.put(`token:${token}`, JSON.stringify(tokenData));

  // Delete registration record
  await env.REG_KV.delete(regKey);

  return json({ token });
}

// POST /event
async function handleEvent(request, env) {
  // Check Authorization header
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return json({ error: 'Missing or invalid Authorization header' }, 401);
  }

  const token = authHeader.substring(7);
  const tokenKey = `token:${token}`;
  const tokenDataStr = await env.TOKEN_KV.get(tokenKey);

  if (!tokenDataStr) {
    return json({ error: 'Invalid token' }, 401);
  }

  const tokenData = JSON.parse(tokenDataStr);

  // Check if token is enabled
  if (!tokenData.enabled) {
    return json({ error: 'Token disabled' }, 403);
  }

  // Read and validate request body
  const body = await readJSON(request);
  if (!body) {
    return json({ error: 'Invalid JSON' }, 400);
  }

  // Check payload size (4KB limit)
  const bodySize = new TextEncoder().encode(JSON.stringify(body)).length;
  if (bodySize > 4096) {
    return json({ error: 'Payload too large' }, 413);
  }

  // Validate required fields
  if (!body.event || !body.hostname || !body.user || !body.time) {
    return json({ error: 'Missing required fields: event, hostname, user, time' }, 400);
  }

  // Check event whitelist
  if (!tokenData.events || !tokenData.events.includes(body.event)) {
    return json({ error: 'Event not allowed' }, 403);
  }

  // Send to Discord
  try {
    await sendDiscordWebhook(
      env,
      body.event,
      body.hostname,
      body.user,
      body.time,
      body.ip,
      body.message
    );
  } catch (discordError) {
    console.error('Discord webhook error:', discordError);
    return json({ error: 'Failed to send notification' }, 502);
  }

  return json({ status: 'ok' });
}

// GET /health
function handleHealth() {
  return json({ ok: true });
}

// Main handler
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;
    const requestId = generateRequestId();

    // Add request ID to response headers
    const addRequestId = (response) => {
      const newResponse = response.clone();
      newResponse.headers.set('X-Request-Id', requestId);
      Object.entries(corsHeaders()).forEach(([k, v]) => {
        newResponse.headers.set(k, v);
      });
      return newResponse;
    };

    // Handle CORS preflight
    if (method === 'OPTIONS') {
      return addRequestId(handleOptions());
    }

    // Route handling
    try {
      if (path === '/health' && method === 'GET') {
        return addRequestId(handleHealth());
      }

      if (path === '/register/request' && method === 'POST') {
        return addRequestId(await handleRegisterRequest(request, env));
      }

      if (path === '/register/confirm' && method === 'POST') {
        return addRequestId(await handleRegisterConfirm(request, env));
      }

      if (path === '/event' && method === 'POST') {
        return addRequestId(await handleEvent(request, env));
      }

      return addRequestId(json({ error: 'Not found' }, 404));
    } catch (error) {
      console.error('Handler error:', error);
      return addRequestId(json({ error: 'Internal server error' }, 500));
    }
  },
};

