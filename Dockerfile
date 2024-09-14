FROM debian:bullseye-slim
# I just don't understand anything about all of these fucking "slim-image"
# WinRAR binaries aren't compatible with Alpine and pyautorescene code don't work with setup.py and other things like this with more recent python version

# Install dependencies and Python 3.9
RUN dpkg --add-architecture i386 && \
    apt-get update && \
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
	# We need 32 bit binaries for some RAR version 
        libc6-i386 \
	libstdc++5 \
	libstdc++5:i386 \
        lib32stdc++6 \
        lib32z1 \
        lib32ncurses6 \
	# We need this for srs .NET 1.2 
	mono-complete \
        && \
    apt-get clean && \
    # We need this for very old RAR version 
    wget http://archive.debian.org/debian/pool/main/g/gcc-2.95/libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    dpkg -i libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf libstdc++2.10-glibc2.2_2.95.4-27_i386.deb && \
    mkdir -p /app /app/rarv /app/rarv/tmp /input /output

WORKDIR /app

# YOU NEED TO EDIT THIS WITH YOURS

RUN USER="" && \
    PASS="" && \
    RAR="/app/rarv" && \ 
    TEMP="/tmp" && \
    # 1 - Install unrar from source
    wget https://www.rarlab.com/rar/unrarsrc-7.0.9.tar.gz && \
    tar xzf unrarsrc-7.0.9.tar.gz && \
    cd unrar && \
    make && \
    make install && \
    cd .. && \
    # Clean up build dependencies
    apt-get remove --purge -y \
        build-essential \
        zlib1g-dev \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /app/unrarsrc-7.0.9.tar.gz /app/unrar  && \
    # 2 - Set up pyrescene
    # wget https://github.com/srrDB/pyrescene/archive/refs/heads/master.zip && \
    wget https://github.com/srrDB/pyrescene/archive/refs/heads/bugfix/issue-19.zip && \
    unzip issue-19.zip && \
    cd pyrescene-bugfix-issue-19 && \
    python3 setup.py install && \
    cd .. && \
    rm -rf issue-19.zip && \
    # 3 - Set up rarlinux
    wget https://github.com/jaloji/rarlinux/archive/refs/heads/master.zip && \
    unzip -o master.zip && \
    # More version avaiblable with x86
    python3 /app/pyrescene-bugfix-issue-19/bin/preprardir.py -b /app/rarlinux-master/x86 /app/rarv/ && \
    rm -rf master.zip && \
    # 4 - Set up pyautorescene
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

# YES WE DONT ADDUSER ADDSHIT 
# I don't give a shit about docker rules its pissed me off to delete them to update this docker when something wrong 
# If you want them FORK IT !

ENV UID=1000 \
    GID=1000

# Set working directory and user
WORKDIR /input

# Uncomment for single use
#CMD ["autorescene.py", "-vaf", "-o", "/output/", "/input/"]
