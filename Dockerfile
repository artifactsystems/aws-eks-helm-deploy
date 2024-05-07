FROM alpine/helm:3.9.0 as helm
RUN chown root:root /usr/bin/helm

FROM python:3-alpine

ENV HELM_SECRETS_VERSION v4.6.0
ENV SOPS_VERSION v3.8.1

RUN mkdir -p /opt/pipe

COPY requirements.txt /opt/pipe
RUN pip install -r /opt/pipe/requirements.txt

COPY pipe /opt/pipe
COPY LICENSE.txt pipe.yml README.md /opt/pipe/

COPY --chown=root:root --from=helm /usr/bin/helm /usr/bin/helm

RUN apk add git
RUN /usr/bin/helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_SECRETS_VERSION}
RUN wget -O sops https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 && chmod +x sops && mv sops /usr/bin/sops

ENTRYPOINT ["python"]
CMD ["/opt/pipe/pipe.py"]
