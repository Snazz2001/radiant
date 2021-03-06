###############################################################
### RUN OUTSIDE OF RADIANT
###############################################################

# install to user directory
local_dir <- Sys.getenv("R_LIBS_USER")
if(!file.exists(local_dir)) dir.create(local_dir, recursive = TRUE)


# miniCRAN vignette
# http://cran.r-project.org/web/packages/miniCRAN/vignettes/miniCRAN.html
# path to non-local install directory
inst_to <- .libPaths()[2]
options(repos = c(CRAN = "http://cran.rstudio.com"))
# install.packages('miniCRAN', inst_to, dependencies = TRUE, type='source')
install.packages('miniCRAN')

pth <- "~/Desktop/GitHub/radiant_dev/radiant-miniCRAN"
if(!file.exists(pth)) dir.create(pth)
setwd(pth)
require(miniCRAN)

# Specify list of packages to download
source('pkgs.R')
# pkgs <- "magrittr"

# setting the default location to get R-packages
# look locally first and then in the Rstudio CRAN
pth_gh <- "~/Desktop/GitHub/build_clones/githubMC"
if(!file.exists(pth_gh)) dir.create(pth_gh, recursive=TRUE)
mcran_gh <- paste0("file:///",normalizePath(pth_gh))
repos <- c(mcran_gh,"http://cran.rstudio.com")
options(repos = c(CRAN = c(mcran_gh,"http://cran.rstudio.com")))

# slightly adapted from from Andrei's source code
source("makeRepo.R")
pkgsdir <- "~/Desktop/GitHub/build_clones/pkgs"

# building minicran for source packages built from github
# need to build this first so pkgDep can read the PACKAGES files
.makeRepo(pkgs_gh, path=pth_gh, type="source", localdir=pkgsdir)
.makeRepo(pkgs_gh, path=pth_gh, type="mac.binary", localdir=pkgsdir)
.makeRepo(pkgs_gh, path=pth_gh, type="mac.binary.leopard", localdir=pkgsdir)
.makeRepo(pkgs_gh, path=pth_gh, type="mac.binary.mavericks", localdir=pkgsdir)
.makeRepo(pkgs_gh, path=pth_gh, type="win.binary", localdir=pkgsdir)

# building minicran for source packages
pkgList <- pkgDep(pkgs, repos=repos, type="source", suggests = FALSE)
.makeRepo(pkgs_gh, path=pth, type="source", localdir=pkgsdir)        # needed to copy locally compiled files to the final folders because makeRepo doesn't do this
makeRepo(pkgList, path=pth, type="source")

# building minicran for windows binaries
pkgList <- pkgDep(pkgs, repos=repos, type="win.binary", suggests = FALSE)
.makeRepo(pkgs_gh, path=pth, type="win.binary", localdir=pkgsdir)    # needed to copy locally compiled files to the final folders because makeRepo doesn't do this
makeRepo(pkgList, path=pth, type="win.binary")

# building minicran for mac binaries
pkgList <- pkgDep(pkgs, repos=repos, type="mac.binary", suggests = FALSE)
.makeRepo(pkgs_gh, path=pth, type="mac.binary", localdir=pkgsdir)    # needed to copy locally compiled files to the final folders because makeRepo doesn't do this
makeRepo(pkgList, path=pth, type="mac.binary")

# building minicran for mac mavericks binaries
pkgList <- pkgDep(pkgs, repos=repos, type="mac.binary.mavericks", suggests = FALSE)
.makeRepo(pkgs_gh, path=pth, type="mac.binary.mavericks", localdir=pkgsdir)    # needed to copy locally compiled files to the final folders because makeRepo doesn't do this
.makeRepo(pkgList, path=pth, type="mac.binary.mavericks")                       # needed to avoid crash on mac.binary.mavericks

# when you are all done you could delete the extra dir
# unlink(pth_gh, recursive=TRUE)
