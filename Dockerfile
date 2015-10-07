FROM centos:centos6
MAINTAINER Andrei Colta andrycolt007@gmail.com

#Add EPEL Repo
#Add Epel centos 6 repo
RUN rpm -Uvh http://fedora.mirrors.telekom.ro/pub/epel/6/i386/epel-release-6-8.noarch.rpm && yum -y update && yum clean all

# Install necessary packages
RUN yum install -y passwd rsync xmlstarlet wget postgres vim telnet curl saxon augeas tar bsdtar unzip net-tools htop openssh-clients openssh-server python-setuptools java-1.7.0-openjdk-devel && easy_install supervisor 

# Update system
RUN yum update -y

RUN curl http://files.amakitu.com/UnlimitedJCEPolicy.zip -o /root/UnlimitedJCEPolicy.zip
RUN unzip /root/UnlimitedJCEPolicy.zip -d /root/  
RUN cp -rf /root/UnlimitedJCEPolicy/*.jar /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.85.x86_64/jre/lib/security/

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss

# Set the JAVA_HOME variable to make it clear where Java is located
ENV JAVA_HOME=/usr/lib/jvm/java JBOSS_VERSION=7.1.1.Final JBOSS_HOME=/opt/jboss/jboss-as-7.1.1.Final 


USER jboss
# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

ENV HOME=/opt/jboss

# Make sure the distribution is available from a well-known place
RUN cd  $HOME && curl http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-$JBOSS_VERSION.tar.gz  | tar zx 

USER root
# Add  admin user 
# RUN /opt/jboss/wildfly/bin/add-user.sh admin admin123! --silent
RUN $JBOSS_HOME/bin/add-user.sh admin admin123! --silent=true

# Enable binding to all network interfaces and debugging inside the server
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Xmx2048m -XX:MaxPermSize=256m -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> ${JBOSS_HOME}/bin/standalone.conf

# Change default memory settings
RUN  sed -i 's/-Xms64m\ -Xmx512m\ -XX\:MaxPermSize=256m/-Xms128m\ -Xmx2048m\ -XX\:MaxPermSize=512m/g'   ${JBOSS_HOME}/bin/standalone.conf

RUN rm -rf /opt/jboss/jboss-as-7.1.1.Final/standalone/configuration/standalone_xml_history/current


