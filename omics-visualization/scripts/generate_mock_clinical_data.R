set.seed(20260630)

n <- 100
clamp <- function(x, lower, upper) pmin(pmax(x, lower), upper)
r1 <- function(x, digits = 1) round(x, digits)

sex <- sample(c("Female", "Male"), n, replace = TRUE)
age <- sample(20:82, n, replace = TRUE)
bmi <- clamp(rnorm(n, 23.5 + 0.035 * (age - 45), 3.2), 16.5, 36.5)
male <- as.integer(sex == "Male")

dat <- data.frame(
  ID = sprintf("P%03d", seq_len(n)),
  Sex = sex,
  Age = age,
  BMI = r1(bmi),
  WBC = r1(clamp(rnorm(n, 6.2 + 0.015 * (age - 50), 1.35), 3.1, 12.8)),
  RBC = r1(clamp(rnorm(n, 4.35 + 0.42 * male - 0.003 * (age - 50), 0.35), 3.3, 5.9), 2),
  HGB = r1(clamp(rnorm(n, 128 + 18 * male - 0.12 * (age - 50), 10), 95, 175), 0),
  HCT = NA_real_,
  PLT = r1(clamp(rnorm(n, 235 - 0.25 * (age - 50), 48), 110, 410), 0),
  NEUT = r1(clamp(rnorm(n, 58 + 0.08 * (age - 50), 8), 38, 82)),
  LYMPH = NA_real_,
  ALT = r1(clamp(rlnorm(n, log(20 + 0.35 * (bmi - 22) + 3 * male), 0.42), 6, 110), 0),
  AST = NA_real_,
  ALP = r1(clamp(rnorm(n, 72 + 0.18 * (age - 50), 18), 35, 145), 0),
  GGT = r1(clamp(rlnorm(n, log(20 + 7 * male + 0.4 * (bmi - 22)), 0.48), 5, 150), 0),
  TBIL = r1(clamp(rnorm(n, 12.5 + 1.2 * male, 4), 4, 28)),
  ALB = r1(clamp(rnorm(n, 44 - 0.035 * (age - 50), 2.6), 35, 51)),
  TP = NA_real_,
  GLU = r1(clamp(rnorm(n, 5.05 + 0.018 * (age - 45) + 0.055 * (bmi - 23), 0.62), 3.7, 8.8), 2),
  TC = r1(clamp(rnorm(n, 4.55 + 0.012 * (age - 45) + 0.035 * (bmi - 23), 0.7), 2.7, 7.2), 2),
  TG = r1(clamp(rlnorm(n, log(1.25 + 0.055 * (bmi - 22)), 0.42), 0.35, 4.8), 2),
  HDL = r1(clamp(rnorm(n, 1.42 - 0.17 * male - 0.018 * (bmi - 23), 0.25), 0.65, 2.25), 2),
  LDL = NA_real_,
  CREA = r1(clamp(rnorm(n, 63 + 15 * male + 0.20 * (age - 45), 11), 38, 125), 0),
  UREA = r1(clamp(rnorm(n, 4.8 + 0.025 * (age - 45), 1.05), 2.4, 8.9), 2),
  UA = r1(clamp(rnorm(n, 275 + 75 * male + 1.2 * (bmi - 23), 55), 150, 520), 0),
  CRP = r1(clamp(rlnorm(n, log(1.4 + 0.035 * (age - 40) + 0.05 * (bmi - 22)), 0.72), 0.1, 18), 2)
)

dat$HCT <- r1(clamp(dat$HGB * 0.30 + rnorm(n, 0, 1.5), 29, 53))
dat$LYMPH <- r1(clamp(88 - dat$NEUT + rnorm(n, 0, 3.2), 12, 48))
dat$AST <- r1(clamp(dat$ALT * 0.65 + rnorm(n, 10, 5), 8, 95), 0)
dat$TP <- r1(clamp(dat$ALB + rnorm(n, 27, 2.5), 58, 84))
dat$LDL <- r1(clamp(dat$TC - dat$HDL - dat$TG / 2.2 + rnorm(n, 0, 0.12), 1.0, 5.2), 2)

out <- file.path("assets", "mock-clinical-data.csv")
write.csv(dat, out, row.names = FALSE, fileEncoding = "UTF-8")
message("Wrote ", nrow(dat), " rows and ", ncol(dat), " columns to ", out)
