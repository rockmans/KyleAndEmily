echo $WORKSPACE
export PROJECT_NAME=kyleandemily
export APP_VERSION=`git rev-parse HEAD | cut -c -12`
export VENV_VERSION=`sha1sum ./requirements.txt | cut -c -12`
export ROOT="/usr/local/$PROJECT_NAME"
export APP_DIR="$ROOT/app_versions/$APP_VERSION"
export VENV_DIR="$ROOT/venv_versions/$VENV_VERSION"
export TEST_APP_DIR="$ROOT/app_test"
export ACTIVE_APP_DIR="$ROOT/app_prod"
export ACTIVE_VENV_DIR="$ROOT/app_venv"
export MEDIA_DIR="$ROOT/media"
export DB_DIR="$ROOT/db"

mkdir -p "$MEDIA_DIR"
mkdir -p "$DB_DIR"

if [[ ! -e "$APP_DIR" ]]
then
  mkdir -p "$APP_DIR"
  cp -rv "./." "$APP_DIR"
fi

if [[ ! -e "$VENV_DIR/bin/activate" ]]
then
  virtualenv "$VENV_DIR"
  . "$VENV_DIR/bin/activate"
  pip install -r "./requirements.txt"
else
  . "$VENV_DIR/bin/activate"
fi

ln -snf "$APP_DIR" "$TEST_APP_DIR"
cd "$TEST_APP_DIR"
python manage.py collectstatic --noinput
python manage.py migrate --noinput

ln -snf "$APP_DIR" "$ACTIVE_APP_DIR"
ln -snf "$VENV_DIR" "$ACTIVE_VENV_DIR"

cp -f "$WORKSPACE/jenkins/nginx.conf" "/etc/nginx/sites-enabled/$PROJECT_NAME.conf"
cp -f "$WORKSPACE/jenkins/uwsgi.ini" "/usr/local/uwsgi/confs/$PROJECT_NAME.ini"
