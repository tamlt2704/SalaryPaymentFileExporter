FROM bitnami/rails:8.0.2

RUN install_packages cron 

# Set working directory
WORKDIR /app

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install


# Copy rest of the app
COPY . .

# Update crontab using whenever
RUN bundle exec whenever --update-crontab

# Precompile assets (optional for production)
# RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0"]
