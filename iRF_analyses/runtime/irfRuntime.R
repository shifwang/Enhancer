library(iRF)
library(AUC)
n.cores <- 32
set.seed(32)

data.dir <- '../data/'
load(paste0(data.dir, 'enhancer.Rdata'))
drop.vars <- c('ZLDm.H3', 'ZLDm.H3K18ac', 'ZLDm.H3K4me1', 'ZLDm.ZLD')
X <- X[,!(colnames(X) %in% drop.vars)]
varnames.all <- varnames.all[!(varnames.all[,1] %in% drop.vars),]
varnames.agg <- varnames.all[,2]

rownames(X) <- NULL
n0 <- sum(Y==0)
n1 <- sum(Y==1)
p <- ncol(X)
col.permuted <- sample(1:p, p, replace=FALSE)
pseq <- seq(10, p, by=10)

runtime <- rep(0, length(pseq))
auroc <- array(0, c(length(pseq), 5))


for (i in 1:length(pseq)){
  print(paste('p ---->', pseq[i]))
  id <- col.permuted[1:pseq[i]]
  ptm <- proc.time()
  ff <- iRF(x=X[train.id, id]
           , y=as.factor(Y[train.id])
           , xtest=X[test.id,id]
           , ytest=as.factor(Y[test.id])
           , n.iter = 3
           , interactions.return = 3
           , n.bootstrap = 10 
           , n.core = n.cores
           )

  runtime[i] <- (proc.time()-ptm)[3]
  print(paste('p: ', pseq[i], '; time: ', runtime[i]))
  for (j in 1:3)
    auroc[i,j] <- auc(roc(ff$rf.list[[j]]$test$votes[,2], as.factor(Y[test.id])))
  save(runtime, auroc, file='runtime.irf.Rdata')
}

