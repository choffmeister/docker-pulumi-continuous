FROM alpine:3.9

ENV PULUMI_VERSION="1.5.2"

RUN apk add --update --no-cache bash curl git

RUN apk add --update --no-cache nodejs npm yarn libc6-compat \
 && curl -sL https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz -o /tmp/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
 && cd /tmp \
 && tar xfvz pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
 && mv pulumi/* /usr/bin \
 && rm pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
