## Configure the bot to monitor the status of the HAQQ node

Follow a few simple steps to install:

1. Create a bot, get an api token (To get a token, you can use FatherBot in telegram) and a telegram chat id, you can read how to do it at the link - [(ENG)](https://sean-bradley.medium.com/get-telegram-chat-id-80b575520659 "") [(RU)](https://nastroyvse.ru/programs/review/telegram-id-kak-uznat-zachem-nuzhno.html "")  
2. Run the script, select the installation stage, which will ask you to enter API_token, telegram chat id and PRC port.
```
curl -s https://raw.githubusercontent.com/Voynitskiy/AlxVoy/main/alarm/setup.sh > setup.sh && chmod +x setup.sh && ./setup.sh
```
3. Select the "Start bot" item and enter the following data in the line that appears, you also need to leave the next line empty
```
*/1 * * * *  /bin/bash $HOME/alerm/alert.sh
```
