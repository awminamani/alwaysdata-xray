AlwaysData Xray Installer

A simple installer for running Xray-core on an "AlwaysData" (https://www.alwaysdata.com/) account using an AlwaysData Service and Reverse Proxy.

The installer:

- Downloads Xray-core
- Detects the server architecture
- Generates a random UUID
- Creates an Xray VLESS + WebSocket configuration
- Uses a configurable service port
- Creates a simple static homepage
- Tests the Xray configuration
- Prints the settings needed for the AlwaysData dashboard
- Prints a ready-to-import VLESS URI

«Important: This project does not automatically configure the AlwaysData dashboard. The Service and Reverse Proxy must be created from the AlwaysData dashboard.»

---

Features

- VLESS
- WebSocket transport
- TLS through AlwaysData's HTTPS reverse proxy
- Automatic UUID generation
- Automatic architecture detection
- Xray configuration validation
- Simple "/" homepage
- "/xray" WebSocket endpoint
- Designed for AlwaysData Services
- No credentials stored in the repository

---

Requirements

You need:

- An AlwaysData account
- SSH access to your AlwaysData account
- A Linux-compatible AlwaysData environment
- Internet access from the server
- A GitHub repository containing this project

The installer does not require root access.

---

How the setup works

The final architecture looks like this:

VLESS Client
     │
     │ HTTPS / TLS
     ▼
https://YOUR_DOMAIN/xray
     │
     │ AlwaysData Reverse Proxy
     ▼
services-YOUR_ACCOUNT.alwaysdata.net:8300
     │
     │ WebSocket
     ▼
Xray-core
     │
     ▼
Internet

The public HTTPS connection is handled by AlwaysData.

Xray itself listens on the internal AlwaysData Service port.

---

1. Connect to AlwaysData

From your terminal:

ssh YOUR_ACCOUNT@YOUR_SSH_HOST

Example:

ssh youruser@ssh1

Replace the values with the SSH information shown in your AlwaysData dashboard.

---

2. Download the installer

You can clone this repository:

git clone https://github.com/awminamani/alwaysdata-xray.git

Enter the directory:

cd alwaysdata-xray

Make the installer executable:

chmod +x install.sh

Run it:

./install.sh

---

Alternative: download the installer directly

If you don't want to clone the entire repository:

curl -fsSL https://raw.githubusercontent.com/awminamani/alwaysdata-xray/main/install.sh -o install.sh

Then:

chmod +x install.sh
./install.sh

«Always inspect scripts before running them on an account you care about.»

---

3. What the installer creates

The installer creates:

~/xray/
├── xray
├── config.json
└── ...

The generated configuration contains:

Protocol: VLESS
Transport: WebSocket
Path: /xray
Port: 8300
Encryption: none
UUID: randomly generated

The UUID is generated locally and is not stored in this GitHub repository.

---

4. Test the Xray configuration

After installation:

~/xray/xray run -test -config ~/xray/config.json

A successful configuration should show:

Configuration OK.

Warnings about deprecated transports do not necessarily mean the configuration failed.

The important result is:

Configuration OK.

---

5. Create the AlwaysData Service

Open your AlwaysData dashboard.

Go to:

Administration
→ Remote access
→ Services

Create a new service.

Service settings

Name

You can use:

xray

SSH user

Select your AlwaysData SSH user.

Example:

YOUR_ACCOUNT

Command

Use the absolute path to the Xray binary:

/home/YOUR_ACCOUNT/xray/xray run -config /home/YOUR_ACCOUNT/xray/config.json

Replace:

YOUR_ACCOUNT

with your AlwaysData account name.

Working directory

/home/YOUR_ACCOUNT/xray/

Environment

Leave empty unless you specifically need environment variables.

Monitoring

Leave empty.

Paused

Make sure the service is not paused.

---

6. Service port

The default installer configuration uses:

8300

AlwaysData Services intended to be externally reachable should use the supported service-port range.

The service should listen on:

::

The Xray configuration should therefore contain:

"listen": "::",
"port": 8300

Do not change this to port "443".

AlwaysData's public web frontend handles HTTPS/TLS on the public domain.

---

7. Create the Reverse Proxy

Now create a new AlwaysData website.

Go to:

Web
→ Sites
→ Add a site

Create a site using:

Type: Reverse proxy

Use your AlwaysData domain.

For example:

YOUR_DOMAIN.alwaysdata.net

For the remote URL, use:

http://services-YOUR_ACCOUNT.alwaysdata.net:8300

Replace:

YOUR_ACCOUNT

with your AlwaysData account name.

---

8. WebSocket path

The Xray configuration uses:

/xray

Therefore your public endpoint becomes:

https://YOUR_DOMAIN.alwaysdata.net/xray

The important parts are:

Protocol: HTTPS
Port: 443
Path: /xray
Transport: WebSocket

The TLS certificate is handled by AlwaysData.

---

9. Optional homepage

The installer creates a simple static homepage.

The homepage is located at:

~/www/index.html

You can edit it with:

nano ~/www/index.html

The page can be used as the actual homepage for your personal/project website.

For example:

https://YOUR_DOMAIN.alwaysdata.net/

can show a normal project or personal-services page, while the WebSocket endpoint is:

https://YOUR_DOMAIN.alwaysdata.net/xray

Important

A homepage should represent a genuine website or project.

Do not use a fake website specifically to disguise prohibited activity or evade AlwaysData's policies.

---

10. VLESS client configuration

After installation, the installer prints your generated UUID.

You will need that UUID when configuring your client.

Use these settings:

Protocol: VLESS

Address:
YOUR_DOMAIN.alwaysdata.net

Port:
443

UUID:
YOUR_GENERATED_UUID

Encryption:
none

Network:
WebSocket

WebSocket Path:
/xray

TLS:
ON

SNI:
YOUR_DOMAIN.alwaysdata.net

Host:
YOUR_DOMAIN.alwaysdata.net

---

11. Dummy VLESS configuration

The following configuration is intentionally fake.

It is safe to include in this repository and will not work.

Replace the dummy values with the values generated by your own installation.

VLESS URI

vless://00000000-0000-0000-0000-000000000000@example.alwaysdata.net:443?type=ws&path=%2Fxray&security=tls&encryption=none&host=example.alwaysdata.net&sni=example.alwaysdata.net#Example

JSON example

{
  "v": "2",
  "ps": "Example",
  "add": "example.alwaysdata.net",
  "port": "443",
  "id": "00000000-0000-0000-0000-000000000000",
  "aid": "0",
  "scy": "none",
  "net": "ws",
  "type": "none",
  "host": "example.alwaysdata.net",
  "path": "/xray",
  "tls": "tls",
  "sni": "example.alwaysdata.net"
}

Client settings

Address: example.alwaysdata.net
Port: 443
UUID: 00000000-0000-0000-0000-000000000000

Security: TLS
SNI: example.alwaysdata.net

Network: WebSocket
Path: /xray
Host: example.alwaysdata.net

Encryption: none

Again, these values are dummy values only.

---

12. Finding your generated UUID

The installer generates the UUID automatically.

You can view your configuration with:

cat ~/xray/config.json

Look for:

"id": "YOUR_GENERATED_UUID"

You can also extract it with:

grep -o '"id": "[^"]*"' ~/xray/config.json

---

13. Checking whether Xray is running

Check the process:

ps aux | grep '[x]ray'

Check the listening port:

ss -lnt | grep 8300

You should see Xray listening on the configured service port.

---

14. Restarting Xray

If Xray is running as an AlwaysData Service, restart it from the AlwaysData dashboard.

Do not normally run another copy manually with:

~/xray/xray run -config ~/xray/config.json &

because that can create multiple Xray processes using the same port.

Use the AlwaysData Service as the process manager.

---

15. Checking the public endpoint

Open:

https://YOUR_DOMAIN.alwaysdata.net/xray

in a browser.

You may receive:

Bad Request

This does not necessarily mean Xray is broken.

The endpoint expects a VLESS WebSocket connection, not a normal browser HTTP request.

A normal browser sends an ordinary HTTP request, while the Xray client sends a VLESS-over-WebSocket handshake.

---

16. Troubleshooting

Configuration OK but client doesn't connect

First test:

~/xray/xray run -test -config ~/xray/config.json

Make sure you get:

Configuration OK.

Then check the service:

AlwaysData
→ Administration
→ Remote access
→ Services

Make sure it is running.

---

503 Service Unavailable

Check the Reverse Proxy remote URL.

It should use the AlwaysData service hostname:

http://services-YOUR_ACCOUNT.alwaysdata.net:8300

Do not use:

http://localhost:8300

or:

http://127.0.0.1:8300

AlwaysData's externally reachable Services use the service hostname.

---

Permission denied on port 443

Do not configure Xray to directly bind to:

443

The public HTTPS frontend is controlled by AlwaysData.

Use a Service port such as:

8300

and let the Reverse Proxy expose it through HTTPS.

---

Port already in use

Check:

ss -lntp | grep 8300

If another Xray process is already running, don't start another one manually.

Check the AlwaysData Service first.

---

Xray service immediately stops

Check:

~/xray/xray run -test -config ~/xray/config.json

Then inspect the service logs in the AlwaysData dashboard.

Common causes include:

- Invalid JSON
- Incorrect Xray path
- Incorrect binary architecture
- Port already in use
- Incorrect file permissions
- Missing files

---

17. Changing the WebSocket path

The default path is:

/xray

If you want another path, edit:

nano ~/xray/config.json

Find:

"path": "/xray"

and change it.

For example:

"path": "/ws"

Then update the Reverse Proxy/client configuration accordingly.

---

18. Changing the service port

The default port is:

8300

If you change it, make sure the new port is supported by AlwaysData Services.

For example:

8301

Update both:

Xray

"port": 8301

Reverse Proxy

http://services-YOUR_ACCOUNT.alwaysdata.net:8301

---

19. Security

Never commit your real credentials to GitHub.

Do NOT put these in the repository:

Real UUID
AlwaysData password
SSH private key
API tokens
GitHub tokens
Private keys

The following is safe:

00000000-0000-0000-0000-000000000000

because it is only a dummy UUID.

---

20. ".gitignore"

Create a ".gitignore" file:

nano .gitignore

Recommended contents:

.env
.env.*
*.key
*.pem
*.crt
id_rsa
id_ed25519

config.local.json
credentials.json

xray/
www/

If the installer itself creates "~/xray" and "~/www" outside the Git repository, these entries are not strictly necessary, but keeping sensitive/generated files out of Git is a good practice.

---

21. Updating Xray

Before updating, test the current configuration:

~/xray/xray run -test -config ~/xray/config.json

Back up the configuration:

cp ~/xray/config.json ~/xray/config.json.backup

Then install the newer Xray version using the installer/update procedure provided by this repository.

After updating:

~/xray/xray version

and:

~/xray/xray run -test -config ~/xray/config.json

Restart the AlwaysData Service after confirming the configuration is valid.

---

22. Useful commands

Show Xray version

~/xray/xray version

Test configuration

~/xray/xray run -test -config ~/xray/config.json

View configuration

cat ~/xray/config.json

Edit configuration

nano ~/xray/config.json

Check Xray process

ps aux | grep '[x]ray'

Check port

ss -lnt | grep 8300

Check files

ls -lah ~/xray

---

23. Recommended project structure

The GitHub repository can look like:

alwaysdata-xray/
│
├── install.sh
├── README.md
├── LICENSE
└── .gitignore

Do not commit generated credentials or your personal Xray configuration.

---

24. Installation summary

The short version:

1. Create an AlwaysData account
        ↓
2. Connect through SSH
        ↓
3. Download install.sh
        ↓
4. Run install.sh
        ↓
5. Xray generates a UUID
        ↓
6. Create an AlwaysData Service
        ↓
7. Run Xray on port 8300
        ↓
8. Create a Reverse Proxy
        ↓
9. Point it to:
   services-YOUR_ACCOUNT.alwaysdata.net:8300
        ↓
10. Use:
    https://YOUR_DOMAIN.alwaysdata.net/xray
        ↓
11. Configure your VLESS client

---

25. Example final configuration

For a fictional account:

Account:
demo

Domain:
demo.alwaysdata.net

Service:
services-demo.alwaysdata.net:8300

Protocol:
VLESS

Transport:
WebSocket

Path:
/xray

TLS:
Enabled

Public port:
443

The fictional VLESS URI would look like:

vless://00000000-0000-0000-0000-000000000000@demo.alwaysdata.net:443?type=ws&path=%2Fxray&security=tls&encryption=none&host=demo.alwaysdata.net&sni=demo.alwaysdata.net#Demo

This example is intentionally non-functional.

---

26. AlwaysData documentation

For official documentation, see:

- "AlwaysData Services" (https://help.alwaysdata.com/en/docs/web-hosting/services/)
- "Adding a Site" (https://help.alwaysdata.com/en/docs/web-hosting/sites/add-a-site/)
- "HTTP Stack" (https://help.alwaysdata.com/en/docs/web-hosting/sites/http-stack/)
- "AlwaysData API" (https://help.alwaysdata.com/en/docs/development/api/usage/)
- "AlwaysData Login Details" (https://help.alwaysdata.com/en/docs/technical-specifications/login-details/)

---

Disclaimer

This project is provided for educational and self-hosting purposes.

You are responsible for complying with:

- AlwaysData's terms and acceptable-use policies
- Your local laws
- Network/provider rules
- Any applicable software licenses

Do not use the project to evade provider restrictions, abuse network resources, attack systems, or violate applicable 
