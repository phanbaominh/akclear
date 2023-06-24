set -o errexit

bundle install
npm install
bundle exec rake fetch_latest_game_data:all
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate