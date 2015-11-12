# Wordpress Init for Docker

[![Docker Repository on Quay](https://quay.io/repository/panubo/wordpress-init/status "Docker Repository on Quay")](https://quay.io/repository/panubo/wordpress-init)

This generates the required _static_ environment variables to bootstrap a new Wordpress install
and creates a corresponding MySQL user and database.

The variables this generates and accepts are as defined in the
[Wordpress Example](https://github.com/voltgrid/voltgrid-wordpress-example) project.

Any unrecognised variables will be discarded.

## Usage

```
docker run -e APP_CODE=<code> quay.io/panubo/wordpress-init <output> --sleep
```

## Status

Work in progress.
