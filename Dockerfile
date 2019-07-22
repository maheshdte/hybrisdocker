FROM ubuntu

RUN apt-get update \
 && apt-get -y install \ 
       git \ 
       software-properties-common \
       ca-certificates \
       p7zip \
       p7zip-full \
       curl \
       wget \
       ant \
       maven \
       gradle \
 &&  add-apt-repository -y ppa:openjdk-r/ppa && apt-get -y install openjdk-8-jdk    \   
&& rm -rf /var/lib/apt/lists/* 

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# set variable for hybris directory
ENV yHYBRIS_DIR="/var/hybris"

# download and extract hybris commerce suite
RUN mkdir -p $yHYBRIS_DIR

RUN mkdir /root/.ssh/
COPY id_rsa /root/.ssh/id_rsa
#RUN chmod 770 root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan git.metrosystems.net >> /root/.ssh/known_hosts \
    && ssh-keyscan 164.139.15.226 >> /root/.ssh/known_hosts

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN apt-get install --yes nodejs
RUN node -v
RUN npm -v
RUN npm i -g nodemon
RUN nodemon -v

RUN cd $yHYBRIS_DIR  && git clone git@git.metrosystems.net:real_efood/hybris-shop-oms.git

RUN adduser --disabled-password --gecos ""  hybris && su - hybris -c "touch me" && chown -R hybris $yHYBRIS_DIR/hybris-shop-oms && chmod -R  755 $yHYBRIS_DIR/hybris-shop-oms
 
# expose server port
EXPOSE 8009 8010 9001 9002 1099 8983

USER hybris
RUN cd $yHYBRIS_DIR/hybris-shop-oms/hybris  && ant  bootstrap   && ant customize patch clean all

RUN cd $yHYBRIS_DIR/hybris-shop-oms/hybris  && ant  initialize

RUN cd $yHYBRIS_DIR/hybris-shop-oms/client && npm install && npm run build:all

RUN rm -rf $yHYBRIS_DIR/hybris-shop-oms/client && rm -rf client-oms && rm -rf $yHYBRIS_DIR/hybris-shop-oms/.git && rm -rf $yHYBRIS_DIR/hybris-shop-oms/deployment && rm -rf $yHYBRIS_DIR/hybris-shop-oms/vagrant && rm -rf $yHYBRIS_DIR/hybris-shop-oms/external && rm -rf $yHYBRIS_DIR/hybris-shop-oms/miscellaneous && rm -rf $yHYBRIS_DIR/hybris-shop-oms/hybris/artifacts


# move to docker compose
CMD cd $yHYBRIS_DIR/hybris-shop-oms/hybris/bin/platform/ && ./hybrisserver.sh
