# thiết lập base image
FROM tomcat:10-jdk21
#Xóa web tomcat mặc định
RUN rm -rf /usr/local/tomcat/webapps/*
#Copy artifact vào webapp
COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
WORKDIR /usr/local/tomcat/
VOLUME /usr/local/tomcat/webapps
