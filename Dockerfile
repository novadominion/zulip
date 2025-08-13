# Use Python 3.11 as base image
FROM python:3.11-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    # PostgreSQL client
    postgresql-client \
    libpq-dev \
    # Image processing
    libvips42 \
    libvips-dev \
    # LDAP support
    libldap2-dev \
    libsasl2-dev \
    # XML processing
    libxml2-dev \
    libxslt1-dev \
    # Other dependencies
    git \
    curl \
    ca-certificates \
    gettext \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libfreetype6-dev \
    # Required for node/npm
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Create zulip user and directories
RUN useradd -m -s /bin/bash zulip && \
    mkdir -p /srv/zulip /home/zulip/uploads /var/log/zulip && \
    chown -R zulip:zulip /srv/zulip /home/zulip/uploads /var/log/zulip

# Set working directory
WORKDIR /srv/zulip

# Copy package files first for better caching
COPY --chown=zulip:zulip package.json package-lock.json* pnpm-lock.yaml* ./
COPY --chown=zulip:zulip pyproject.toml uv.lock* ./

# Install Node dependencies
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile || npm install

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install uv && \
    uv pip install --system django==5.2.* && \
    uv pip install --system \
        asgiref \
        typing-extensions \
        jinja2 \
        markdown \
        pygments \
        jsx-lexer \
        uri-template \
        regex \
        ipython \
        pyvips \
        sqlalchemy==1.4.* \
        greenlet \
        boto3 \
        defusedxml \
        python-ldap \
        django-auth-ldap \
        django-bitfield \
        html2text \
        talon-core \
        css-inline \
        pyjwt \
        pika \
        psycopg2 \
        python-binary-memcached \
        django-bmemcached \
        python-dateutil \
        redis \
        tornado \
        orjson \
        polib \
        virtualenv-clone \
        beautifulsoup4 \
        lxml \
        python-magic \
        pytz \
        django-two-factor-auth \
        phonenumbers \
        django-cors-headers \
        django-redis \
        gunicorn \
        whitenoise

# Copy the entire application
COPY --chown=zulip:zulip . .

# Build frontend assets
RUN npm run build || echo "Frontend build skipped"

# Create necessary directories and set permissions
RUN mkdir -p /srv/zulip/static /srv/zulip/staticfiles && \
    chown -R zulip:zulip /srv/zulip

# Switch to zulip user
USER zulip

# Expose port
EXPOSE 8000

# Default command
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]