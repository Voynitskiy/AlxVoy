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
## Install Cosmos Exporter
```
cd
wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v0.3.0/cosmos-exporter_0.3.0_Linux_x86_64.tar.gz
tar xvf cosmos-exporter*
```
```
cp cosmos-exporter /usr/local/bin
chown cosmos_exporter:cosmos_exporter /usr/local/bin/cosmos-exporter
rm -rf cosmos-exporter*
```
Creating a service file
```
tee /etc/systemd/system/cosmos-exporterd.service > /dev/null <<EOF
[Unit]
Description=Cosmos Exporter
After=network-online.target

[Service]
User=cosmos_exporter
Group=cosmos_exporter
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=/usr/local/bin/cosmos-exporter --denom unls --denom-coefficient 1000000 --bech-prefix nolus --node localhost:9090 --tendermint-rpc http://localhost:26657
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
```
```
systemctl daemon-reload && systemctl enable cosmos-exporterd
systemctl restart cosmos-exporterd && journalctl -u cosmos-exporterd -f -o cat
```
