FROM community.wave.seqera.io/library/r-ape_r-dplyr_r-magrittr_r-stringi_pruned:8a10e051913dbb30

RUN Rscript -e 'install.packages(c("remotes", "BiocManager"), repos="https://cran.rstudio.com/")'

RUN Rscript -e 'remotes::install_github("sysbiolab/GeneBridge")'
