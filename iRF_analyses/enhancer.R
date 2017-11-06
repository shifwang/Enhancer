library(iRF)
n.cores <- 24
set.seed(1)
load('./data/enhancer.Rdata')

rit.params <- list(depth=5, nchild=2, ntree=500, class.id=1, class.cut=NULL)
fit <-  iRF(x=X[train.id,], 
           y=as.factor(Y[train.id]), 
           xtest=X[test.id,], 
           ytest=as.factor(Y[test.id]), 
           n.iter=4,
           interactions.return=1:4, 
           rit.params=rit.params,
           varnames.grp=varnames.all$Predictor_collapsed, 
           n.core=n.cores, 
           n.bootstrap=30,
           rit.param=rit.params
          )
save(file='results_enhancer.Rdata', fit)


