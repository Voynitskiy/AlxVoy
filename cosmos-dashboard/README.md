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
