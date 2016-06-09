#!/bin/bash
apt-get update
apt-get install -y python-dev                  # Required for psycopg2 drivers
apt-get install -y python3-dev                 # Required to build python3 stuff, like pillow
apt-get install -y python-setuptools           # Pip
apt-get install -y python-virtualenv           # Venv
apt-get install -y virtualenvwrapper           # Venv
apt-get install -y git                         # In order to pull/push from VM
apt-get install -y libevent-dev
apt-get install -y make                        # In order to use Makefile
apt-get install -y libpq-dev                   # Required for psycopg2 drivers
apt-get install -y libjpeg-dev                 # Required for pillow
apt-get install -y gcc                         # Required for pillow
#apt-get install -y nginx                       # A proper web server
#apt-get install -y build-essential             # Required for supervisord
#apt-get install -y supervisor                  # Run uwsgi in the background

# Upgrade virtualenv to latest version
sudo pip install virtualenv --upgrade

# If you wish you wish to have postgres installed
# apt-get install -y libpq-dev                   # Required for postgresql
# apt-get install -y postgresql                  # Postgresql
# apt-get install -y postgresql-contrib          # Postgresql

# Add vagrant user if it does not exist
id -u vagrant &>/dev/null || useradd vagrant --home /home/vagrant --shell /bin/bash