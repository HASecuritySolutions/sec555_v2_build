#!/bin/bash

# Install Prerequisites

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnome-terminal vim auditd nmap
sudo apt dist-upgrade -y
sudo mkdir /scripts
sudo mkdir /var/www/
sudo mkdir /var/www/sec555-wiki
cd /var/www/sec555-wiki
sudo mkdir /var/www/sec555-wiki/sec555-labs
sudo git clone https://github.com/sans-blue-team/sec555-wiki.git .
sudo mkdir /labs
sudo chown student: /labs

# Install Docker

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install -y docker.io
sudo usermod -aG docker ${USER}
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Install Visual Studio Code Editor

url https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code
curl -L https://github.com/HASecuritySolutions/sec555_v2_build/raw/master/settings.json -o $HOME/.config/Code/User/settings.json

# Set up desktop environment

mkdir $HOME/555_files
curl -L https://github.com/HASecuritySolutions/sec555_v2_build/raw/master/sec555_coin.png -o $HOME/555_files/sec555_coin.png
curl -L https://github.com/HASecuritySolutions/sec555_v2_build/raw/master/purple_terminal.bmp -o $HOME/555_files/purple_terminal.bmp

xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set $HOME/555_files/sec555_coin.png
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/image-path --set $HOME/555_files/sec555_coin.png
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/image-style --set 1

# Pull docker images
sudo docker pull httpd
sudo docker run -d --name wiki --restart always --net=bridge --network=labs_esnet -p 80:80 -v /var/www/sec555-wiki:/usr/local/apache2/htdocs/ httpd
sudo docker pull rabbitmq
sudo docker run -d --name rabbitmq --hostname rabbitmq --net=bridge --network=labs_esnet -p 5672:5672 -p 8080:8080 -p 15672:15672 -e RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.25 -e RABBITMQ_DEFAULT_USER=student -e RABBITMQ_DEFAULT_PASS=sec555 -v /labs/rabbitmq/mnesia:/var/lib/rabbitmq/mnesia rabbitmq:3-management
sudo docker pull hasecuritysolutions/wikiup:v1.0
sudo docker pull hasecuritysolutions/elastic_cron:v1.0
sudo docker pull hasecuritysolutions/elastalert:v0.1.31
sudo docker pull docker.elastic.co/beats/filebeat:6.2.4
sudo docker pull hasecuritysolutions/logstashoss:v6.2.2

sudo chmod 755 /labs/1.1/filebeat.yml

alias filebeat="docker run -it --rm --net=bridge --network=labs_esnet --name filebeat --hostname filebeat -v /labs:/labs:ro -v /var/log:/var/log:ro --link logstash docker.elastic.co/beats/filebeat:6.2.4 /usr/share/filebeat/filebeat"
alias nxlog="docker run -it --rm --net=bridge --network=labs_esnet --name nxlog --hostname nxlog -v /labs:/labs:ro -v /var/log:/var/log:ro --link logstash hasecuritysolutions/nxlog-ce:v2.10.2102 /usr/bin/nxlog"
alias nxlog-processor="docker run -it --rm --net=bridge --network=labs_esnet --name nxlog-processor --hostname nxlog-processor -v /labs:/labs:ro -v /var/log:/var/log:ro --link logstash hasecuritysolutions/nxlog-ce:v2.10.2102 /usr/bin/nxlog-processor"
alias logstash="docker run -it --rm --net=bridge --network=labs_esnet --name logstash --hostname logstash -v /labs:/labs -v /var/log:/var/log:ro --link rabbitmq --link elasticsearch --link freq_server --link domain_stats -u root -e ELASTICSEARCH_HOST=elasticsearch -p 1055:1055/udp -p 1056:1056 -p 5044:5044 -p 5045:5045 -p 6000:6000 -p 6050:6050 hasecuritysolutions/logstashoss:v6.2.2 /usr/share/logstash/bin/logstash"
alias pwsh="docker run -it --rm --net=bridge --network=labs_esnet -v /labs:/labs -v /scripts:/scripts -v /var/www:/var/www -v /home/student:/home/student -v /var/run/docker.sock:/var/run/docker.sock --link elasticsearch hasecuritysolutions/wikiup:v1.0 /usr/bin/pwsh"
alias curator="docker run -it --rm --net=bridge --network=labs_esnet -v /etc/localtime:/etc/localtime:ro --name curator --hostname curator -v /labs/curator:/labs/curator:ro -e TZ=America/Chicago -e ELASTICSEARCH_HOST=elasticsearch --net=bridge --link elasticsearch hasecuritysolutions/elastic_cron:v1.0 /usr/local/bin/curator"
alias elastalert="docker run -it --rm --net=bridge --network=labs_esnet --name elastalert --hostname elastalert -v /labs/elastalert:/labs/elastalert --link elasticsearch hasecuritysolutions/elastalert:v0.1.31 /usr/local/bin/elastalert"
alias wikiup="docker run -it --rm --net=bridge --network=labs_esnet -v /root/.ssh:/root/.ssh -v /home/student/.ssh:/home/student/.ssh -v /labs:/labs -v /var/www/sec555-wiki:/var/www/sec555-wiki -v /scripts:/scripts -v /var/run/docker.sock:/var/run/docker.sock -v /root:/root -v /home/student:/home/student hasecuritysolutions/wikiup:v1.0"
alias elastalert-test-rule="docker run -it --rm --net=bridge --network=labs_esnet --name elastalert --hostname elastalert -v /labs/elastalert:/labs/elastalert --link elasticsearch hasecuritysolutions/elastalert:v0.1.31 /usr/local/bin/elastalert-test-rule"
