#!/bin/bash
# This script needs to be executed as root!

curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o agent.sh && chmod +x agent.sh && env NZ_SERVER=107.173.19.61:8008 NZ_TLS=false NZ_CLIENT_SECRET=dgNWh5mZsk6zLOjzMuX0BsHCM9JXggYB ./agent.sh
