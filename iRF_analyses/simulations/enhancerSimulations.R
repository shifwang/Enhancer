library(iRF)
load('../data/enhancer.Rdata')
load('../data/rfSampleSplitNoise.Rdata')

tf.idcs <- 46:80
X <- X[,tf.idcs]
varnames.agg <- varnames.all[tf.idcs, 2]
varnames.agg <- gsub('_', '.', varnames.agg)

responseTF <- function(x, tt=c(rep(1.25, 4), 75)) {
  y <- (x[,'kr1'] > tt[1] | x[,'kr2'] > tt[1]) &
    (x[,'twi1'] > tt[2] | x[,'twi2'] > tt[2]) &
    (x[,'D1'] > tt[3]) &
    (x[,'hb1'] > tt[4] | x[,'hb2'] > tt[4]) &
    (x[,'wt_ZLD'] > tt[5])
    return(y)
}

n <- nrow(X)
p <- ncol(X)
n.reps <- 20
sample.sizes <- seq(200, 2000, by=200) 
noise <- c('rf', 'swap')
dir <- 'simulations/tf/'
dir.create(dir, recursive=TRUE)

for (ns in noise) {
  for (ss in sample.sizes) {
    write.dir <- paste0(dir, 'noise_', ns, '/', 'nTrain_', ss, '/')
    dir.create(write.dir, recursive=TRUE)

    lapply(1:n.reps, function(i) {

      # Generate responses and introduce additional interactions
      if (ns == 'rf') {

        pred.prob.mean <- rowMeans(pred.prob)
        y.noise <- as.numeric(runif(n) < pred.prob.mean)
        y <- responseTF(x=X)       
        y <- y | y.noise

      } else if (ns == 'swap') {

        y <- responseTF(x=X)
        n1 <- sum(y)
        n0 <- sum(!y)
        idcs.flip.1 <- sample(which(y == 1), round(n1 * 0.2))
        idcs.flip.0 <- sample(which(y == 0), round(n1 * 0.2))
        idcs.flip <- c(idcs.flip.0, idcs.flip.1)
        if (length(idcs.flip)) y[idcs.flip] <- !y[idcs.flip]
      } 

      prop.1 <- mean(y)
      prop.0 <- 1 - prop.1
      obs1 <- which(y)
      obs0 <- which(!y)
      train.id <- c(sample(obs1, round(ss * prop.1), replace=FALSE),
                    sample(obs0, round(ss * prop.0), replace=FALSE))

      obs1 <- setdiff(obs1, train.id)
      obs0 <- setdiff(obs0, train.id)
      test.id <- c(sample(obs1, round(ss * prop.1), replace=FALSE),
                   sample(obs0, round(ss * prop.0), replace=FALSE))
      y <- as.factor(as.numeric(y))

      fit <- iRF(x=X[train.id,], y=y[train.id], 
                 xtest=X[test.id,], ytest=y[test.id], 
                 n.iter=5, interactions.return=1:5, 
                 n.bootstrap=20, varnames.grp=varnames.agg,
                 n.cores=n.cores) 

      y.test <- y[test.id]
      y.train <- y[train.id]
      save(file=paste0(write.dir, 'rep', i, '.Rdata'), fit, train.id, test.id, y.train, y.test)
    })

  }
}
