#!/usr/bin/env bash
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
bin/rails db:migrate
echo "[render-build] Running database seeds"
RAILS_ENV=production bin/rails db:seed
echo "[render-build] Database seeds completed"
