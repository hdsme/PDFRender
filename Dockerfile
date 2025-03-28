# Stage 1: Builder
FROM python:3.11-alpine3.16 AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    openssl-dev \
    tzdata

# Set timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    echo "Asia/Ho_Chi_Minh" > /etc/timezone

# Set workdir
WORKDIR /workspace

# Copy source and dependencies
COPY . .

# Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Intermediate stage for wkhtmltopdf
FROM surnet/alpine-wkhtmltopdf:3.16.2-0.12.6-full AS wkhtmltopdf

# Stage 2: Runtime
FROM python:3.11-alpine3.16
LABEL maintainer="Hao Hoang"
LABEL service="PDFService"

# Install runtime dependencies for wkhtmltopdf, including fonts
RUN apk add --no-cache \
    openssl \
    tzdata \
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    libssl1.1 \
    ca-certificates \
    fontconfig \
    freetype \
    ttf-droid \
    ttf-freefont \
    ttf-liberation

# Copy wkhtmltopdf binary and shared library from the wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/libwkhtmltox.so /bin/

# Set timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    echo "Asia/Ho_Chi_Minh" > /etc/timezone

# Set workdir
WORKDIR /workspace

# Copy installed dependencies and application code from builder
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /workspace .

# Expose port
EXPOSE 80

# Default command
CMD ["python3", "manage.py"]