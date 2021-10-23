FROM alpine:3.14

RUN apk update
RUN apk add --no-cache python3 unrar unzip wget ca-certificates py3-setuptools chromaprint \
  && mkdir /app
WORKDIR /app
RUN wget https://github.com/srrDB/pyrescene/archive/refs/heads/master.zip \
  && unzip master.zip \
  && ( cd pyrescene-master \
  && python3 setup.py install ) \
  && rm -R master.zip pyrescene-master

# Be careful this will be IDs used before docker build you must reinstall again if you don't change them
ENV USERNAME=test
ENV PASSWORD=12345

RUN wget https://github.com/jaloji/pyautorescene/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd pyautorescene-master \
  && sed -i "s/username = \"\"/username=\""$USERNAME"\"/" /app/pyautorescene-master/bin/autorescene.py \
  && sed -i "s/password = \"\"/password=\""$PASSWORD"\"/" /app/pyautorescene-master/bin/autorescene.py \
  && python3 setup.py install

# Cleanup
RUN rm -R master.zip

# Create user
ENV UID=1000
ENV GID=1000

RUN addgroup -S appgroup && adduser -S app -G appgroup

RUN mkdir -p /input /output
WORKDIR /input/
# Run as user
USER app

# Uncomment for single use
#CMD autorescene.py -va --find-sample -o /output/ /input/