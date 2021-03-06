#code to simulate fake data based on experimental design and altering number of replicates
#housekeeping
rm(list=ls())
options(stringsAsFactors = FALSE)
graphics.off()

setwd("~/Documents/GitHub/Coexistence-in-BC-Forests/Analyses/scripts")

set.seed(1234)

#I plan to run an experiment with four treatments and a three way interactions : soil_type, temp_treat, density & soil_treat
#all treatments are coded as binary and each treatment stands for the following:
#soil_type 0 = hetrospecific soil
#soil_type 1 = conspecific soil  
#soil_treat 0 = unsterilized soil
#soil_treat 1 = sterilized soil
#density 0 = single species
#density 1 = 5 conspecific species 
#temp_treat 0 = high temperature ~25 degrees
#temp_treat 1= low temperature ~10 degrees

### code the fake data

#### codes for the four treatments
density <- c(0,1)
temptreat <- c(0,1)
soil_type <- c(0,1)
soil_treat <- c(0,1)
error <- 1.5


### codes for intercept and individual effects
#y = biomass
intercepthere <- 50
soiltype_effect <- -10 #loses 10 units of biomass in conspecific soil
density_effect <- -5 # as in you LOSE 5 units of biomass in the high treatment
temp_effect <- -7.5 # as in you LOSE 7.5 units of biomass in the low temp treatment
soiltreat_effect <- 5 # as in you Gain 10 units of biomass in the sterilized streatment


#### codes for interactions
densoiltype_intxn <- -12 #high density + conspecific soil causes a loss of 12 units of biomass
denstemp_intxn <- 2 # as in when you have high density and low temp you GAIN 2 units of biomass
densoiltreat_itxn <- -1 #high density + sterilization causes a Loss of one unit of biomass
tempsoiltype_intxn <- -4 #low temp + conspecific soil causes a loss of 4 units of biomass
tempsoiltreat_intxn <- -2.5 #low temp + sterilization causes a loss of 2.5 units of biomass
soiltypesoiltreat_intxn <- -1.5 #conspecific soil + sterilization causes a loss of 1.5 unites of biomass
densoiltypetemp_intxn <- -0.5 #low temp + high density + conspecific soil causes a loss of 0.5 units of biomass
densoiltreattemp_intxn <- 1 
densoiltypesoiltreat_intxn <- 2.5
soiltreattempsoiltype_intxn <- 0.5 
all_intxn <- -0.75 


#codes for number of 5 replicates
reps_per_treatment <- 5 # 10 is always a good place to start (easy to do the math in your head and check your code)
ntot <- length(density)*length(temptreat)*length(soil_type)*length(soil_treat)*reps_per_treatment

#creates datae frame for a factorial design including all four treatments 
factorialgrid <- expand.grid(x_density = c(0, 1), x_temp = c(0,1), x_soiltype= c(0,1), x_soiltreat= c(0,1))

#codes a data frame based on factorial grid and number of reps
df <- as.data.frame(factorialgrid[rep(seq_len(nrow(factorialgrid)), each = reps_per_treatment),])

#calculates the biomass based on treatments and interactions 
df$y_biomass <- intercepthere +
  density_effect*df$x_density +
  temp_effect*df$x_temp +
  soiltype_effect*df$x_soiltype +
  soiltreat_effect*df$x_soiltreat + # 4 main effects
  densoiltype_intxn * (df$x_density * df$x_soiltype) +
  denstemp_intxn * (df$x_density * df$x_temp) +
  densoiltreat_itxn * (df$x_density * df$x_soiltreat) +
  tempsoiltreat_intxn * (df$x_temp * df$x_soiltreat) +
  tempsoiltype_intxn * (df$x_temp * df$x_soiltype) +
  soiltypesoiltreat_intxn * (df$x_soiltype * df$x_soiltreat) + # 6 2-way intxns
  densoiltypetemp_intxn * (df$x_density * df$x_soiltype * df$x_temp) +
  densoiltreattemp_intxn * (df$x_density * df$x_soiltreat * df$x_temp) +
  densoiltypesoiltreat_intxn * (df$x_density * df$x_soiltype * df$x_soiltreat) +
  soiltreattempsoiltype_intxn * (df$x_soiltreat * df$x_temp * df$x_soiltype ) + #4 3-way intxns
  all_intxn * (df$x_density * df$x_temp * df$x_soiltype * df$x_soiltreat)  # 1 4-way intxn

