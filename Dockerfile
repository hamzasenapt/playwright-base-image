FROM eclipse-temurin:22-jdk

ARG PLAYWRIGHT_VERSION
ARG CHROMIUM_VERSION
ARG TARGETARCH

# Install required dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    xvfb \
    unzip \
    ca-certificates \
    fonts-liberation \
    libasound2t64 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    libu2f-udev \
    libvulkan1 \
    libxss1 \
    libxshmfence1 \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /ms-playwright/chromium-${CHROMIUM_VERSION}

# Download and install browser based on architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        BROWSER_URL="https://playwright.azureedge.net/builds/chromium/${CHROMIUM_VERSION}/chromium-linux.zip"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        BROWSER_URL="https://playwright.azureedge.net/builds/chromium/${CHROMIUM_VERSION}/chromium-linux-arm64.zip"; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    cd /ms-playwright/chromium-${CHROMIUM_VERSION} && \
    wget --no-check-certificate --tries=5 --retry-connrefused --waitretry=1 --timeout=20 $BROWSER_URL -O chromium-linux.zip && \
    unzip chromium-linux.zip && \
    rm chromium-linux.zip && \
    chmod +x chrome-linux/chrome

# Set environment variables
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_GC=1
ENV DISPLAY=:99

# Create a non-root user
RUN useradd -m playwright && \
    chown -R playwright:playwright /ms-playwright

USER playwright
WORKDIR /app 