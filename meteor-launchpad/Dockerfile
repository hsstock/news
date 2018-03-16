FROM debian:jessie
MAINTAINER Jeremy Shimko <jeremy.shimko@gmail.com>

RUN groupadd -r node && useradd -m -g node node

# Default values for Meteor environment variables
ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000

EXPOSE 3000

ENV DEV_BUILD true

# Gosu
ENV GOSU_VERSION 1.10

# MongoDB
ENV MONGO_VERSION 3.4.10
ENV MONGO_MAJOR 3.4
ENV MONGO_PACKAGE mongodb-org

# PhantomJS
ENV PHANTOM_VERSION 2.1.1

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts
ENV METEOR_SETUP /opt/meteor/setup

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

COPY setup $METEOR_SETUP

# install base dependencies, build app, cleanup
RUN bash $BUILD_SCRIPTS_DIR/install-deps.sh && \
		bash $BUILD_SCRIPTS_DIR/post-install-cleanup.sh

# define all --build-arg options
ARG APT_GET_INSTALL
ENV APT_GET_INSTALL $APT_GET_INSTALL

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-8.9.0}

ARG INSTALL_MONGO
ENV INSTALL_MONGO ${INSTALL_MONGO:-true}

ARG INSTALL_PHANTOMJS
ENV INSTALL_PHANTOMJS ${INSTALL_PHANTOMJS:-true}

ARG INSTALL_GRAPHICSMAGICK
ENV INSTALL_GRAPHICSMAGICK ${INSTALL_GRAPHICSMAGICK:-true}

# optionally custom apt dependencies at app build time
RUN if [ "$APT_GET_INSTALL" ]; then apt-get update && apt-get install -y $APT_GET_INSTALL; fi

# optionally install Mongo or Phantom at app build time
RUN bash $BUILD_SCRIPTS_DIR/install-phantom.sh
#ONBUILD RUN bash $BUILD_SCRIPTS_DIR/install-mongo.sh
RUN bash $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh

# Node flags for the Meteor build tool
ARG TOOL_NODE_FLAGS
ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

RUN bash $BUILD_SCRIPTS_DIR/install-node.sh

RUN bash $BUILD_SCRIPTS_DIR/install-meteor1.sh

ONBUILD COPY . $APP_SOURCE_DIR
ONBUILD RUN bash $APP_SOURCE_DIR/build-meteor.sh

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]