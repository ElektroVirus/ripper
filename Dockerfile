FROM debian:buster

RUN apt-get update \
  && apt-get install -y cdrdao python-gobject-2 python-musicbrainzngs python-mutagen python-setuptools \
  python-cddb python-requests libsndfile1-dev flac sox git \
  libiso9660-dev python-pip swig make pkgconf \
  eject locales \
  autoconf libtool curl \
  && pip install pycdio==2.0.0

# libcdio-paranoia / libcdio-utils are wrongfully packaged in Debian, thus built manually
# see https://github.com/whipper-team/whipper/pull/237#issuecomment-367985625
RUN curl -o - 'https://ftp.gnu.org/gnu/libcdio/libcdio-2.0.0.tar.gz' | tar zxf - \
  && cd libcdio-2.0.0 \
  && autoreconf -fi \
  && ./configure --disable-dependency-tracking --disable-cxx --disable-example-progs --disable-static \
  && make install \
  && cd .. \
  && rm -rf libcdio-2.0.0

# Install cd-paranoia from tarball
RUN curl -o - 'https://ftp.gnu.org/gnu/libcdio/libcdio-paranoia-10.2+0.94+2.tar.gz' | tar zxf - \
  && cd libcdio-paranoia-10.2+0.94+2 \
  && autoreconf -fi \
  && ./configure --disable-dependency-tracking --disable-example-progs --disable-static \
  && make install \
  && cd .. \ 
  && rm -rf libcdio-paranoia-10.2+0.94+2

RUN ldconfig

# add user
RUN useradd -m worker -G cdrom \
  && mkdir -p /output /home/worker/.config/whipper /home/worker/.local/share/whipper/plugins \
  && chown worker: /output /home/worker/.config/whipper /home/worker/.local/share/whipper/plugins
VOLUME ["/home/worker/.config/whipper", "/output"]

# setup locales + cleanup
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && locale-gen en_US.UTF-8 \
  && apt-get clean && apt-get autoremove -y

# install whipper
RUN mkdir /whipper && git clone https://github.com/whipper-team/whipper /whipper
RUN cd /whipper/src && make && make install \
  && cd /whipper && python2 setup.py install

# install eac logger
RUN git clone https://github.com/whipper-team/whipper-plugin-eaclogger.git /whipper/whipper-plugin-eaclogger \
  && cd /whipper/whipper-plugin-eaclogger \
  && python2 setup.py bdist_egg \
  && cp dist/whipper_plugin_eaclogger*.egg /home/worker/.local/share/whipper/plugins/ \
  && cd \
  && rm -rf /whipper

RUN whipper -v

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US
ENV LANGUAGE=en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

USER worker
WORKDIR /output
ENTRYPOINT ["whipper"]
