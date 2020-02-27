# Sources API

[![Build Status](https://travis-ci.org/RedHatInsights/sources-api.svg?branch=master)](https://travis-ci.org/RedHatInsights/sources-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/bc0595445f017018ffbc/maintainability)](https://codeclimate.com/github/RedHatInsights/sources-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bc0595445f017018ffbc/test_coverage)](https://codeclimate.com/github/RedHatInsights/sources-api/test_coverage)
[![Security](https://hakiri.io/github/RedHatInsights/sources-api/master.svg)](https://hakiri.io/github/RedHatInsights/sources-api/master)

This project exposes an API for accessing objects living in the Sources Service database

## Prerequisites
You need to install ruby >= 2.5 and run:

```
bundle install
```

## Getting started

Setup your database configuration
```
config/database.dev.yml config/database.yml
```

Then edit the file to setup your postgres info

Next create the database
```
bin/rake db:create db:migrate
bin/rails s
```

To list all your routes, use:

```
bin/rake routes
```

Start your server:
```
bin/rails s
```

This will use kafka by default to send updates for created/updated/deleted actions.  It uses localhost:9092 by default but this can be changed by passing `QUEUE_HOST=` and/or `QUEUE_PORT=`.  To disable kafka updates pass `NO_KAFKA=true`.

## License

This project is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).
