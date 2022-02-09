# A docker stack with nginx, php and mysql 5.7 for symfony project

/!\Requirements : docker & docker-compose /!\

- Copy all the symfony files & folder you want and paste it in "app" folder.
Change the php version in php/Dockerfile to you need (ex: 7.2, 8.0....)

First start the container 

```make start```

Then init the project: composer install - create db & yarn install
/!\ Don't forgive to set the app/.env file with DATABASE_URL /!\

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
