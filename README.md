
[![Publish Encrypted Execution Tools](https://github.com/encrypted-execution/php/actions/workflows/build-tools-publish.yml/badge.svg)](https://github.com/encrypted-execution/php/actions/workflows/build-tools-publish.yml)

[![Publish 8.4 Apache on Debian Bookworm](https://github.com/encrypted-execution/php/actions/workflows/8.4-apache-publish.yml/badge.svg)](https://github.com/encrypted-execution/php/actions/workflows/8.4-apache-publish.yml)

# Encrypted Execution PHP

This is a fork of the Docker PHP demonstrating how [Encrypted Execution](https://encrypted-execution.com) can be applied to PHP, and consumed seamlessly by PHP users or even hosters.

# How to use:

To just kick the tires:
```
docker run -it -p 8080:80 -v ./php-test-site:/var/www ghcr.io/encrypted-execution/php-8.4--apache-debian  
```

More documentation coming soon.

# Development

1. All scrambling code is under `/encrypted-execution`
2. To produce a new PHP version (on whatever distro), you basically need to do the equivalent of:
    * Pick up that Distro+Webserver directory from upstream Docker PHP repo
    * Modify Dockerfile to import the Encrypted Execution builder image to get the tools
    * Right after building full-php, run the encrypter so that the Zend parser is scrambled
    * Rebuild. The incremental build should be fast (this is how we live-reencrypt running code so fast.)

# License

All modifications, patches, changes: when not automatically applicable under The PHP License for whatever reason, are granted under the Apache 2.0 License.

NOTE: Copyrights to all code is belong to Polyverse Corporation. This isn't a problem unless you want to relicense this.
