# Poodle

![Release](https://github.com/datacite/poodle/workflows/Release/badge.svg) [![Maintainability](https://api.codeclimate.com/v1/badges/ddb43ea782a1f201edfc/maintainability)](https://codeclimate.com/github/datacite/poodle/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/ddb43ea782a1f201edfc/test_coverage)](https://codeclimate.com/github/datacite/poodle/test_coverage)

DataCite MDS API, enabling DOI and metadata registration. The application does not store any data internally, but uses the DataCite REST API as backend service.

For documentation, and for testing the API, please go to [DataCite Support](https://support.datacite.org/docs/mds-api-guide).

## Installation

Using Docker.

```
docker run -p 8035:80 datacite/poodle
```

You can now point your browser to `http://localhost:8035` and use the application.

By default the application connects to the DataCite test infrastructure.
Set the `API_URL` environment variable to connect to the DataCite production
infrastructure:

```
API_URL=https://api.datacite.org
```

## Development

We use Rspec for unit and acceptance testing:

```
bundle exec rspec
```

Follow along via [Github Issues](https://github.com/datacite/poddle/issues).

### Note on Patches/Pull Requests

- Fork the project
- Write tests for your new feature or a test that reproduces a bug
- Implement your feature or make a bug fix
- Do not mess with Rakefile, version or history
- Commit, push and make a pull request. Bonus points for topical branches.

## License

**Poodle** is released under the [MIT License](https://github.com/datacite/poodle/blob/master/LICENSE).
