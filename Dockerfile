FROM alpine:3.9

ENV KUBECTL_VERSION="1.14.2"
ENV HELM_VERSION="2.14.0"
ENV PULUMI_VERSION="1.5.2"

RUN apk add --update --no-cache ca-certificates curl

RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

RUN apk add --update -t deps curl \
 && curl -sL https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 && cd /tmp \
 && tar xfvz helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && chmod +x /usr/local/bin/helm \
 && rm -r linux-amd64/ \
 && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 && apk del --purge deps \
 && rm /var/cache/apk/*

RUN apk add --update --no-cache nodejs npm yarn libc6-compat \
 && curl -sL https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz -o /tmp/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
 && cd /tmp \
 && tar xfvz pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
 && mv pulumi/* /usr/bin \
 && rm pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /deployment
ENTRYPOINT ["/entrypoint.sh"]
