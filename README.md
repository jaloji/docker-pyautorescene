# docker-pyautorescene

Requirements
------------
Be careful to change your Srrdb IDs before docker build or you will need to edit /app/pyautorescene-master/utils/res.py manualy inside the docker and run python3 setup.py install again.

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
#CMD autorescene.py -vaf -o /output/ /input/
```
Or since pyautorescene have upload script.
```
#CMD ["srrup.py", "/srr"]
```
Or you can leave it like that and do this command to use it as the inital script:
```
docker exec -ti docker-pyautorescene /bin/bash
```

WinRAR binaries seem to not being compatible with Alpine:
```
/app/rarv # ldd /app/rarv/2014-06-10_rar510
        /lib64/ld-linux-x86-64.so.2 (0x56367939e000)
        libstdc++.so.6 => /usr/lib/libstdc++.so.6 (0x7f73bca13000)
        libm.so.6 => /lib64/ld-linux-x86-64.so.2 (0x56367939e000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x7f73bc9f9000)
        libpthread.so.0 => /lib64/ld-linux-x86-64.so.2 (0x56367939e000)
        libc.so.6 => /lib64/ld-linux-x86-64.so.2 (0x56367939e000)
Error relocating /app/rarv/2014-06-10_rar510: __swprintf_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __vfwprintf_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __strncpy_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __vswprintf_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __memcpy_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __strcat_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __wcscpy_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __wcscat_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __wcsncpy_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __strcpy_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __open64_2: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __memset_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __sprintf_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __memmove_chk: symbol not found
/app/rarv # ./2014-06-10_rar510 
Error relocating /app/rarv/2014-06-10_rar510: __wcscat_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __wcsncpy_chk: symbol not found
/app/rarv # apk add --no-cache gcompat
fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
OK: 133 MiB in 100 packages
/app/rarv # ./2014-06-10_rar510 
Error relocating /app/rarv/2014-06-10_rar510: __wcscat_chk: symbol not found
Error relocating /app/rarv/2014-06-10_rar510: __wcsncpy_chk: symbol not found
```
