# grepl selects variables matching:  characters excluded, all variables.  The
# collapse option connects.  The names to draw from is names(dovars0)
covars <-
    covars0[, !grepl(paste(exclude.vars, collapse = "|"), names(covars0))]
# scaled vars
covars.scale <- scale(covars)
# count vars
nn <- ncol(covars)

# foward selection
# exp.covar defines the data frame with the outcome
exp.covar <- data.frame(y, covars.scale)
#which var has the highest corr w/ y
v1 <- names(which.max(abs(cor(exp.covar))["y", -1]))
# the first variable with the highest cor
v <- v1
for (J in 1:nn) {
    # exclude the var with the highest corr w/ y and selected
    # SUN:  271 sites
    vr <-
        names(exp.covar)[!(names(exp.covar) %in% c(v, "y"))]
    # (k in vr) is the number of names in vector vr
    for (k in vr) {
        # regression formula in fn
        fn <-
            formula(paste("y ~", paste(c(v, k), collapse = "+")))
        # extract the F statistic
        f11 <-
            anova(lm(fn, data = exp.covar))[(J + 1), "F value"]
        if (k == vr[1])
            f12 <- f11
        else
            f12 <- c(f12, f11)
    }
    # choose the variable with the highest F statistic
    v2 <- vr[which.max(f12)]
    # SUN: 2nd var with the highest partial f-test stat in the model with 1st var
    # v is the final list of variables
    v <- c(v, v2)
}
fvar <- v
nvar <-
    c(3, 5, 7, 10, 13, 16, 20, 25, 30, seq(60, length(fvar), 30), length(fvar))
