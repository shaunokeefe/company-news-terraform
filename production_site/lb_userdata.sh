#!/bin/bash -v
sed -i -e 's/server localhost:8080;/server 172.31.24.20:8080;\n    server 172.31.24.21:8080;/g' /etc/nginx/sites-available/company_news
service nginx restart
