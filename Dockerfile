FROM bioconductor/bioconductor_docker:RELEASE_3_11

WORKDIR /home/rstudio

COPY --chown=rstudio:rstudio . /home/rstudio/curatedTCGAManu

ENV R_REMOTES_NO_ERRORS_FROM_WARNINGS=true

RUN Rscript -e "options(repos = c(CRAN = 'https://cloud.r-project.org')); BiocManager::install(update = TRUE, ask = FALSE); devtools::install('.', dependencies = TRUE, repos = BiocManager::repositories(), build_vignettes = TRUE)"

