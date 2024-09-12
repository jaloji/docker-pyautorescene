FROM alpine:3.14
# After 3.14 unrar is not available and pyautorescene code don't work with setup.py and other things like this with more recent python version

# Install dependencies and create /app directory
RUN apk update && \
    apk add --no-cache python3 unzip wget ca-certificates py3-setuptools chromaprint build-base zlib-dev libgcc && \
	# Install and build unrar from source
    cd /tmp && \
	wget https://www.rarlab.com/rar/unrarsrc-7.0.9.tar.gz && \
	tar xzf unrarsrc-7.0.9.tar.gz && \
	cd unrar && \
    make && \
    make install && \
    cd / && \
	rm -rf /tmp/unrarsrc-7.0.9.tar.gz /tmp/unrar && \
    # Remove build dependencies to keep the image slim
    apk del build-base zlib-dev libgcc && \
    mkdir -p /app /app/rarv /app/rarv/tmp /input /output

# Set up pyrescene
WORKDIR /app
RUN wget https://github.com/srrDB/pyrescene/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cd pyrescene-master && \
    python3 setup.py install && \
    cd .. && \
    rm -rf master.zip # We don't delete them I want to try reconstruction of compressed RARs under linux

# Set up rarlinux and prepare RAR files
RUN wget https://github.com/dryes/rarlinux/archive/refs/heads/master.zip && \
    unzip master.zip && \
    python3 /app/pyrescene-master/bin/preprardir.py /app/rarlinux-master/ /app/rarv/ && \
	rm -rf master.zip && \
    sed -i 's|RAR_VERSION = ""|RAR_VERSION = "/app/rarv"|' /app/pyautorescene-master/utils/res.py && \
    sed -i 's|SRR_TEMP_FOLDER = f"{RAR_VERSION}\\\\tmp"|SRR_TEMP_FOLDER = f"{RAR_VERSION}/tmp"|' /app/pyautorescene-master/utils/res.py

# Be careful this will be IDs used before docker build you must reinstall again if you don't change them
ENV USER= \
    PASS= \
    UID=1000 \
    GID=1000

# Set up pyautorescene
RUN wget https://github.com/jaloji/pyautorescene/archive/refs/heads/master.zip && \
    unzip master.zip && \
    sed -i "s/USERNAME = \"\"/USERNAME=\"$USER\"/" /app/pyautorescene-master/utils/res.py && \
    sed -i "s/PASSWORD = \"\"/PASSWORD=\"$PASS\"/" /app/pyautorescene-master/utils/res.py && \
    cd pyautorescene-master && \
    python3 setup.py install && \
    cd .. && \
    rm -rf master.zip # We don't delete them I want to try reconstruction of compressed RARs under linux

RUN mkdir -p /input /output

# Uncomment for single use
#CMD ["autorescene.py", "-vaf", "-o", "/output/", "/input/"]
