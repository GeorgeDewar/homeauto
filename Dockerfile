FROM datacom/ruby:2.1.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update                    # 2014-08-04
RUN apt-get -y install libpq-dev

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
RUN bundle install --system

ADD . /usr/src/app
RUN rake assets:precompile

