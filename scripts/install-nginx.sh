sudo yum install epel-release -y
sudo yum install nginx -y

sudo mkdir -p /var/www/portal
sudo cp index-portal.html /var/www/portal/index.html

sudo mkdir -p /var/www/flow-orchestrator/v1.0/webhook/api/
sudo cp index-floworch.html /var/www/flow-orchestrator/v1.0/webhook/api/index.html

sudo chown -R nginx:nginx /var/www
sudo cp server*.conf /etc/nginx/conf.d

sudo semanage port -a -t http_port_t  -p tcp 8010
sudo semanage port -a -t http_port_t  -p tcp 8015
sudo setenforce permissive

sudo service nginx start
