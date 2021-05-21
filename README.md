# nrm-mediawiki

NRM MediaWiki

## Image

Artifactory secret is at:
https://console.apps.silver.devops.gov.bc.ca/k8s/ns/245e18-tools/secrets/artifacts-default-jtftbt

```bash
❯ oc -n 245e18-tools get secret/artifacts-default-jtftbt -o json | jq '.data.password' | tr -d "\"" | base64 -d
29k9IwCUb6SwloGZ7d5jrY1v%

❯ oc -n 245e18-tools get secret/artifacts-default-jtftbt -o json | jq '.data.username' | tr -d "\"" | base64 -d
default-245e18-ujotfv%
```

```bash
> curl -u <username>:<password> -X GET "https://artifacts.developer.gov.bc.ca/artifactory/api/repositories?type=remote" | \
 jq -r '(["ARTIFACTORYKEY","SOURCEURL"] | (., map(length*"-"))), (.[] | [.key, .url]) | @tsv' | column -t
```

```bash
❯ docker pull redhat-docker-remote.artifacts.developer.gov.bc.ca/openshift4/mediawiki-apb
Using default tag: latest
latest: Pulling from openshift4/mediawiki-apb
Digest: sha256:af2963b65d6203264ea9f97ebd4417ab96dd29cde08acae81215a92d0ab865d9
Status: Downloaded newer image for redhat-docker-remote.artifacts.developer.gov.bc.ca/openshift4/mediawiki-apb:latest
redhat-docker-remote.artifacts.developer.gov.bc.ca/openshift4/mediawiki-apb:latest
```

## DB

```bash
export TOOLS=245e18-tools
export PROJECT=245e18-dev
export WIKI=scrummaster
```

```bash
oc -n ${PROJECT} new-app --file=./ci/openshift/postgresql.dc.yaml -p WIKI=${WIKI}wiki
```

## Files

- [Deployment configuration](ci/openshift/mysql.dc.json) for MySQL database

## Deploy

### Database

Deploy the DB using the correct WIKI parameter (e.g. `sm`):  
`oc -n 245e18-dev new-app --file=./ci/openshift/mysql.dc.json -p WIKI=xyz`

#### Reset the Database

To redeploy _just_ the database, first delete the deployed objects from the last run, with the correct WIKI, such as:  
`oc -n 245e18-dev delete secret/xyz-wiki-mysql dc/xyz-wiki-mysql svc/xyz-wiki-mysql`

(`pvc/xyz-wiki-mysql` will be left as-is)

## Using an environmental variables to deploy

For each specific wiki, it may be useful to set an environment variable for the deployment, for example the `xyz` wiki, which will result in a URL of
`https://xyz-wiki.apps.silver.devops.gov.bc.ca/wiki/Main_Page`. Note that you must fill in the correct admin password (`supersecret` below) and email (`John.Doe@gov.bc.ca` below):

```bash
export TOOLS=245e18-tools
export PROJECT=245e18-dev
export WIKI=scrummaster
oc -n $PROJECT new-app --file=./ci/openshift/mysql.dc.yaml -p WIKI=$WIKI
oc -n $PROJECT new-app --file=./ci/openshift/mediawiki.dc.yaml -p WIKI=$WIKI -p MEDIAWIKI_EMAIL=Jesus.HernandezTapia@gov.bc.ca -p MEDIAWIKI_WIKI_NAME="NRM ScrumMasters Megathon"
```

## FAQ

1. To login the database, open the DB pod terminal (via OpenShift Console or `oc rsh`) and enter:
   `MYSQL_PWD="$MYSQL_PASSWORD" mysql -h 127.0.0.1 -u $MYSQL_USER -D $MYSQL_DATABASE`

From the MediwWiki pod:

`MYSQL_PWD="$MEDIAWIKI_DATABASE_PASSWORD" mysql -h $MEDIAWIKI_DATABASE_HOST -u $MEDIAWIKI_DATABASE_USER -D $MEDIAWIKI_DATABASE_NAME`

2. To reset all deployed objects (this will destroy all data and persistent volumes). Only do this on a botched initial install or if you have the DB backed up and ready to restore into the new wiped database.  
   `oc -n $PROJECT delete all,secret,pvc,cm,horizontalpodautoscaler -l app=$WIKI`

NOTE If using RH image `registry.redhat.io/openshift4/mediawiki:v4.2`, then the local
docker-compose needs fix from https://www.mediawiki.org/w/index.php?title=Topic:Qdndm8q8mlgvvs6j&topic_showPostId=su3oek2l90y1fx44#flow-post-su3oek2l90y1fx44

```bash
docker-compose exec wiki bash
bash-4.2$ vi /home/www-data/httpd/mediawiki/mw-config/index.php
bash-4.2$ vi /home/www-data/httpd/mediawiki/includes/NoLocalSettings.php
```

## Reconfigure

```bash
docker-compose exec mediawiki /bin/bash
```

```bash
sed 's/#$wgUseImageMagick/$wgUseImageMagick/' /opt/bitnami/mediawiki/LocalSettings.php > \
  /opt/bitnami/mediawiki/LocalSettings.php.changed && \
  mv /opt/bitnami/mediawiki/LocalSettings.php.changed \
     /opt/bitnami/mediawiki/LocalSettings.php

sed 's/#$wgImageMagickConvertCommand/$wgImageMagickConvertCommand/' /opt/bitnami/mediawiki/LocalSettings.php > \
  /opt/bitnami/mediawiki/LocalSettings.php.changed && \
  mv /opt/bitnami/mediawiki/LocalSettings.php.changed \
     /opt/bitnami/mediawiki/LocalSettings.php
```

```bash
cat >> /opt/bitnami/mediawiki/LocalSettings.php << EOF
\$wgFileExtensions = array( 'png', 'gif', 'jpg', 'jpeg', 'doc',
    'xls', 'mpp', 'pdf', 'ppt', 'tiff', 'bmp', 'docx', 'xlsx',
    'pptx', 'ps', 'odt', 'ods', 'odp', 'odg'
);
EOF
```

Or locally by editting `./docker/mediawiki/data/LocalSettings.php`

## To reset local DB

In running containers:

```bash
rm -rf ./docker/mariadb/data/
```

```bash
rm -rf ./docker/mediawiki/data/
```
