#!/bin/bash

NAME="admin_app"                                  # Name of the application
DJANGODIR=/home/frappe/adminapp/adminapp             # Django project directory
SOCKFILE=/home/frappe/adminapp/supervisor/gunicorn.sock  # we will communicte using this unix socket
USER=frappe                                        # the user to run as
GROUP=frappe                                     # the group to run as
NUM_WORKERS=3                                     # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=adminapp.settings             # which settings file should Django use
DJANGO_WSGI_MODULE=adminapp.wsgi                     # WSGI module name

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source /home/frappe/adminapp/env/adminapp/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec /home/frappe/adminapp/env/adminapp/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --bind=unix:$SOCKFILE \
  --log-level=debug \
  --log-file=-\
  --timeout=10000
