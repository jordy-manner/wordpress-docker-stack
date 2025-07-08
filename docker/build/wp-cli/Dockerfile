FROM wordpress:cli-php8.3

USER root

# Install system dependencies
RUN apk update && apk add ssmtp

# Sendmail
RUN echo "hostname=localhost.localdomain" > /etc/ssmtp/ssmtp.conf
RUN echo "mailhub=mail:1025" >> /etc/ssmtp/ssmtp.conf

# Custom configuration
RUN echo "sendmail_path=sendmail -i -t" >> ${PHP_INI_DIR}/conf.d/98-sendmail.ini
RUN echo "smtp_port=1025" >> ${PHP_INI_DIR}/conf.d/98-sendmail.ini

USER www-data