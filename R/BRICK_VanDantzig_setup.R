# =======================================================================================
# Script to set up the flood risk/Van Dantzig analysis. This module serves as
# a coupling link between the physical and socioeconomic impacts modules of
# BRICK.
#
# Questions? Tony Wong (twong@psu.edu)
# =======================================================================================
#
#   Requires (input variables):
# - sea_level     simulated local sea level [m sle]
# - time          times of model steps [years]
# - ss.gev        array of storm surge GEV parameters [n.ensemble x 3 (loc/scale/shape)]
# - surge.rise    time series for storm surge rise
# - params.vd     draws for smapling Van Dantzig parameters within the ensemble
#
#   Simulates (output variables):
# - vanDantzig.ensemble   ensemble of Van Dantzig outputs (heightenings and
#                         corresponding investment costs, losses, and failure
#                         probabilities)
#
#   Parameters:
# - currentyear           year in which we initially evaluate the dikes
# - endyear               year the dikes must hold strong until
# - lowleveeheight        lowest heightening considered [m]
# - highleveeheight       highest dike heightening considered [m]
# - increment             consider dike heightenings from lowleveeheight to
#                         highleveeheight in increments of 'increment'
# - H0                    initial height of levee [m]
# - p_zero_p              initial flood frequency (1/yr) if no heightening
# - alpha_p               exponential flood frequency constant
# - V_p                   value of goods protected by the dike
# - delta_prime_p         net discount rate
# - I_range               investment cost uncertainty range
# - subs_rate             land subsidence rate (m/yr)
# - design_surge_level    Table #2 from Jonkman et al (2009)
# - investments_US        Table #2 from Jonkman et al (2009)
#                         These two above give the cost in US$ to build a levee
#                         to withstand the given surge level.
##==============================================================================
## Copyright 2016 Tony Wong, Alexander Bakker
## This file is part of BRICK (Building blocks for Relevant Ice and Climate
## Knowledge). BRICK is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## BRICK is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with BRICK.  If not, see <http://www.gnu.org/licenses/>.
##==============================================================================

#install.packages("extRemes")
#install.packages("fExtremes")
#install.packages('ismev')
#install.packages('zoo')
library(extRemes)
library(fExtremes)
#library(ismev)
library(zoo)

source("../R/VD_NOLA.R")

## Set up
lowleveeheight	= 0         # lowest levee heightening considered (m)
highleveeheight	= 0.91      # largest levee heightening considered (m)
increment       = 0.91		# increment of levee heightening range (m)
H0              = 16*0.3048 # initial levee height (m) (change to 16ft = 4.877m
                            # rough average of NOLA central levee ring)
H0 = H0-(4*0.3048)          # initial subsidence of 4 ft

## Time horizon until next evaluation of levees (years)
T <- endyear - currentyear
time_frame <- time.proj

## Range of considered levee heights (meters)
X = seq(from = lowleveeheight, to = highleveeheight, by = increment)

## Conversion from feet to meters:
feet_to_meter = function(ft) { ft * 0.3048 }

## Investment costs for surge levels. Table # 2 in Jonkman et al. (2009)
## Correction from previous versions - this is *total* levee height, not just
## the heightening.
design_surge_level_ft = c(9, 11, 13, 15, 17, 21, 25)
design_surge_level_M = feet_to_meter(design_surge_level_ft)

investments_US = c(2.2E09, 2.4E09, 2.6E09, 2.9E09, 3.1E09, 3.6E09, 4.1E09)

I_table = matrix(c(design_surge_level_M, investments_US), ncol=2)
colnames(I_table) = c("Surge level", "Associated cost")

investment.fit <- lm(I_table[,2]~I_table[,1])
intercept.h2i = investment.fit$coefficients[[1]]
slope.h2i = investment.fit$coefficients[[2]]

##==============================================================================
## End
##==============================================================================
