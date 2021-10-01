{config, ...}:
let
  allowHttps = true;

  serverTemplate = {
    domain,
    proxyTarget,
    redirectWww ? false,
    enableHttps ? false
    }: let
      wwwAlias = if redirectWww then "www.${domain}" else "";

      proxyConfig = ''
location / {
          proxy_pass ${proxyTarget};
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }

location ^~ /ws {
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_set_header X-NginX-Proxy true;
      proxy_pass   http://127.0.0.1:8546/;
  }

  location ^~ /rpc {
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_set_header X-NginX-Proxy true;
      proxy_pass    http://127.0.0.1:8545/;
   }
      
      '';

      httpChallengeConfig = ''
        location /.well-known/acme-challenge {
          root /var/www/challenges;
        }

        location / {
          return 301 https://${domain}$request_uri;
        }
      '';

      secureServer = ''
        server {
          server_name ${domain};
          listen 443 ssl;
          ssl_certificate     ${config.security.acme.directory}/${domain}/fullchain.pem;
          ssl_certificate_key ${config.security.acme.directory}/${domain}/key.pem;

          ${proxyConfig}
        }
      '';
    in ''
      server {
        server_name ${domain} ${wwwAlias};
        listen 80;
        listen [::]:80;

        ${if enableHttps then httpChallengeConfig else proxyConfig}
      }

      ${if enableHttps then secureServer else ""}
    '';
in {
  networking.hostName = "openmev";
  networking.firewall.allowedTCPPorts = [80 443];

  services.httpd.enable = true;
  services.httpd.adminAddr = "admin@openmev.org";
  services.httpd.documentRoot = ./static;
  services.httpd.port = 8080;

  services.nginx.enable = true;
  services.nginx.httpConfig =
    serverTemplate {
      domain = "openmev.net";
      redirectWww = true;
      proxyTarget = "http://127.0.0.1:8080";
      enableHttps = allowHttps;
    };
} // (if allowHttps then {
  security.acme.certs."openmev.net" = {
    webroot = "/var/www/challenges";
    email   = "admin@openmev.org";
    postRun = "systemctl reload nginx.service";
  };
} else {})
