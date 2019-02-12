# mesim_pure and related functions:
#   getMSE
#   me_pure
# TODO: DROP?: Note:  uses the purrr tidyverse package
# 
# getMSE function:
getMSE <- function(obs,pred) {
    # obs is the outcome variable
    # pred is the prediction from a model
    obs_avg <- mean(obs)
    MSE_obs <- mean((obs-obs_avg)^2)
    MSE_pred <- mean((obs - pred)^2)
    result <- c(sqrt(MSE_pred),
                max(1 - MSE_pred / MSE_obs, 0))
    names(result) <-  c("RMSE", "R2(MSE-based)")
    
    return(result)
}

# mesim_pure code (need to learn...)

# TODO:  Should the seed be set here or before calling?  Probably outside before
# calling the mesim_pure function
#set.seed(100)

me_pure <- function(n_subj = 10000) {
# definition of terms:
#   n for sample size (n_subj), referring to subject 
#   z for exposure model covariates
#   y for outcome
# the following terms are passed from outside if not using defaults:
#   n_subj=10000 (default) is the # subjects
# the following terms are set inside the program: (could edit the function to
# pass these in from outside)
#   sd_eta=4  is the SD for the error in the exposure model
#   sd_e1=4   is the SD for the extra classical error of exposure
#   sd_e2=4   is the SD for the extra classical error of exposure
#   sd_e3=4   is the SD for the extra classical error of exposure
#   sd_eps=25 is the SD for the error in the disease model
#   alpha_0=0 is the intercept parameter in the exposure model
#   alpha[1]=4is the parameter for s1 in the exposure model
#   alpha[2]=4is the parameter for s2 in the exposure model
#   alpha[3]=4is the parameter for s3 in the exposure model
#   beta[1]=1   is the intercept in the disease model
#   beta[2]=2   is the slope in the disease model (called \beta_x in the lab)
# define the exposure and health model parameters for fixed effects
#   define the coefficients alpha and beta (description given above)
alpha_0 <- 0
alpha <- c(4,4,4)
beta  <- c(1,2)

#   define the SDs for all the components for the subjects and samples 
sd_s <- c(1,1,1)
sd_eta <- 4
sd_e <- c(4,4,4)
sd_eps <- 25

# first create the subject dataset:
n_subj = 10000

s_1 <- rnorm(n_subj,sd=sd_s[1])
s_2 <- rnorm(n_subj,sd=sd_s[2])
s_3 <- rnorm(n_subj,sd=sd_s[3])

x <- alpha_0 + alpha[1]*s_1 + alpha[2]*s_2 + alpha[3]*s_3 + 
     rnorm(n_subj, sd = sd_eta)
y <- beta[1] + beta[2]*x + rnorm(n_subj, sd = sd_eps)

Berk_1 <- alpha_0 + alpha[1]*s_1
Berk_2 <- alpha_0 + alpha[1]*s_1 + alpha[2]*s_2
Berk_3 <- alpha_0 + alpha[1]*s_1 + alpha[2]*s_2 + alpha[3]*s_3

class_1 <- x       + rnorm(n_subj, sd = sd_e[1])
class_2 <- class_1 + rnorm(n_subj, sd = sd_e[2])
class_3 <- class_2 + rnorm(n_subj, sd = sd_e[3])

predictors <- c("x", "Berk_1", "Berk_2", "Berk_3", 
                "class_1", "class_2", "class_3")

#TODO DROP most likely:  idea for doing this with purrr.  probably too advanced 
# for ENVH 556 (and me!)
#models <- map(setNames(1:7,predictors), ~ lm(y ~ paste(.x)))

#TODO:  define a list for 4 parameters x 7 models.  This will go into a bigger
#list or data frame with n_samps replicates that is called below
#result <- list(b1 = WHAT HERE FOR 7xn_samps, seb1 = WHAT HERE FOR 7xn_samps)
    for (i in seq_along(predictors)) {
        lmfit <- lm(y ~ predictors[i])
        
        b1[i]      <- tidy(lmfit)$estimate[2]
        seb1[i]    <- tidy(lmfit)$std.error[2]
        R2[i]      <- getMSE(y,lmfit$fitted.values)
        exp_var[i] <- var(predictors[i])
        
        #return(ADD)
    }

# TODO:  need to return something from this function, depending on how result is 
# defined

}

# TODO:  need to test this and make sure it returns what I want
result_pure <- replicate( 1000, {
    me_pure
    })

# TODO:  once I have the result_pure in the structure I want, I need to do some
# analyses of it.  Presumably do that inside the calling .Rmd instead of here.
# May even want the result_pure replication step in the calling .Rmd.
