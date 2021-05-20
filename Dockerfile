FROM debian:buster-slim

ENV OTRS_VERSION="6.0.31"

#Install OS dependencies
RUN apt-get update && apt-get install -y \
    libapache2-mod-perl2 \
    libdbd-mysql-perl \
    libtimedate-perl \
    libnet-dns-perl \
    libnet-ldap-perl \
    libio-socket-ssl-perl \
    libpdf-api2-perl \
    libdbd-mysql-perl \
    libsoap-lite-perl \
    libtext-csv-xs-perl \
    libjson-xs-perl \
    libapache-dbi-perl \
    libxml-libxml-perl \
    libxml-libxslt-perl \
    libyaml-perl \
    libarchive-zip-perl \
    libcrypt-eksblowfish-perl \
    libencode-hanextra-perl \
    libmail-imapclient-perl \
    libtemplate-perl \
    wget \
    tar \
    libdigest-md5-perl \
    libdatetime-perl \
    libmoo-perl \
    apache2 \
    libapache2-mod-perl2

#Download and unpackage
RUN wget "https://otrscommunityedition.com/download/otrs-community-edition-${OTRS_VERSION}.tar.gz" -O otrs.tar.gz \
    && mkdir /opt/otrs \
    && tar xzvf otrs.tar.gz -C /opt/otrs --strip-components=1 \
    && rm otrs.tar.gz

#Install required modules
RUN perl /opt/otrs/bin/otrs.CheckModules.pl

#OTRS user setup
RUN useradd -d /opt/otrs -c 'OTRS user' otrs \
    && groupadd www \
    && usermod -G www otrs

#Activate default config file
RUN cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm

#Check needed modules
RUN perl -cw /opt/otrs/bin/cgi-bin/index.pl \
    && perl -cw /opt/otrs/bin/cgi-bin/customer.pl \
    && perl -cw /opt/otrs/bin/otrs.Console.pl

#Apache setup
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/zzz_otrs.conf \
    && a2enmod perl \
    && a2enmod deflate \
    && a2enmod filter \
    && a2enmod headers \
    && /opt/otrs/bin/otrs.SetPermissions.pl

#Copy start script
COPY scripts/start.sh start.sh

CMD ["sh", "start.sh"]
