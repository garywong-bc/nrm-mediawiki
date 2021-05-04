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
export PROJECT=599f0a-dev
export WIKI=scrummaster
```

```bash
oc -n ${PROJECT} new-app --file=./ci/openshift/postgresql.dc.yaml -p WIKI_NAME=${WIKI}wiki
```
