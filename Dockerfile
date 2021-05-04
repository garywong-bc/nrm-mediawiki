FROM openshift/ose-base:ubi7
ENV __doozer=update BUILD_RELEASE=202006230600.p0 BUILD_VERSION=v4.2.36 OS_GIT_MAJOR=4 OS_GIT_MINOR=2 OS_GIT_PATCH=36 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.2.36-202006230600.p? 

ENV USER_NAME=www-data \
  USER_UID=1001 \
  BASE_DIR=/home/www-data \
  PHP=71 \
  HOME=${BASE_DIR}


RUN yum -y install mediawiki httpd ImageMagick git rh-php${PHP}* mediawiki-container-scripts \
  && yum clean all \
  && mkdir -p ${BASE_DIR} ${BASE_DIR}/etc \
  && useradd -u ${USER_UID} -r -g 0 -M -d ${BASE_DIR} -b ${BASE_DIR} -s /sbin/nologin -c "www-data user" ${USER_NAME} \
  && mkdir -p ${BASE_DIR}/httpd/{logs,run,html,conf} \
  && cp /opt/rh/httpd24/root/etc/httpd/conf/{httpd.conf,magic} ${BASE_DIR}/httpd/conf \
  && cp -R /usr/share/mediawiki ${BASE_DIR}/httpd/mediawiki \
  && mkdir ${BASE_DIR}/tmp \
  && cp -R /opt/rh/httpd24/root/etc/httpd/conf.modules.d ${BASE_DIR}/httpd/conf.modules.d \
  && cp -R /opt/rh/httpd24/root/etc/httpd/conf.d ${BASE_DIR}/httpd/conf.d \
  && chown -R ${USER_NAME}:0 ${BASE_DIR}/httpd \
  && mkdir -p ${BASE_DIR}/httpd/mediawiki/{cache,images} \
  && chmod 777 ${BASE_DIR}/httpd/mediawiki/{cache,images} \
  && chmod 777 /var/opt/rh/rh-php${PHP}/run/php-fpm \
  && chmod 777 ${BASE_DIR}/tmp \
  && chmod -R g+rw ${BASE_DIR} \
  && ln -sf /home/www-data /opt/rh/httpd24/root/home/www-data \
  && cp /usr/share/mediawiki-container-scripts/mediawiki.conf.example           ${BASE_DIR}/httpd/conf.d/mediawiki.conf \
  && sed -i -e 's/Listen 80/Listen 8080/'               -e "s@ServerRoot \"/etc/httpd\"@ServerRoot ${BASE_DIR}/httpd@"               -e 's@DocumentRoot "/var/www/.*"@DocumentRoot mediawiki/@'               -e "s@/var/www@${BASE_DIR}/httpd@"               -e "s@logs/error_log@${BASE_DIR}/httpd/logs/error_log@"               -e "s@logs/access_log@${BASE_DIR}/httpd/logs/access_log@" ${BASE_DIR}/httpd/conf/httpd.conf \
  && echo "PidFile /home/www-data/httpd/run/httpd.pid" >> ${BASE_DIR}/httpd/conf/httpd.conf \
  && echo "DefaultRuntimeDir /home/www-data/httpd/run/" >> ${BASE_DIR}/httpd/conf/httpd.conf \
  && rm -rf ${BASE_DIR}/httpd/modules \
  && ln -sf /opt/rh/httpd24/root/usr/lib64/httpd/modules/ ${BASE_DIR}/httpd/modules \
  && rm -rf /home/www-data/httpd/html \
  && ln -sf /home/www-data/httpd/mediawiki /home/www-data/httpd/html \
  && sed "s@${USER_NAME}:x:${USER_UID}:@${USER_NAME}:x:\${USER_ID}:@g" /etc/passwd > ${BASE_DIR}/etc/passwd.template

EXPOSE 8080
USER ${USER_UID}
ENTRYPOINT ["entrypoint.sh"]

LABEL \
  com.redhat.component="openshift-enterprise-mediawiki-container" \
  version="v4.2.36" \
  vendor="Red Hat" \
  name="openshift/mediawiki" \
  License="GPLv2+" \
  release="202006230600.p0" \
  io.openshift.maintainer.product="OpenShift Container Platform"