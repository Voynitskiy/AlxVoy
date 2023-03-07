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
ExecStart=/usr/local/bin/cosmos-exporter --denom unls \
  --denom-coefficient 1000000 \
  --bech-prefix nolus \
  --node localhost:9090 \
  --tendermint-rpc http://localhost:26657
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
# Grafana & Prometheus
#### Install it on a separate server
## Install Prometheus
```
mkdir /etc/prometheus
mkdir /var/lib/prometheus
```
```
cd && \
wget https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz && \
tar xvf prometheus-2.38.0.linux-amd64.tar.gz
```
```
cp prometheus-2.38.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.38.0.linux-amd64/promtool /usr/local/bin/
cp -r prometheus-2.38.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.38.0.linux-amd64/console_libraries /etc/prometheus
cp prometheus-2.38.0.linux-amd64/prometheus.yml /etc/prometheus/
rm -rf prometheus-2.38.0.linux-amd64.tar.gz prometheus-2.38.0.linux-amd64
```
Check
```
prometheus --version
promtool --version
```
## Configuring Prometheus
```
curl -sSL https://raw.githubusercontent.com/lesnikutsa/cosmos-monitoring/main/prometheus.yml > /etc/prometheus/prometheus.yml
```
```
mkdir -p $HOME/prometheus && cd prometheus
wget -q -O add_node.sh https://raw.githubusercontent.com/lesnikutsa/cosmos-monitoring/main/add_node.sh && chmod +x add_node.sh
```
Adding a value to variables
```
VALIDATOR_IP=<YOUR_VALIDATOR_IP>
VALOPER_ADDRESS=<YOUR_VALOPER_ADDRESS>
WALLET_ADDRESS=<YOUR_WALLET_ADDRESS>
$HOME/prometheus/add_node.sh $VALIDATOR_IP $VALOPER_ADDRESS $WALLET_ADDRESS Nolus
```
Check
```
nano /etc/prometheus/prometheus.yml
```
#### Example
```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
rule_files: null
scrape_configs:
  - job_name: prometheus
    metrics_path: /metrics
    static_configs:
      - targets:
          - localhost:9090
  - job_name: cosmos
    metrics_path: /metrics
    static_configs:
      - targets:
          - 135.181.46.247:26660
        labels: {}
      - targets:
          - 135.181.46.247:26660
        labels: {}
  - job_name: node
    metrics_path: /metrics
    static_configs:
      - targets:
          - 135.181.46.247:9100
        labels:
          instance: nolus
      - targets:
          - 135.181.46.247:9100
        labels:
          instance: nolus
  - job_name: validators
    metrics_path: /metrics/validators
    static_configs:
      - targets:
          - 135.181.46.247:9300
        labels: {}
      - targets:
          - 135.181.46.247:9300
        labels: {}
  - job_name: validator
    metrics_path: /metrics/validator
    relabel_configs:
      - source_labels:
          - address
        target_label: __param_address
    static_configs:
      - targets:
          - 135.181.46.247:9300
        labels:
          address: nolusvaloper1rp9sy3rzdavu2f5764r2304ftetm3ytc5fyswa
      - targets:
          - 135.181.46.247:9300
        labels:
          address: nolusvaloper1rp9sy3rzdavu2f5764r2304ftetm3ytc5fyswa
  - job_name: wallet
    metrics_path: /metrics/wallet
    relabel_configs:
      - source_labels:
          - address
        target_label: __param_address
    static_configs:
      - targets:
          - 135.181.46.247:9300
        labels:
          address: nolus1rp9sy3rzdavu2f5764r2304ftetm3ytcde34dq
      - targets:
          - 135.181.46.247:9300
        labels:
          address: nolus1rp9sy3rzdavu2f5764r2304ftetm3ytcde34dq
```
Creating a service file
```
tee /etc/systemd/system/prometheusd.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
```
```
systemctl daemon-reload && systemctl enable prometheusd
systemctl restart prometheusd && sudo systemctl status prometheusd
```
Check
```
curl 'localhost:9090/metrics'
```
Check Targets
```
echo "http://$(wget -qO- eth0.me):9090"
```
## Install Grafana
```
sudo apt-get install -y adduser libfontconfig1 && \
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_9.1.3_amd64.deb && \
sudo dpkg -i grafana-enterprise_9.1.3_amd64.deb
```
```
systemctl daemon-reload && systemctl enable grafana-server
systemctl restart grafana-server && journalctl -u grafana-server -f
```
### Configuring Grafana on the site
```
echo "http://$(wget -qO- eth0.me):3000"
```
### Enter
* `Login` admin
* `Password` admin

![Enter](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-1.png)
### Go to Data sources
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-2.png)
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-3.png)
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-4.png)
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-5.png)
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-6.png)
### Download Dashboard
[https://grafana.com/grafana/dashboards/17100-cosmos-node-monitoring-from-neobase/](https://grafana.com/grafana/dashboards/17100-cosmos-node-monitoring-from-neobase/)
### Uploading Dashboard
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-7.png)
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-8.png)
![Data sources](https://github.com/Voynitskiy/AlxVoy/raw/main/cosmos-dashboard/Grafana-9.png)
