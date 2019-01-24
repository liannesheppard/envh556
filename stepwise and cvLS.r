# 3.2. land use regression
mod.min  <- lm(pm25 ~ 1, data=mon.data)
mod.full <- lm(pm25 ~ long + lat + log10.m.to.a1 + log10.m.to.a2 + log10.m.to.a3
                + log10.m.to.road + km.to.coast + s2000.pop.div.10000, data=mon.data)

step(mod.min, direction="both", scope=list(lower = ~1, upper = mod.full), test="F")

# output of step has the coefficients.  Can use that to get the list??

mod <- lm(pm25 ~ km.to.coast + log10.m.to.a1 + log10.m.to.a2 + lat, data=mon.data)

# 3.2.1. leave-one-out cross-validation
for(i in 1:nrow(mon.data)){
  train <- mon.data[-i,]
  test <- mon.data[i,]
  train.lm <- lm(pm25 ~ km.to.coast + log10.m.to.a1 + log10.m.to.a2 + lat, data=train)
  X <- cbind(1,matrix(unlist(test[,names(train.lm$model)[-1]]),nrow=1))
  pred.1 <- X %*% train.lm$coef
  if(i==1) pred <- pred.1 else pred <- c(pred,pred.1)
}

mse.lur <- mean( (mon.data$pm25 - pred)^2 )
r2.lur <- 1 - mse.lur/var(mon.data$pm25)
mse.lur
r2.lur
