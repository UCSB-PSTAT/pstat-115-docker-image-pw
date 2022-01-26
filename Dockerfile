FROM jupyter/r-notebook:latest
#FROM ucsb/r-base:v20210120.1

ENV REPOS='https://cran.microsoft.com'


LABEL maintainer="Patrick Windmiller <windmiller@pstat.ucsb.edu>"

USER root

RUN apt update -y && apt upgrade -yq && \
    apt install -yq build-essential python-dev autotools-dev libicu-dev libbz2-dev libboost-all-dev libfreetype6-dev libpixman-1-dev libcairo2-dev libxt-dev nano && \
    wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2021.09.2-382-amd64.deb && \
    wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.2-382-amd64.deb && \
    apt install ./rstudio*.deb -yq && apt-get clean && rm -f ./rstudio*.deb

## Required rstan build method to work with docker and kubernetes (Beginning)
#-- RSTAN
#-- install rstan reqs
RUN echo "local({r <- getOption('repos'); r['CRAN'] <- 'https://cran.microsoft.com';  options(repos = r)})" > $R_HOME/etc/Rprofile.site
RUN R -e "install.packages(c('inline','gridExtra','loo'),repos='$REPOS')"
#-- install rstan
RUN R -e "dotR <- file.path(Sys.getenv('HOME'), '.R'); if(!file.exists(dotR)){ dir.create(dotR) }; Makevars <- file.path(dotR, 'Makevars'); if (!file.exists(Makevars)){  file.create(Makevars) }; cat('\nCXX14FLAGS=-O3 -fPIC -Wno-unused-variable -Wno-unused-function', 'CXX14 = g++ -std=c++1y -fPIC', file = Makevars, sep = '\n', append = TRUE)"
RUN R -e "install.packages(c('ggplot2','StanHeaders','V8','BH'),repos='$REPOS')"
RUN R -e "packageurl <- 'https://cran.r-project.org/src/contrib/rstan_2.21.3.tar.gz'; install.packages(packageurl, repos = NULL, type = 'source', dependencies = TRUE)"
#-- Docker Makevars substitute (Allows for clearing of Home directory during persistance storage build)
##RUN sed -i 's/CXX14 = /CXX14 = g++ -std=c++1y -fPIC/I' $R_HOME/etc/Makeconf && \
##    sed -i 's/CXX14FLAGS = /CXX14FLAGS = -O3 -fPIC -Wno-unused-variable -Wno-unused-function/I' $R_HOME/etc/Makeconf
## Required rstan build (End)

#-- ggplot2 extensions
RUN R -e "install.packages(c('GGally','ggridges','viridis'),repos='$REPOS')"

#-- Misc utilities
RUN R -e "install.packages(c('beepr','config','tinytex','rmarkdown','formattable','here','Hmisc'),repos='$REPOS')"

RUN R -e "install.packages(c('kableExtra','logging','microbenchmark','openxlsx'),repos='$REPOS')"

RUN R -e "install.packages(c('RPushbullet','styler','ggridges','plotmo'),repos='$REPOS')"

RUN R -e "install.packages(c('nloptr'),repos='$REPOS')"

RUN R --vanilla -e "install.packages('minqa',repos='https://cloud.r-project.org', dependencies=TRUE)"

#-- Caret and some ML packages
#-- ML framework, metrics and Models
RUN R -e "install.packages(c('codetools'),repos='$REPOS')"
RUN R --vanilla -e "install.packages('caret',repos='https://cloud.r-project.org')"
RUN R -e "install.packages(c('car','ensembleR','MLmetrics','pROC','ROCR','Rtsne','NbClust'),repos='$REPOS')"

RUN R -e "install.packages(c('tree','maptree','arm','e1071','elasticnet','fitdistrplus','gam','gamlss','glmnet','lme4','ltm','randomForest','rpart','ISLR'),repos='$REPOS')"

#-- More Bayes stuff
RUN R -e "install.packages(c('coda','projpred','MCMCpack','hflights','HDInterval','tidytext','dendextend','LearnBayes'),repos='$REPOS')"

RUN R -e "install.packages(c('rstantools', 'shinystan'),repos='$REPOS')"

RUN R -e "install.packages(c('mvtnorm','dagitty','tidyverse','codetools'),repos='$REPOS')"

RUN R -e "devtools::install_github('rmcelreath/rethinking', upgrade = c('never'),repos='$REPOS')"

#-- ottr
RUN R -e "devtools::install_github('ucbds-infra/ottr@stable')"
RUN pip install otter-grader


#-- Cairo
RUN R -e "install.packages(c('Cairo'),repos='$REPOS')"

RUN conda && conda clean -i

RUN pip install nbgitpuller && \
    jupyter serverextension enable --py nbgitpuller --sys-prefix

RUN conda install -y -c conda-forge jupyter-server-proxy jupyter-rsession-proxy

#-- Latex
# RUN apt-get update && apt-get install -y \
#    texlive-latex-base \
#    texlive-fonts-recommended \
#    texlive-latex-recommended \
    #texlive-latex-extra

#RUN R -e "tinytex::install_tinytex()"

# Removes the .R folder for accurate simulation of Kubernetes/Docker/Persistant storage env
RUN rm -R $HOME/.R

USER $NB_USER

