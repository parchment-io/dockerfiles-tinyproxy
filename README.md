# tinyproxy Docker image

This image is compiled from [tinyproxy source's](https://github.com/tinyproxy/tinyproxy) master branch nightly (if changed) and with alpine as a base image and stripped as best as possible to generate a small image.

### Usage

By default, this image will run with the stock config file. If you wish to customize the config, mount your desired config at `/etc/tinyproxy/tinyproxy.conf`.

### Maintainer

Matt Kulka [mattlqx](https://github.com/mattlqx)
