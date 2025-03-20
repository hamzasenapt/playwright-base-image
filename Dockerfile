FROM --platform=$TARGETPLATFORM eclipse-temurin:22-jdk

# Install Playwright dependencies
RUN apt-get update && apt-get install -y \
    xvfb \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    libxtst6 \
    libnss3 \
    libcups2 \
    libxss1 \
    libxrandr2 \
    libasound2t64 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set up Playwright environment variables
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_SKIP_BROWSER_GC=1
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV DISPLAY=:99

# Create directories and set permissions
RUN mkdir -p /ms-playwright/chromium-1105/chrome-linux && \
    chmod -R 777 /ms-playwright

# Download and install Playwright browser based on architecture
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        BROWSER_URL="https://playwright.azureedge.net/builds/chromium/1105/chromium-linux.zip"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        BROWSER_URL="https://playwright.azureedge.net/builds/chromium/1105/chromium-linux-arm64.zip"; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    wget -q $BROWSER_URL && \
    unzip -q chromium-linux*.zip -d /ms-playwright/chromium-1105/chrome-linux/ && \
    rm chromium-linux*.zip && \
    chmod -R 777 /ms-playwright

# Create a non-root user
RUN useradd -m -s /bin/bash playwright-user && \
    chown -R playwright-user:playwright-user /ms-playwright

# Switch to non-root user
USER playwright-user

# Set working directory
WORKDIR /app 