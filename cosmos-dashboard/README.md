# COSMOS DASHBOARD
### Configuring the Node
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.nolus/config/config.toml
systemctl restart nolusd
```
Check
```
echo "http://$(wget -qO- eth0.me):26660"
```
## Install Node Exporter
```
cd
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz
```
```
sudo cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -r node_exporter-*
node_exporter --version
```
Creating a service file
```
tee /etc/systemd/system/node_exporterd.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF
```
```
systemctl daemon-reload && systemctl enable node_exporterd
systemctl restart node_exporterd && journalctl -u node_exporterd -f -o cat
```
Check
```
curl 'localhost:9100/metrics'
```
```
echo "http://$(wget -qO- eth0.me):9100"
```
