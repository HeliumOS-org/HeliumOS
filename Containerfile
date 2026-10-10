ARG BASE

FROM ${BASE}

ARG PLAYBOOK

LABEL containers.bootc=1

RUN rm -f /usr/share/rpm/rpmdb.sqlite-shm /usr/share/rpm/rpmdb.sqlite-wal; \
    rpm --rebuilddb || true; \
    new="$(ls -d /usr/share/rpmrebuilddb.* | head -1)"; \
    rm -rf /usr/share/rpm && mv "$new" /usr/share/rpm

RUN dnf update -y
RUN dnf install -y ansible-core

WORKDIR /workdir

COPY . .
RUN cp -rf /workdir/files/* /

RUN ansible-playbook /workdir/playbooks/${PLAYBOOK}

# RUN dnf remove -y ansible-core && dnf clean all
RUN rm -rdf /workdir /var/log

RUN bootc container lint
