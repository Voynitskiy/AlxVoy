#!/bin/bash

while true
do

curl -s https://raw.githubusercontent.com/Voynitskiy/AlxVoy/main/logo.sh | bash

PS3='Select an action: '
options=(
"Setup parametrs for bot" 
"Start bot"
"Exit")
select opt in "${options[@]}"
               do
                   case $opt in
                   
"Setup parametrs for bot")
echo "┌────────────────────────────────────────────────────┐"
echo "               Setup your Telegramm API               "
echo "└────────────────────────────────────────────────────┘"
read TG_API
echo export TG_API=${TG_API} >> $HOME/.bash_profile
echo "┌────────────────────────────────────────────────────┐"
echo "                  Setup your Chat ID                  "
echo "└────────────────────────────────────────────────────┘"
read TG_ID
echo export TG_ID=${TG_ID} >> $HOME/.bash_profile
echo "┌────────────────────────────────────────────────────┐"
echo "              Setup your PRC port [26657]             "
echo "└────────────────────────────────────────────────────┘"
read PORT_ID
echo export PORT_ID=${PORT_ID} >> $HOME/.bash_profile
source $HOME/.bash_profile

mkdir $HOME/alarm
wget -O $HOME/alarm/alarm.sh https://raw.githubusercontent.com/Voynitskiy/AlxVoy/main/alarm/alarm.sh
chmod +x $HOME/alarm/alarm.sh
break
;;
            
"Start bot")
echo "┌────────────────────────────────────────────────────┐"
echo "                     Bot strating                     "
echo "└────────────────────────────────────────────────────┘"

crontab -e

break
;;

"Exit")
exit
;;

*) echo "invalid option $REPLY";;
esac
done
done
