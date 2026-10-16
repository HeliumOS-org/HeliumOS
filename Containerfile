ARG BASE

FROM ${BASE}

ARG PLAYBOOK

LABEL containers.bootc=1

RUN dnf update -y
RUN dnf install -y ansible-core

WORKDIR /workdir

COPY . .
RUN cp -rf /workdir/files/* /

RUN ansible-playbook /workdir/playbooks/${PLAYBOOK}

RUN dnf remove -y ansible-core && dnf clean all
RUN rm -rdf /workdir /var/log

RUN bootc container lint
