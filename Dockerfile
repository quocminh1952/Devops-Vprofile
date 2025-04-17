# thiết lập base image
FROM tomcat:10-jdk21
LABEL "Project"="CICD-Jenkins-Docker"
LABEL "Author"="InkDevops-Minh1952"

#Xóa web tomcat mặc định
RUN rm -rf /usr/local/tomcat/webapp/*
#Copy artifact vào webapp
COPY target/*.war /usr/local/tomcat/webapp/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
WORKDIR /usr/local/tomcat/