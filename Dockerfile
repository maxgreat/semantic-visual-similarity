
FROM nvidia/cuda:9.2-base-ubuntu16.04
ENV DEBIAN_FRONTEND noninteractive

ENV http_proxy=http://10.100.9.1:2001 https_proxy=http://10.100.9.1:2001
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    cython \
    bzip2 \
    libx11-6 \
    build-essential \
    wget

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda install conda-build \
 && /home/user/miniconda/bin/conda create -y --name py36 python=3.6.5 \
 && /home/user/miniconda/bin/conda clean -ya


ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH


# CUDA 9.2-specific steps
RUN conda install -y -c pytorch \
    cuda92=1.0 \
    magma-cuda92 \
    torchvision \
 && conda clean -ya

# Install HDF5 Python bindings
RUN conda install -y h5py=2.8.0 \
 && conda clean -ya
RUN pip install h5py-cache==1.0

# Install Torchnet, a high-level framework for PyTorch
RUN pip install torchnet==0.0.4

# Install Requests, a Python library for making HTTP requests
RUN conda install -y requests=2.19.1 \
 && conda clean -ya

# Install Graphviz
RUN conda install -y graphviz=2.38.0 \
 && conda clean -ya
RUN pip install graphviz==0.8.4

# Install OpenCV3 Python bindings
#RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
#    libgtk2.0-0 \
#    libcanberra-gtk-module \
# && sudo rm -rf /var/lib/apt/lists/*
RUN conda install -y -c menpo opencv3=3.1.0 \
 && conda clean -ya

# Install gensim
RUN pip install gensim

# Install faiss
RUN conda install faiss-cpu -c pytorch
RUN conda install faiss-gpu -c pytorch
RUN conda install faiss-gpu cuda92 -c pytorch

RUN conda install -c qwant fasttext-python

#install SRU for RNN
RUN pip install sru

#nltk for text tokenizers
RUN pip install nltk

#pycocotools for MS COCO
RUN conda install pycocotools

RUN pip install tensorboardx

# Set the default command to python3
CMD ["python3"]