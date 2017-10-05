# Use Alpine for its small size.
FROM alpine:latest

# Use GCC.
RUN apk update \
 && apk add --no-cache \
      binutils \
      cmake \
      make \
      libgcc \
      musl-dev \
      gcc \
      g++

# Beast depends on Boost and OpenSSL.
RUN apk add --no-cache \
      boost \
      boost-dev \
      openssl \
      openssl-dev

# Some settings to be used throughout dockerfile build times.
ARG PROJECT_NAME
ARG BUILD_DIR="/tmp/build/$PROJECT_NAME"
ARG SRC_DIR="/src/$PROJECT_NAME"
ARG INSTALL_DIR="/opt/$PROJECT_NAME"

# Copy source files into the Docker image.
COPY . "$SRC_DIR/"

# The actual build command.
RUN mkdir -p "$BUILD_DIR" \
 && cd "$BUILD_DIR" \
 && cmake \
      -DCMAKE_BUILD_TYPE=release \
      -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_DIR" \
      "$SRC_DIR" \
 && cmake --build "$BUILD_DIR" \
 && cmake --build "$BUILD_DIR" --target install

# Build and source directories are not used at runtime.
RUN rm -r "$BUILD_DIR" \
 && rm -r "$SRC_DIR"

# Development packages are also not used at runtime.
RUN apk del \
      boost-dev \
      openssl-dev

# Use a non-root user during run time.
RUN adduser -D example
USER example

# Default runtime environment variables attached to the new user.
# Project binary name.
ARG PROJECT_NAME
# Default port.
ARG PORT
# Add all variables using one single cache layer.
ENV \
  PROJECT_NAME=$PROJECT_NAME \
  PORT=$PORT

WORKDIR "$INSTALL_DIR"
CMD bin/$PROJECT_NAME 0.0.0.0 $PORT . 1
