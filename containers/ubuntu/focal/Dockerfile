#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
# procps is very common in build systems, and is a reasonably small package
RUN apt-get install -y --no-install-recommends \
		bzr \
		git \
		libgit2-dev \
		mercurial \
		openssh-client \
		subversion \
		procps

RUN apt install -y \
	# Install System.Drawing native dependencies
	libc6-dev libgdiplus libx11-dev

RUN ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

RUN set -eux; \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
		# https://bugs.debian.org/929417
		tzdata \
	;

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
	fi

RUN rm -rf /var/lib/apt/lists/*
