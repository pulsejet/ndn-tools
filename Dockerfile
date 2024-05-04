# syntax=docker/dockerfile:1

ARG NDN_CXX_VERSION=latest
FROM ghcr.io/named-data/ndn-cxx-build:${NDN_CXX_VERSION} AS build

RUN apt-get install -Uy --no-install-recommends \
        libpcap-dev \
    && rm -rf /var/lib/apt/lists/*

ARG JOBS
RUN --mount=rw,target=/src <<EOF
    set -eux
    cd /src
    ./waf configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --sharedstatedir=/var
    ./waf build
    ./waf install
EOF


FROM ghcr.io/named-data/ndn-cxx-runtime:${NDN_CXX_VERSION} AS ndn-tools

COPY --link --from=build /usr/bin/ndnpeek /usr/bin/
COPY --link --from=build /usr/bin/ndnpoke /usr/bin/
COPY --link --from=build /usr/bin/ndncatchunks /usr/bin/
COPY --link --from=build /usr/bin/ndnputchunks /usr/bin/
COPY --link --from=build /usr/bin/ndnping /usr/bin/
COPY --link --from=build /usr/bin/ndnpingserver /usr/bin/
COPY --link --from=build /usr/bin/ndndump /usr/bin/
COPY --link --from=build /usr/bin/ndn-dissect /usr/bin/

ENV HOME=/config
VOLUME /config
VOLUME /run/nfd

ENTRYPOINT ["/bin/bash"]