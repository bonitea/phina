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

ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME} \
    build_dir="/tmp/build/$PROJECT_NAME" \
    src_dir="/src/$PROJECT_NAME" \
    install_dir="/opt/$PROJECT_NAME"

ADD ./cmake "$src_dir/cmake/"
ADD ./extlib "$src_dir/extlib/"
ADD CMakeLists.txt "$src_dir/"
ADD ./src "$src_dir/src/"

# The actual build command.
RUN mkdir -p "$build_dir" \
 && cd "$build_dir" \
 && cmake \
      -DCMAKE_BUILD_TYPE=release \
      -DCMAKE_INSTALL_PREFIX:PATH="$install_dir" \
      "$src_dir" \
 && cmake --build "$build_dir" \
 && cmake --build "$build_dir" --target install

# Build and source directories are not used at runtime.
RUN rm -r "$build_dir" \
 && rm -r "$src_dir"

# Development packages are also not used at runtime.
RUN apk del \
      boost-dev \
      openssl-dev

ARG PORT
ENV PORT=$PORT
## # Expose is NOT supported by Heroku
## EXPOSE $PORT

# Use a non-root user during run time.
RUN adduser -D example
USER example

WORKDIR "$install_dir"
CMD bin/$PROJECT_NAME 0.0.0.0 $PORT . 1
