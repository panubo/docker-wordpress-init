# Wordpress Init for Docker

This generates the required _static_ environment variables to bootstrap a new Wordpress install
and creates a corresponding MySQL user and database.

See [Wordpress Example](https://github.com/voltgrid/voltgrid-wordpress-example).

## Usage

```
docker run -e APP_CODE=<code> quay.io/panubo/wordpress-init <output> --sleep
```

## Status

Work in progress.
