# syntax=docker/dockerfile:1.7

# renovate: datasource=github-releases depName=anomalyco/opencode
ARG OPENCODE_VERSION=1.18.4

FROM alpine:3.21 AS download
ARG OPENCODE_VERSION
ARG TARGETARCH
RUN apk add --no-cache curl tar
WORKDIR /tmp/opencode
# arm64 releases have no "baseline" variant; x64 uses baseline for widest CPU compat
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) ASSET="opencode-linux-x64-baseline-musl" ;; \
      arm64) ASSET="opencode-linux-arm64-musl" ;; \
      *) echo "unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o opencode.tar.gz \
      "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/${ASSET}.tar.gz"; \
    tar -xzf opencode.tar.gz; \
    chmod +x opencode

FROM alpine:3.21
ARG OPENCODE_VERSION
LABEL org.opencontainers.image.title="opencode-k8s" \
      org.opencontainers.image.description="opencode web UI server for Kubernetes" \
      org.opencontainers.image.version="${OPENCODE_VERSION}"

RUN apk add --no-cache \
      libgcc libstdc++ ripgrep ca-certificates \
      git openssh-client curl tzdata

COPY --from=download /tmp/opencode/opencode /usr/local/bin/opencode
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/restart-opencode.sh /usr/local/bin/restart-opencode
# Baked outside $HOME because the PVC shadows /home/opencode; entrypoint copies
# these into ~/.config/opencode/commands/ at startup.
COPY docker/commands/ /usr/local/share/opencode/commands/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/restart-opencode \
 && opencode --version

RUN addgroup -g 1000 opencode \
 && adduser -D -u 1000 -G opencode -h /home/opencode opencode

ENV HOME=/home/opencode \
    OPENCODE_DISABLE_AUTOUPDATE=true \
    BUN_RUNTIME_TRANSPILER_CACHE_PATH=0

USER opencode
WORKDIR /home/opencode
EXPOSE 4096

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["serve", "--hostname", "0.0.0.0", "--port", "4096"]
