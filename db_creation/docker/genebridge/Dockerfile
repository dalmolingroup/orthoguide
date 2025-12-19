FROM rocker/r-ver:4.3.2

RUN apt-get update && apt-get install -y     zlib1g-dev     libpng-dev     libssl-dev     libcurl4-openssl-dev     wget && rm -rf /var/lib/apt/lists/*

RUN Rscript -e 'install.packages(c("remotes", "BiocManager", "vroom"), repos="https://cran.rstudio.com/")'

RUN Rscript -e 'BiocManager::install("AnnotationHub", force = TRUE)'

RUN Rscript -e 'remotes::install_github("sysbiolab/GeneBridge")'

CMD ["bash"]
