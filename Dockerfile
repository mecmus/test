# Copyright (c) 2020-2021 Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause

FROM ubuntu:22.04 as build

RUN mkdir -p /opt/build && mkdir -p /opt/dist
RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl && \
  rm -rf /var/lib/apt/lists/*

# install cmake
RUN cd /opt/build && \
    curl -LO https://github.com/Kitware/CMake/releases/download/v3.26.2/cmake-3.26.2-linux-x86_64.sh && \
    mkdir -p /opt/dist//usr/local && \
    /bin/bash cmake-3.26.2-linux-x86_64.sh --prefix=/opt/dist//usr/local --skip-license




# cleanup
RUN rm -rf /opt/dist/usr/local/include && \
    rm -rf /opt/dist/usr/local/lib/pkgconfig && \
    find /opt/dist -name "*.a" -exec rm -f {} \; || echo ""
RUN rm -rf /opt/dist/usr/local/share/doc
RUN rm -rf /opt/dist/usr/local/share/man

FROM ubuntu:22.04
RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates gpg-agent software-properties-common && \
  rm -rf /var/lib/apt/lists/*
# repository to install Intel(R) oneAPI Libraries
RUN curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB | apt-key add -
RUN echo "deb [trusted=yes] https://apt.repos.intel.com/oneapi all main " > /etc/apt/sources.list.d/oneAPI.list

RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl ca-certificates gpg-agent software-properties-common && \
  rm -rf /var/lib/apt/lists/*
# repository to install Intel(R) GPU drivers
RUN curl -fsSL https://repositories.intel.com/graphics/intel-graphics.key | apt-key add -
RUN echo "deb [trusted=yes arch=amd64] https://repositories.intel.com/graphics/ubuntu jammy flex" > /etc/apt/sources.list.d/intel-graphics.list

RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates build-essential pkg-config gnupg libarchive13 openssh-server openssh-client wget net-tools git intel-oneapi-runtime-ccl intel-oneapi-runtime-compilers intel-oneapi-runtime-dal intel-oneapi-runtime-dnnl intel-oneapi-runtime-dpcpp-cpp intel-oneapi-runtime-dpcpp-library intel-oneapi-runtime-fortran intel-oneapi-runtime-ipp intel-oneapi-runtime-ipp-crypto intel-oneapi-runtime-libs intel-oneapi-runtime-mkl intel-oneapi-runtime-mpi intel-oneapi-runtime-opencl intel-oneapi-runtime-openmp intel-oneapi-runtime-tbb intel-oneapi-runtime-vpl intel-level-zero-gpu level-zero  && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/dist /

ENV LANG=C.UTF-8
ENV LD_LIBRARY_PATH=/opt/intel/oneapi/lib
