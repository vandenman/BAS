context("bas.lm")

test_that("shrinkage is less than or equal to 1", {
  data(Hald)
  hald_bas <- bas.lm(Y ~ ., prior = "ZS-null", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "EB-local", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "EB-global", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "hyper-g", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "hyper-g-n", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "hyper-g-laplace", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "g-prior", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "AIC", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "BIC", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
  hald_bas <- bas.lm(Y ~ ., prior = "ZS-full", modelprior = uniform(), data = Hald)
  expect_equal(0, sum(hald_bas$shrinkage > 1))
})

test_that("shrinkage is less than or equal to 1", {
  data(Hald)
  #  hald_bas = bas.lm(Y ~ ., prior="JZS", modelprior=uniform(), data=Hald)
  #  expect_equal(0, sum(hald_bas$shrinkage > 1))
})

test_that("A/BIC: shrinkage is equal to 1", {
  data(Hald)
  hald_BIC <- bas.lm(Y ~ ., prior = "BIC", modelprior = uniform(), data = Hald)
  expect_equal(hald_BIC$n.model, sum(hald_BIC$shrinkage == 1))
  hald_AIC <- bas.lm(Y ~ ., prior = "AIC", modelprior = uniform(), data = Hald)
  expect_equal(hald_AIC$n.model, sum(hald_AIC$shrinkage == 1))
})

test_that("no method", {
  data(Hald)
  expect_error(bas.lm(Y ~ .,
    prior = "garbage",
    modelprior = uniform(), data = Hald
  ))
})

test_that("deterministic, BAS and MCMC+BAS", {
  data(Hald)
  hald_bas <- bas.lm(Y ~ .,
    prior = "BIC",
    modelprior = uniform(), data = Hald
  )
  hald_MCMCbas <- bas.lm(Y ~ .,
    prior = "BIC", method = "MCMC+BAS",
    modelprior = uniform(), data = Hald, MCMC.iterations = 1000
  )
  hald_deterministic <- bas.lm(Y ~ .,
    prior = "BIC",
    method = "deterministic",
    modelprior = uniform(), data = Hald
  )
  expect_equal(hald_bas$probne0, hald_deterministic$probne0)
  expect_equal(hald_bas$probne0, hald_MCMCbas$probne0)
})

test_that("pivot", {
  data(Hald)
  hald_bas <- bas.lm(Y ~ .,
    prior = "BIC",
    modelprior = uniform(), data = Hald
  )
  hald_deterministic <- bas.lm(Y ~ .,
    prior = "BIC",
    method = "deterministic",
    modelprior = uniform(), data = Hald, pivot = TRUE
  )
  expect_equal(hald_bas$probne0, hald_deterministic$probne0)
})


test_that("pivoting with non-full rank design", {
  set.seed(42)
  dat <- data.frame(Y = rnorm(5), X1 = 1:5, X2 = 1:5, X3 = rnorm(5))

  tmp.bas <- bas.lm(Y ~ ., data = dat, prior = "BIC", modelprior = uniform(), method = "BAS", pivot = T)

  tmp.mcmc <- bas.lm(Y ~ ., data = dat, prior = "BIC", modelprior = uniform(), method = "MCMC", pivot = T, MCMC.iterations = 10000)
  expect_equal(sort(tmp.bas$R2), sort(tmp.mcmc$R2))
})

test_that("prediction versus fitted", {
  data(Hald)
  hald_ZS <- bas.lm(Y ~ .,
    prior = "ZS-null", modelprior = uniform(),
    data = Hald
  )
  expect_equal(
    as.vector(fitted(hald_ZS, estimator = "BMA")),
    predict(hald_ZS, estimator = "BMA", se.fit = TRUE)$fit
  )
  expect_equal(
    as.vector(fitted(hald_ZS, estimator = "HPM")),
    as.vector(predict(hald_ZS, estimator = "HPM", se.fit = TRUE)$fit)
  )
  expect_equal(
    as.vector(fitted(hald_ZS, estimator = "BPM")),
    as.vector(predict(hald_ZS, estimator = "BPM", se.fit = TRUE)$fit)
  )
  expect_equal(
    as.vector(fitted(hald_ZS, estimator = "MPM")),
    as.vector(predict(hald_ZS, estimator = "MPM", se.fit = TRUE)$fit)
  )
})

test_that("methods", {
  data(Hald)
  expect_error(bas.lm(Y ~ .,
    prior = "ZS-null", modelprior = uniform(),
    data = Hald, method = "AMCMC"
  ))
  expect_error(bas.lm(Y ~ .,
    prior = "hyperg/n", modelprior = uniform(),
    data = Hald
  ))
})

test_that("force.heredity", {
  loc <- system.file("testdata", package = "BAS")
  d <- read.csv(paste(loc, "JASP-testdata.csv", sep = "/"))

  simpleFormula <- as.formula("contNormal ~ contGamma + contcor1 + contGamma * contcor1 ")

  set.seed(1)
  basObj <- bas.lm(simpleFormula,
    data = d,
    alpha = 0.125316,
    prior = "JZS",
    include.always = as.formula("contNormal ~ contcor1"),
    modelprior = beta.binomial(1, 1),
    weights = d$facFifty
  )
  set.seed(1)
  basObj.old <- bas.lm(simpleFormula,
    data = d,
    alpha = 0.125316,
    prior = "JZS",
    include.always = as.formula("contNormal ~ contcor1"),
    modelprior = beta.binomial(),
    weights = d$facFifty, force.heredity = FALSE
  )
  basObj.old <- force.heredity.bas(basObj.old)

  expect_equal(basObj$probne0, basObj.old$probne0)
})


test_that("check non-full rank", {
  loc <- system.file("testdata", package = "BAS")
  d <- read.csv(paste(loc, "JASP-testdata.csv", sep = "/"))

  fullModelFormula <- as.formula("contNormal ~  contGamma * contExpon + contGamma * contcor1 + contExpon * contcor1")

  expect_warning(bas.lm(fullModelFormula,
    data = d,
    alpha = 0.125316,
    prior = "JZS",
    weights = facFifty, force.heredity = FALSE, pivot = F
  ))
  expect_error(eplogprob(lm(fullModelFormula, data = d)))
  basObj.eplogp <- bas.lm(fullModelFormula,
    data = d,
    alpha = 0.125316, initprobs = "marg-eplogp",
    prior = "JZS", method = "deterministic", pivot = T,
    modelprior = uniform(),
    weights = facFifty, force.heredity = FALSE
  )
  basObj.det <- bas.lm(fullModelFormula,
    data = d,
    alpha = 0.125316,
    modelprior = uniform(),
    prior = "JZS", method = "deterministic", pivot = T,
    weights = facFifty, force.heredity = FALSE
  )
  basObj <- bas.lm(fullModelFormula,
    data = d,
    alpha = 0.125316, modelprior = uniform(),
    prior = "JZS", method = "BAS", pivot = T,
    weights = facFifty, force.heredity = FALSE
  )
  expect_equal(0, sum(is.na(basObj.det$postprobs)))
  expect_equal(basObj.eplogp$probne0, basObj.det$probne0)
  expect_equal(basObj.det$probne0, basObj$probne0)
  expect_equal(basObj.eplogp$probne0, basObj$probne0)

  basObj.EBL <- bas.lm(fullModelFormula,
    data = d,
    alpha = 0.125316, initprobs = "marg-eplogp",
    prior = "EB-local", method = "deterministic", pivot = T,
    modelprior = uniform(),
    weights = facFifty, force.heredity = FALSE
  )
  basObj.up <- update(basObj.eplogp, newprior = "EB-local")
  expect_equal(basObj.EBL$postprobs, basObj.up$postprobs)
})

test_that("as.matrix tools", {
  data(Hald)
  hald_bic <- bas.lm(Y ~ .,
    data = Hald, prior = "BIC",
    initprobs = "eplogp"
  )
  m1 <- which.matrix(hald_bic$which, hald_bic$n.vars)
  colnames(m1) <- hald_bic$namesx
  m2 <- list2matrix.which(hald_bic)
  expect_equal(m1, m2)
  m3 <- list2matrix.bas(hald_bic, "which") > 0
  m3[, 1] <- 1
  probne0 <- t(m3) %*% hald_bic$postprobs
  expect_equal(as.vector(probne0), hald_bic$probne0)
})