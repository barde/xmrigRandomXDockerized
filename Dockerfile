# Build: 
# docker build -t xmrig .
#
# Set docker max memory to 3GB
# Run:
# docker run -it -m=3g xmrig
#
FROM alpine:edge as buildmachine

RUN apk --no-cache upgrade && \
    apk --no-cache add hwloc hwloc-dev --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ && \
    apk add --no-cache git cmake linux-headers libuv-dev openssl-dev libuv build-base automake libtool autoconf wget

RUN git clone https://github.com/xmrig/xmrig.git

# change to 0% donation
RUN sed -i 's/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/g' xmrig/src/donate.h

# build deps for static compile
RUN cd xmrig/scripts && ./build_deps.sh

RUN mkdir xmrig/build && cd xmrig/build && cmake .. -DXMRIG_DEPS=scripts/deps && make -j$(nproc)

# runtime
FROM alpine:edge

ADD config.json .
COPY --from=buildmachine /xmrig/build/xmrig .

ENV XMRIG_USER="3LUvVmhHLLZBSaprdSZYSBFnBu7ybZg7nh"

CMD sh -c 'sed -i 's/3LUvVmhHLLZBSaprdSZYSBFnBu7ybZg7nh/${XMRIG_USER}/g' ./config.json && ./xmrig'
