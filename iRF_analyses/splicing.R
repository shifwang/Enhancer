library(iRF)
load('./data/splicing.Rdata')
n.cores <- 24
set.seed(47)

rit.params <- list(depth = 5, ntree = 500, nchild = 2, class.id = 1,
  class.cut = NULL)
fit <- iRF(x=x[train.id,], y=y[train.id],
           n.iter=2,
           interactions.return=1:2,
           n.bootstrap=1, 
           n.core=n.cores,
           rit.param=rit.params, 
           varnames.grp=varnames.all$Predictor_collapsed)

save(file='results_splice.Rdata', fit)
