FROM alpine:3.19
LABEL maintainer="Bart Smeding"
ENV container=docker

ENV pip_packages "ansible-core yamllint jmespath"

# Install requirements
RUN apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        build-base && \
    rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED \
    && pip3 install --upgrade pip wheel \
    && pip3 install --upgrade cryptography cffi \
    && pip3 install mitogen jmespath \
    && pip3 install --upgrade pywinrm

# Install Ansible and other applications via pip
RUN pip3 install $pip_packages

# Clean up
RUN apk del build-dependencies \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

# Set localhost Ansible inventory file
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# Set working directory
RUN mkdir -p /ansible
WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
