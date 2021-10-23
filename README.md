# docker-pyautorescene

Requirements
------------
Be careful to change your Srrdb IDs before docker build or you will need to edit /app/pyautorescene-master/bin/autorescene.py manualy inside the docker and run python3 setup.py install again. Compressed RARs will doesn't work with this tool. You need to run my fork pyautorescene script under Windows.

Installation
-----

```
docker build -t docker-pyautorescene .
```

Usage
-----
To run this container the first time, you'll need to run command similar to:

```
docker run -i -e UID=1000 -e GID=1000 -v /path/with/input/files:/input -v /path/to/rescene:/output
```
Be careful about UID/GID you must use a machine user with read/write rights on dirs used.

You can uncomment this line in the Dockerfile if you just want a single use or you can put other parameters.
```
#CMD autorescene.py -va --find-sample -o /output/ /input/
```
Or you can leave it like that and do this command to use it as the inital script:
```
docker exec -ti docker-pyautorescene /bin/sh
```
