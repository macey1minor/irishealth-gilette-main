ARG IMAGE=intersystemsdc/irishealth-community:preview
FROM $IMAGE as builder

ARG IRIS_PASSWORD

USER root

RUN pip3 install --no-cache-dir --target $ISC_PACKAGE_INSTALLDIR/mgr/python boto3
# RUN init.py TODO: create init.py to run the table creation script

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
USER ${ISC_PACKAGE_MGRUSER}

COPY . .
COPY src src
COPY iris.script /tmp/iris.script
COPY misc /usr/irissys

RUN mkdir -p /tmp/deps \
 && cd /tmp/deps \
 && wget -q https://pm.community.intersystems.com/packages/zpm/latest/installer -O zpm.xml


# run iris and initial 
RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
	&& iris stop IRIS quietly


FROM $IMAGE as final

ADD --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} https://github.com/grongierisc/iris-docker-multi-stage-script/releases/latest/download/copy-data.py /irisdev/app/copy-data.py

RUN --mount=type=bind,source=/,target=/builder/root,from=builder \
	cp -f /builder/root/usr/irissys/iris.cpf /usr/irissys/iris.cpf && \
	python3 /irisdev/app/copy-data.py -c /usr/irissys/iris.cpf -d /builder/root/ 
	