# incorporating 15% error into y
df$y_pred <- rnorm(n = ntot, mean = df$y_biomass, sd = error)

#Statistical model to test paramaters
fittedmodel <- lm(y_pred ~ x_density * x_temp * x_soiltype * x_soiltreat, data= df)

## Putting parameters into a list so you can call all of them at once
#suggestion from Geoff!
param <- list(intercepthere = 50,
              density_effect = -5, # as in you LOSE 5 units of biomass in the high treatment
              temp_effect = -7.5, # as in you LOSE 7.5 units of biomass in the low temp treatment
              soiltype_effect = -10, #loses 10 units of biomass in conspecific soil
              soiltreat_effect = 5, # as in you Gain 10 units of biomass in the sterilized streatment
              #### codes for interactions
              denstemp_intxn = 2, # as in when you have high density and low temp you GAIN 2 units of biomass
              densoiltype_intxn = -12, #high density + conspecific soil causes a loss of 12 units of biomass
              tempsoiltype_intxn = -4, #low temp + conspecific soil causes a loss of 4 units of biomass
              densoiltreat_itxn = -1, #high density + sterilization causes a Loss of one unit of biomass
              tempsoiltreat_intxn = -2.5, #low temp + sterilization causes a loss of 2.5 units of biomass
              soiltypesoiltreat_intxn = -1.5, #conspecific soil + sterilization causes a loss of 1.5 unites of biomass
              densoiltypetemp_intxn = -0.5, #low temp + high density + conspecific soil causes a loss of 0.5 units of biomass
              densoiltreattemp_intxn = 1, 
              densoiltypesoiltreat_intxn = 2.5,
              soiltreattempsoiltype_intxn = 0.5, 
              all_intxn = -0.75)

## saving Model estimates
Fivereps<- t(coef(fittedmodel))

Fivereps
## True value
t(param)


## What is estimated sigma?
sigma(fittedmodel)
## True sigma
error

############################################################################
#run code but this time for 7 reps
############################################################################
#codes for number of 7 replicates
reps_per_treatment <- 7 # 10 is always a good place to start (easy to do the math in your head and check your code)
ntot <- length(density)*length(temptreat)*length(soil_type)*length(soil_treat)*reps_per_treatment

#creates datae frame for a factorial design including all four treatments 
factorialgrid <- expand.grid(x_density = c(0, 1), x_temp = c(0,1), x_soiltype= c(0,1), x_soiltreat= c(0,1))

#codes a data frame based on factorial grid and number of reps
df <- as.data.frame(factorialgrid[rep(seq_len(nrow(factorialgrid)), each = reps_per_treatment),])

#calculates the biomass based on treatments and interactions 
df$y_biomass <- intercepthere +
  density_effect*df$x_density +
  temp_effect*df$x_temp +
  soiltype_effect*df$x_soiltype +
  soiltreat_effect*df$x_soiltreat + # 4 main effects
  densoiltype_intxn * (df$x_density * df$x_soiltype) +
  denstemp_intxn * (df$x_density * df$x_temp) +
  densoiltreat_itxn * (df$x_density * df$x_soiltreat) +
  tempsoiltreat_intxn * (df$x_temp * df$x_soiltreat) +
  tempsoiltype_intxn * (df$x_temp * df$x_soiltype) +
  soiltypesoiltreat_intxn * (df$x_soiltype * df$x_soiltreat) + # 6 2-way intxns
  densoiltypetemp_intxn * (df$x_density * df$x_soiltype * df$x_temp) +
  densoiltreattemp_intxn * (df$x_density * df$x_soiltreat * df$x_temp) +
  densoiltypesoiltreat_intxn * (df$x_density * df$x_soiltype * df$x_soiltreat) +
  soiltreattempsoiltype_intxn * (df$x_soiltreat * df$x_temp * df$x_soiltype ) + #4 3-way intxns
  all_intxn * (df$x_density * df$x_temp * df$x_soiltype * df$x_soiltreat)  # 1 4-way intxn

