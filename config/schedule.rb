# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Default to 5:00 PM if not set
require "yaml"
config = YAML.load_file("config/export.yml")[ENV["RAILS_ENV"] || "development"]
run_time = config["run_time"] || "5:00 pm"
puts "Current export run time: #{run_time}"
puts "Current Rails environment: #{ENV['RAILS_ENV'] || 'development'}"

set :output, "log/cron.log"
every 1.day, at: run_time do
  rake "payments:export"
end
