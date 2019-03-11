# Sources API

[![Build Status](https://travis-ci.org/ManageIQ/sources-api.svg)](https://travis-ci.org/ManageIQ/sources-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/47776e67dbb7cc572c3b/maintainability)](https://codeclimate.com/github/ManageIQ/sources-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/47776e67dbb7cc572c3b/test_coverage)](https://codeclimate.com/github/ManageIQ/sources-api/test_coverage)
[![Security](https://hakiri.io/github/ManageIQ/sources-api/master.svg)](https://hakiri.io/github/ManageIQ/sources-api/master)

This project exposes an API for accessing objects living in the Topological Inventory Service database

## Prerequisites
You need to install ruby >= 2.2.2 and run:

```
bundle install
```

## Getting started

```
bin/rake db:create db:migrate
bin/rails s
```

To list all your routes, use:

```
bin/rake routes
```

## License

This project is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).