# incorporating 15% error into y
df$y_pred <- rnorm(n = ntot, mean = df$y_biomass, sd = error)

#Statistical model to test paramaters
fittedmodel <- lm(y_pred ~ x_density * x_temp * x_soiltype * x_soiltreat, data= df)

## Model estimates
Sevenreps<- t(coef(fittedmodel))
Sevenreps
## True value
t(param)
### Looks good

## What is estimated sigma?
sigma(fittedmodel)
## True sigma
error

############################################################################
#run code but this time for 10 reps
############################################################################
#codes for number of 10 replicates
reps_per_treatment <- 10 # 10 is always a good place to start (easy to do the math in your head and check your code)
ntot <- length(density)*length(temptreat)*length(soil_type)*length(soil_treat)*reps_per_treatment

#creates datae frame for a factorial design including all four treatments 
factorialgrid <- expand.grid(x_density = c(0, 1), x_temp = c(0,1), x_soiltype= c(0,1), x_soiltreat= c(0,1))

#codes a data frame based on factorial grid and number of reps
df <- as.data.frame(factorialgrid[rep(seq_len(nrow(factorialgrid)), each = reps_per_treatment),])

#calculates the biomass based on treatments and interactions 
df$y_biomass <- intercepthere +
  density_effect*df$x_density +
  temp_effect*df$x_temp +
  soiltype_effect*df$x_soiltype +
  soiltreat_effect*df$x_soiltreat + # 4 main effects
  densoiltype_intxn * (df$x_density * df$x_soiltype) +
  denstemp_intxn * (df$x_density * df$x_temp) +
  densoiltreat_itxn * (df$x_density * df$x_soiltreat) +
  tempsoiltreat_intxn * (df$x_temp * df$x_soiltreat) +
  tempsoiltype_intxn * (df$x_temp * df$x_soiltype) +
  soiltypesoiltreat_intxn * (df$x_soiltype * df$x_soiltreat) + # 6 2-way intxns
  densoiltypetemp_intxn * (df$x_density * df$x_soiltype * df$x_temp) +
  densoiltreattemp_intxn * (df$x_density * df$x_soiltreat * df$x_temp) +
  densoiltypesoiltreat_intxn * (df$x_density * df$x_soiltype * df$x_soiltreat) +
  soiltreattempsoiltype_intxn * (df$x_soiltreat * df$x_temp * df$x_soiltype ) + #4 3-way intxns
  all_intxn * (df$x_density * df$x_temp * df$x_soiltype * df$x_soiltreat)  # 1 4-way intxn

# incorporating 15% error into y
df$y_pred <- rnorm(n = ntot, mean = df$y_biomass, sd = error)

#Statistical model to test paramaters
fittedmodel <- lm(y_pred ~ x_density * x_temp * x_soiltype * x_soiltreat, data= df)


## Model estimates
Tenreps<- t(coef(fittedmodel))
Tenreps
## True value
t(param)
### Looks good

## What is estimated sigma?
sigma(fittedmodel)
## True sigma
error

#####merge
truepram<- as.numeric(t(param))
comparereps <- rbind(Fivereps,Sevenreps,Tenreps,truepram)
row.names(comparereps)[1] <-"Fivereps"
row.names(comparereps)[2] <-"Sevenreps"
row.names(comparereps)[3] <-"Tenreps"
