# A docker stack with nginx, php 7.2 and mysql 5.7 for symfony project

### Copy the project that you want in app folder or create it

First start the container 

```make start```

Then init the project: composer install - create db & yarn install

```make init-project```

Host address 

```
http://localhost:8099/
```

do

```
sudo chmod -R 777 var/
```

If the port of mysql in already in use

```
sudo service mysql stop
```

to stop the containers simply do a
```
make stop
```
