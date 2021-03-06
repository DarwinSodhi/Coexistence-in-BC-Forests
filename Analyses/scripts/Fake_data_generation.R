#code to simulate fake data based on experimental design 
rm(list=ls())
options(stringsAsFactors = FALSE)
graphics.off()

# setwd("~/Documents/GitHub/Coexistence-in-BC-Forests/Analyses/scripts")


set.seed(1234)

if(FALSE){
# y = biomass
soil_type <- c(0,1)
soil_treatment <- c(0,1)
density <- c(0,1)
temp <- c(0,1)

# does this make sense or should I code variables seperately? (EMW: Either way works, it will depend on the rest of your code!)

#soil_type 0 = hetrospecific 
#soil_type 1 = conspecific  
#soil_treatment 0 = unsterilized
#soil_treatment 1 = sterilized 
#density 0 = single species
#density 1 = 5 conspecific species 
#temp 0 = high temperature ~25 degrees
#temp 1 = low temperature ~10 degrees

#biomass = intercept + soil_type + soil_treatment + density + temp * interactions of all paramteres

#random numbers given to paramters based on predictions
intercept = 30 
soil_type_test= -10
soil_treatment_test = -5
density_test = -15
temp_test = -7.5
}

# EMW: Good start through here! But a few things to work on:
# (1) Start with a simpler version of the experiment! (More on this below)
# (2) You need to build the full dataframe up, it should look in the end like 'real' data, both because otherwise it's too hard to think through (at least for me) and also because it's way easier to check your work.

# Here's the start of a simpler example (but still including an interaction): imagine you have an experiment with a low and high density treatment of ONLY conspecific and low and high temperature in a full factorial design ... following some of your code from above:

density <- c(0,1)
temptreat <- c(0,1)
intercepthere <- 30  # watch out of potentially reserved words in R ..
    # I don't think 'intercept' or 'temp' are used in base R, but they might be in other packages. 
density_effect <- -5 # as in you LOSE 5 units of biomass in the high treatment
temp_effect <- -7.5 # as in you LOSE 7.5 units of biomass in the high temp treatment
denstemp_intxn <- 2 # as in when you have high density and high temp you GAIN 2 units of biomass

reps_per_treatment <- 10 # 10 is always a good place to start (easy to do the math in your head and check your code)
ntot <- length(density)*length(temptreat)*reps_per_treatment

# Okay, so, I will need a dataframe with the following columns: density, temptreat (these are my two X data) and biomass (Y data)
# For building experimental data I use expand.grid to get the factorial right
factorialgrid <- expand.grid(x_density = c(0, 1), x_temp = c(0,1))

df <- as.data.frame(factorialgrid[rep(seq_len(nrow(factorialgrid)), each = reps_per_treatment),])
# check my work
df$treatcombo = paste(df$x_density, df$x_temp, sep = "_")
table(df$treatcombo) 

# now we just need to build the y data ... I think you have all you need now, see where you get.
# y follows from simple linear model ... 
# y = a + b1*x1 + b2*x2 + b3(x1*x2)
# a is the intercept and the b's are each a slope coefficient
df$y_biomass <- intercepthere + density_effect*df$x_density + temp_effect*df$x_temp + denstemp_intxn*(df$x_density*df$x_temp)
# I suggest you try adding one more effect (soil type or soil treat?) with all possible two-way interactions (send me your code when you're done).


#### code for a two way interaction 
#soil type is either 0 (heterospecific) or 1 (conspecific)
soil_type <- c(0,1)
soiltype_effect <- -10 #loses 10 units of biomass in conspecific soil
densoil_intxn <- -12 #high density + conspecific soil causes a loss of 12 units of biomass
tempsoil_intxn <- -4 #high temp + conspecific soil causes a loss of 4 units of biomass
densoiltemp_intxn <- -0.5 #high temp + high density + conspecific soil causes a loss of 0.5 units of biomass

ntot_2 <- length(density)*length(temptreat)*length(soil_type)*reps_per_treatment

factorialgrid <- expand.grid(x_density = c(0, 1), x_temp = c(0,1), x_soil= c(0,1))

df <- as.data.frame(factorialgrid[rep(seq_len(nrow(factorialgrid)), each = reps_per_treatment),])

df$y_biomass <- intercepthere + density_effect*df$x_density + temp_effect*df$x_temp + denstemp_intxn*(df$x_density*df$x_temp) + 
  soiltype_effect*df$x_soil + densoil_intxn * (df$x_density*df$x_soil) + tempsoil_intxn * (df$x_temp * df$x_soil) + 
  densoiltemp_intxn * (df$x_density * df$x_temp * df$x_soil)