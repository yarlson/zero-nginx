FROM nginx:1.27-alpine3.19

# Build argument for Zero version
ARG ZERO_VERSION=0.1.0

# Install necessary tools
RUN apk add --no-cache curl tar

# Detect architecture and set the appropriate value
RUN case $(uname -m) in \
        x86_64) ARCH="amd64" ;; \
        aarch64) ARCH="arm64" ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    echo "Detected architecture: $ARCH" && \
    curl -L https://github.com/yarlson/zero/releases/download/${ZERO_VERSION}/zero_${ZERO_VERSION}_linux_${ARCH}.tar.gz | tar xz -C /usr/local/bin

# Copy the entrypoint script
COPY 00-install-certificates.sh /docker-entrypoint.d

# Make the entrypoint script executable
RUN chmod +x /docker-entrypoint.d/00-install-certificates.sh
