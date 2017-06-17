FROM ruby:2.4.1

ADD . /srv
WORKDIR /srv

RUN bundle install

EXPOSE 4567

CMD ["ruby", "app.rb"]
