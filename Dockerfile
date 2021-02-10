FROM frolvlad/alpine-gcc AS build
RUN apk update && apk add bash gcc git automake autoconf make && \
  mkdir /usr/src && cd /usr/src && git clone https://github.com/tinyproxy/tinyproxy.git && \
  touch /usr/src/tinyproxy/docs/man5/tinyproxy.conf.5 && \
  touch /usr/src/tinyproxy/docs/man8/tinyproxy.8 && \
  CFLAGS='--static' cd /usr/src/tinyproxy && \
    ./autogen.sh && \
    ./configure --enable-xtinyproxy --enable-upstream --enable-transparent --enable-reverse && \
    make && \
    make install

FROM alpine
RUN sed -i 's/nogroup/nobody/' /etc/group && \
  printf "#!/bin/sh\nexit 0" > /bin/a2x && ln -s /bin/true /bin/applet
COPY --from=build /usr/src/tinyproxy/.git/refs/heads/master /.commit
COPY --from=build /usr/local/etc/tinyproxy /etc/tinyproxy
COPY --from=build /usr/local/bin/tinyproxy /usr/local/bin/
RUN apk update && apk add curl && sed -E -i 's/^Port 8888/Port 8080/' /etc/tinyproxy/tinyproxy.conf
ENTRYPOINT ["/usr/local/bin/tinyproxy"]
CMD ["-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]
HEALTHCHECK --start-period=60s CMD ["/bin/sh", "-c", "if [ $(curl --resolve tinyproxy.stats:8080:127.0.0.1 -s -o /dev/null -w \"%{http_code}\" http://tinyproxy.stats:8080) = 200 ]; then exit 0; else exit 1; fi"]
