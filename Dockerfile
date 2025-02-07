# Duplicated from https://github.com/cytopia/docker-phpcs
# but using PHPCSStandards/PHP_CodeSniffer instead of
# abandoned squizlabs/PHP_CodeSniffer.

ARG PHP_IMG_TAG=cli-alpine
FROM php:${PHP_IMG_TAG} AS builder

# Install build dependencies
RUN set -eux \
	&& apk add --no-cache \
		ca-certificates \
		# coreutils add 'sort -V'
		coreutils \
		curl \
		git \
	&& git clone https://github.com/PHPCSStandards/PHP_CodeSniffer

ARG PCS_VERSION=latest
RUN set -eux \
	&& cd PHP_CodeSniffer \
	&& if [ "${PCS_VERSION}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="$( git tag | grep -E "^v?${PCS_VERSION}\.[.0-9]+\$" | sort -V | tail -1 )"; \
	fi \
	&& echo "Version: ${VERSION}" \
	&& curl -sS -L https://github.com/PHPCSStandards/PHP_CodeSniffer/releases/download/${VERSION}/phpcs.phar -o /phpcs.phar \
	&& chmod +x /phpcs.phar \
	&& mv /phpcs.phar /usr/bin/phpcs \
	\
	&& phpcs --version


ARG PHP_IMG_TAG=cli-alpine
FROM php:${PHP_IMG_TAG} AS production

COPY --from=builder /usr/bin/phpcs /usr/bin/phpcs
ENV WORKDIR /data
WORKDIR /data

ENTRYPOINT ["phpcs"]
CMD ["--version"]
