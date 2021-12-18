FROM tomcat:9.0.54-jdk11-openjdk

COPY dev.war /usr/local/tomcat/webapps/

ENV DATASOURCE_URL jdbc:postgresql://postgres-base.postgres.database.azure.com:5432/teachua
ENV DATASOURCE_USER demo3
ENV DATASOURCE_PASSWORD p@ssw0rd
ENV MY_PASSWORD "Application is running"
ENV JWT_SECRET SecretString
