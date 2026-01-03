# Building Seafile Server with PostgreSQL on openSUSE

This guide provides step-by-step instructions for building Seafile Server with PostgreSQL support on openSUSE.

## Prerequisites

### Install Required Development Packages

```bash
sudo zypper install -y \
    gcc \
    g++ \
    make \
    automake \
    autoconf \
    libtool \
    pkg-config \
    git \
    vala \
    libuuid-devel \
    libevent-devel \
    libjansson-devel \
    sqlite3-devel \
    zlib-devel \
    glib2-devel \
    libarchive-devel \
    libcurl-devel \
    openssl-devel \
    postgresql-devel \
    postgresql-server \
    libargon2-devel \
    argon2-devel \
    hiredis-devel \
    fuse-devel \
    oniguruma-devel
```

### Install Seafile-Specific Dependencies

You'll need to build and install these dependencies from source:

#### 1. libsearpc

```bash
git clone https://github.com/haiwen/libsearpc.git
cd libsearpc
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
cd ..
```

#### 2. libjwt

```bash
git clone https://github.com/benmcollins/libjwt.git
cd libjwt
autoreconf -i
./configure --prefix=/usr/local
make
sudo make install
cd ..
```

**Note:** Both libjwt v1.x and v3.x are compatible with Seafile. The v1.x API functions are maintained in v3.x for backward compatibility.

#### 3. libevhtp (required for HTTP server)

**Note:** libevhtp requires oniguruma (already in the package list above). You also need cmake:
```bash
sudo zypper install -y cmake
```

Then build libevhtp:
```bash
git clone https://github.com/haiwen/libevhtp.git
cd libevhtp
cmake -DEVHTP_DISABLE_SSL=OFF -DEVHTP_BUILD_SHARED=ON .
make
sudo make install
cd ..
```

If you get errors about missing onigposix.h, make sure oniguruma-devel is installed and rebuild libevhtp.

#### 4. Update library cache

```bash
sudo ldconfig
```

### Install Go (for fileserver)

```bash
# Download and install Go 1.22 or later
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
```

## Building Seafile Server

### 1. Clone the Repository

```bash
git clone https://github.com/haiwen/seafile-server.git
cd seafile-server
```

### 2. Generate Build Configuration

```bash
./autogen.sh
```

### 3. Configure with PostgreSQL Support

**Important:** The configure script includes a fix for lib64 paths on x86_64 systems where libjwt installs to `/usr/local/lib64`.

```bash
./configure \
    --with-postgresql \
    --prefix=/usr/local/seafile \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
```

**Configuration Options:**
- `--with-postgresql`: Enable PostgreSQL support
- `--with-mysql`: Enable MySQL support (can be used alongside PostgreSQL)
- `--prefix`: Installation directory (default: /usr/local)

### 4. Compile

```bash
make -j$(nproc)
```

### 5. Install

```bash
sudo make install
```

### 6. Build Go Fileserver

```bash
cd fileserver
go build -o seaf-fileserver
sudo cp seaf-fileserver /usr/local/seafile/bin/
cd ..
```

## PostgreSQL Database Setup

### 1. Initialize PostgreSQL (if not already done)

```bash
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### 2. Create Databases and User

```bash
sudo -u postgres psql <<EOF
CREATE USER seafile WITH PASSWORD 'your_password_here';
CREATE DATABASE ccnet OWNER seafile ENCODING 'UTF8';
CREATE DATABASE seafile OWNER seafile ENCODING 'UTF8';
CREATE DATABASE seahub OWNER seafile ENCODING 'UTF8';
GRANT ALL PRIVILEGES ON DATABASE ccnet TO seafile;
GRANT ALL PRIVILEGES ON DATABASE seafile TO seafile;
GRANT ALL PRIVILEGES ON DATABASE seahub TO seafile;
EOF
```

### 3. Initialize Database Schema

```bash
# Initialize ccnet database
sudo -u postgres psql -U seafile -d ccnet -f scripts/sql/postgresql/ccnet.sql

# Initialize seafile database
sudo -u postgres psql -U seafile -d seafile -f scripts/sql/postgresql/seafile.sql
```

## Configuration

### 1. Create Configuration Directory

```bash
mkdir -p /usr/local/seafile/conf
```

### 2. Create Configuration Files

#### conf/seafile.conf

```ini
[database]
type = postgresql
host = localhost
port = 5432
user = seafile
password = your_password_here
db_name = seafile
max_connections = 100

[network]
port = 12001

[fileserver]
port = 8082
host = 0.0.0.0
```

#### conf/ccnet.conf

```ini
[General]
SERVICE_URL = http://your-server-ip:8000
PORT = 10001

[Database]
ENGINE = pgsql
HOST = localhost
PORT = 5432
USER = seafile
PASSWD = your_password_here
DB = ccnet
```

## Running Seafile Server

### 1. Start Seafile Server

```bash
/usr/local/seafile/bin/seaf-server -c /usr/local/seafile/conf -d /usr/local/seafile/seafile-data
```

### 2. Start Fileserver

```bash
/usr/local/seafile/bin/seaf-fileserver -c /usr/local/seafile/conf -d /usr/local/seafile/seafile-data
```

## Troubleshooting

### Library Not Found Errors

If you encounter library errors, add the library path:

```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
sudo ldconfig
```

### PostgreSQL Connection Issues

1. Check PostgreSQL is running:
```bash
sudo systemctl status postgresql
```

2. Verify database access:
```bash
psql -h localhost -U seafile -d ccnet -c "SELECT 1;"
```

3. Check PostgreSQL authentication in `/var/lib/pgsql/data/pg_hba.conf`:
```
# Add this line if needed
host    all             seafile         127.0.0.1/32            md5
```

Then restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### Build Errors

If configure fails to find packages, ensure `PKG_CONFIG_PATH` is set:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
./configure --with-postgresql --prefix=/usr/local/seafile
```

## Systemd Service Files (Optional)

### /etc/systemd/system/seafile.service

```ini
[Unit]
Description=Seafile Server
After=network.target postgresql.service

[Service]
Type=forking
ExecStart=/usr/local/seafile/bin/seaf-server -c /usr/local/seafile/conf -d /usr/local/seafile/seafile-data
User=seafile
Group=seafile
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### /etc/systemd/system/seafile-fileserver.service

```ini
[Unit]
Description=Seafile Fileserver
After=network.target seafile.service

[Service]
Type=simple
ExecStart=/usr/local/seafile/bin/seaf-fileserver -c /usr/local/seafile/conf -d /usr/local/seafile/seafile-data
User=seafile
Group=seafile
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start services:

```bash
sudo systemctl daemon-reload
sudo systemctl enable seafile seafile-fileserver
sudo systemctl start seafile seafile-fileserver
```

## Verification

Check that all services are running:

```bash
sudo systemctl status postgresql
sudo systemctl status seafile
sudo systemctl status seafile-fileserver
```

Check database connectivity:

```bash
psql -h localhost -U seafile -d seafile -c "SELECT COUNT(*) FROM Repo;"
```

## Additional Resources

- Seafile Manual: https://manual.seafile.com/
- Seafile Forum: https://forum.seafile.com
- PostgreSQL Documentation: https://www.postgresql.org/docs/

## Notes

- This build includes full PostgreSQL support via libpq
- Connection pooling is enabled by default
- SSL/TLS support for PostgreSQL can be configured in the connection string
- The Go fileserver has been updated to support PostgreSQL alongside MySQL
