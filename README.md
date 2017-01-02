# docker-amavis

## Description:

This docker image provide a [amavis](https://www.ijs.si/software/amavisd/) and [spamassassin](http://spamassassin.apache.org/) and [clamAV](https://www.clamav.net/) service based on [Ubuntu](https://hub.docker.com/_/ubuntu/)

## Usage:

### Docker-compose:
```
version: '2'
services:
    mariadb:
        image: mariadb
        restart: always
        volumes:
            - /mariadb/data:/var/lib/mysql

    amavis:
        image: aknaebel/amavis
        links:
            - mariadb
        ports:
            - "783:783"
            - "3310:3310"
            - "10024:10024"
            - "10025:10025"
        volumes:
            - /amavis/data/amavis:/var/lib/amavis
            - /amavis/data/clamav:/var/lib/clamav
            - /amavis/data/spamassassin:/var/lib/spamassassin
        volumes:
            VIMBADMIN_PASSWORD=vimbadmin_password
            DBHOST=mariadb
            HOSTNAME=mail.example.com
        container_name: amavis
        restart: always
```

```
docker-compose up -d
```

## Amavis stuff:

### Environment variables:
- VIMBADMIN_PASSWORD: password for the vimdadmin user in database (see the vimbadmin image config)
- DBHOST: hostname of the databases host
- HOSTNAME: The FQDN of your mail server

### Ports:
- spamassassin (port 783)
- clamAV (port 3310)
- amavisd (port 10024)

### Cron:
The image come with a cron job inside to update the clamAV database

#### Database:
The image in design to use lookup into the same datase as vimbadmin to retrieve some datas about users

### Documentation
See the official documentation to configure a specific option of your amavis image
