# Base image
FROM --platform=linux/amd64 debian:bookworm

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    xz-utils \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# Update Conda and install Mamba for faster package management
RUN conda update -n base -c defaults conda && \
    conda config --set channel_priority strict && \
    conda install -n base -c conda-forge mamba

# Clone and install MiniPhy dependencies
RUN git clone https://github.com/LinoHofstetter/MiniPhy && \
    cd MiniPhy && \
    mamba install -c conda-forge -c bioconda -c defaults \
        make "python>=3.7" "snakemake-minimal>=6.2.0" "mamba>=0.20.0" && \
    make conda

# Install Attotree and dependencies
RUN mamba install -c bioconda -c conda-forge attotree && \
    mamba install -c bioconda mash && \
    mamba install -c bioconda quicktree

# Install additional Python packages
RUN pip3 install --upgrade pip && \
    pip3 install pandas numpy biopython  # Add any other packages you need here

# Set working directory
WORKDIR /MiniPhy

# Expose the input and output directories
VOLUME ["/MiniPhy/input", "/MiniPhy/output"]

# Default command to display help
CMD ["make", "help"]
