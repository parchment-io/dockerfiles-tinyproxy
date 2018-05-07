FROM frolvlad/alpine-gcc
RUN apk update && apk add bash gcc git automake autoconf make
RUN mkdir /usr/src && cd /usr/src && git clone https://github.com/tinyproxy/tinyproxy.git
RUN printf "#!/bin/sh\nexit 0" > /bin/a2x && ln -s /bin/true /bin/applet && \
    touch /usr/src/tinyproxy/docs/man5/tinyproxy.conf.5 && \
    touch /usr/src/tinyproxy/docs/man8/tinyproxy.8
RUN CFLAGS='--static' cd /usr/src/tinyproxy && \
      ./autogen.sh && \
      ./configure --enable-xtinyproxy --enable-upstream --enable-transparent --enable-reverse && \
      make && \
      make install
RUN mv /usr/local/etc/tinyproxy /etc/tinyproxy
RUN cp /usr/src/tinyproxy/.git/refs/heads/master /.commit
RUN apk del gcc git automake autoconf make m4 perl libssh2 libcurl expat pcre2
RUN sed -i 's/nogroup/nobody/' /etc/group
COPY strip-docker-image-export /
ENTRYPOINT ["/usr/local/bin/tinyproxy"]
CMD ["-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]
