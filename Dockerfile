FROM ruby:2.6.5
ENV APP_HOME /app/
ENV LIB_DIR lib/warden/cognito/
RUN mkdir -p $APP_HOME/$LIB_DIR
WORKDIR $APP_HOME
COPY Gemfile *gemspec $APP_HOME
COPY $LIB_DIR/version.rb $APP_HOME/$LIB_DIR
RUN bundle install
