import jwt
import time 
import sys
import requests
import json
# Get PEM file path
if len(sys.argv) > 3:
    pem = sys.argv[1]
    app_id = sys.argv[2]
    install_id = sys.argv[3]
else:
    print("Pass in path to PEM, Github APP ID and Github INSTALLATION ID at runtime, separated by a space. i.e. `python3 create-token.py private.pem 123456 87654321``")
    exit(1)
# Open PEM
with open(pem, 'r') as pem_file:
    signing_key = pem_file.read()
    
payload = {
    # Issued at time
    'iat': int(time.time()),
    # JWT expiration time (10 minutes maximum)
    'exp': int(time.time()) + 600, 
    # GitHub App's identifier
    'iss': app_id
}
    
# Create JWT
encoded_jwt = jwt.encode(payload, signing_key, algorithm='RS256')

# get installations
#get_installs_api_url = "https://api.github.com/app/installations"
get_installs_headers = {"Authorization": "Bearer "+encoded_jwt,"Accept": "application/vnd.github+json"}
#get_installs_resp_raw = requests.get(get_installs_api_url, headers=get_installs_headers)

#get token url from installations
#get_installs_resp = get_installs_resp_raw.json()
#print(get_installs_resp)

# get token url from provided installation
gh_app_token_url =  "https://api.github.com/app/installations/"+sys.argv[3]+"/access_tokens"

#create token
gh_token_resp_raw = requests.post(gh_app_token_url,headers=get_installs_headers)
gh_token_resp = gh_token_resp_raw.json()
gh_token = gh_token_resp['token']

print(gh_token)
