FROM debian:bullseye-slim
# I just don't understand anything about all of these fucking "slim-image"
# WinRAR binaries aren't compatible with Alpine and pyautorescene code don't work with setup.py and other things like this with more recent python version

# Install dependencies and Python 3.9
RUN apt-get update && \
    apt-get install -y \
        wget \
        unzip \
        ca-certificates \
        build-essential \
        zlib1g-dev \
        libstdc++6 \
        libgcc-s1 \
        python3.9 \
        python3.9-distutils \
        python3.9-venv \
        python3-pip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /app /app/rarv /app/rarv/tmp /input /output

# Install unrar from source
RUN wget https://www.rarlab.com/rar/unrarsrc-7.0.9.tar.gz && \
    tar xzf unrarsrc-7.0.9.tar.gz && \
    cd unrar && \
    make && \
    make install && \
    cd .. && \
    rm -rf unrarsrc-7.0.9.tar.gz unrar

# Set up pyrescene
WORKDIR /app
RUN wget https://github.com/srrDB/pyrescene/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cd pyrescene-master && \
    python3 setup.py install && \
    cd .. && \
    rm -rf master.zip

# Set up rarlinux
RUN wget https://github.com/dryes/rarlinux/archive/refs/heads/master.zip && \
    unzip -o master.zip && \
    python3 /app/pyrescene-master/bin/preprardir.py -b /app/rarlinux-master/ /app/rarv/ && \
	rm -rf master.zip

ENV UID=1000 \
    GID=1000

# YES WE DONT ADDUSER ADDSHIT 
# I don't give a shit about docker rules its pissed me off to delete them to update this docker when something wrong 
# If you want them FORK IT !

# Set up pyautorescene
# You need to edit this with yours
RUN USER="" && \
    PASS="" && \
    RAR="" && \ 
    TEMP="" && \
	wget https://github.com/jaloji/pyautorescene/archive/refs/heads/master.zip && \
    unzip -o master.zip && \
    cd pyautorescene-master && \
	sed -i 's%RAR_VERSION = "".*%RAR_VERSION = "'"$RAR"'"%' /app/pyautorescene-master/utils/res.py && \
	sed -i 's%SRR_TEMP_FOLDER = f"{RAR_VERSION}"%SRR_TEMP_FOLDER = f"{RAR_VERSION}'"$TEMP"'"%' /app/pyautorescene-master/utils/res.py && \
    sed -i "s/USERNAME = \"\"/USERNAME=\"$USER\"/" /app/pyautorescene-master/utils/res.py && \
    sed -i "s/PASSWORD = \"\"/PASSWORD=\"$PASS\"/" /app/pyautorescene-master/utils/res.py && \
    python3 setup.py install && \
    cd .. && \
    rm -rf master.zip
	
# Set working directory and user
WORKDIR /input

# Uncomment for single use
#CMD ["autorescene.py", "-vaf", "-o", "/output/", "/input/"]
