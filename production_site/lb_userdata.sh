#!/bin/bash -v
sed -i -e 's/server localhost:8080;/server ${ip0}:8080;\n    server ${ip1}:8080;    server ${ip2}:8080;/g' /etc/nginx/sites-available/company_news
service nginx restart
