FROM centos:7

ARG FATE_REPO=FederatedAI/FATE
ARG FATE_BRANCH=master
ARG PYTHON_VERSION=3.6.14

# python
RUN yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm \
    && yum install -y python3-pip python-devel git \
    && yum -y install gcc gcc-c++ make openssl-devel gmp-devel mpfr-devel libmpc-devel libaio numactl autoconf automake libtool libffi-devel snappy snappy-devel zlib zlib-devel bzip2 bzip2-devel lz4-devel libasan lsof sysstat telnet psmisc


ENV PATH=/root/.pyenv/bin:/root/.pyenv/shims:$PATH
RUN curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && { echo; \
        echo 'eval "$(pyenv init -)"'; \
        echo 'eval "$(pyenv virtualenv-init -)"'; } >> /root/.bashrc \
    && pyenv update \
    && pyenv install ${PYTHON_VERSION} \
    && /root/.pyenv/versions/${PYTHON_VERSION}/bin/python -m venv /venv \
    && /venv/bin/python -m pip install --no-cache-dir --upgrade pip \
    && /venv/bin/python -m pip install --no-cache-dir -r  "https://raw.githubusercontent.com/${FATE_REPO}/${FATE_BRANCH}/python/requirements.txt" \
    && rm -rf /tmp/*

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# fate_client and fate_test
RUN /venv/bin/python -m pip install --no-cache-dir "git+https://github.com/${FATE_REPO}.git@${FATE_BRANCH}#egg=fate_client&subdirectory=python/fate_client" \
    && /venv/bin/python -m pip install --no-cache-dir "git+https://github.com/${FATE_REPO}.git#${FATE_BRANCH}#egg=fate_test&subdirectory=python/fate_test"  \
    && rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]