# =======================================================================================
# Driver script to run the flood risk/Van Dantzig analysis. This module serves
# as a coupling link between the physical and socioeconomic impacts modules of
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

brick_vandantzig <- function(
  currentyear,
  endyear,
  sea_level,
  time,
  ss.gev=NULL,
  surge.rise=NULL,
  params.vd=NULL
){

## Make sure sea_level has time as the first dimension (number of rows = number of years)
dims = dim(sea_level)
if(dims[1]!=length(time)) {sea_level=t(sea_level)}
n.ensemble = dims[2]

## Create a matrix of sea-level data starting from the current year for each model simulation.
## (but does not include subsidence, which is accounted for as uncertain parameter)
local_sea_level = data.matrix(sea_level[match(currentyear, time):match(endyear, time), ])

## Test simulation to get the names
if(is.null(surge.rise)) {
  vd.out = VD_NOLA_R(params=params.vd[1,], T=T, X=X,
    local_sea_level=local_sea_level[,1], intercept.h2i=intercept.h2i,
    slope.h2i=slope.h2i, ss.gev=ss.gev[1,], H0=H0)
} else {
  vd.out = VD_NOLA_R(params=params.vd[1,], T=T, X=X,
    local_sea_level=local_sea_level[,1], intercept.h2i=intercept.h2i,
    slope.h2i=slope.h2i, ss.gev=ss.gev[1,], surge.rise=surge.rise[,1], H0=H0)
}

vanDantzig.ensemble = vector("list", ncol(vd.out))
names(vanDantzig.ensemble) = names(vd.out)
for (i in 1:ncol(vd.out)) {
  vanDantzig.ensemble[[i]] = mat.or.vec(nrow(vd.out), n.ensemble)
}

## Run the simulations
print(paste('Starting the risk assessment simulations now...',sep=''))

if(is.null(surge.rise)) {
  pb <- txtProgressBar(min=0,max=n.ensemble,initial=0,style=3)
  for (i in 1:n.ensemble) {
    vd.out = VD_NOLA_R(params=params.vd[i,], T=T, X=X,
      local_sea_level=local_sea_level[,i], intercept.h2i=intercept.h2i,
      slope.h2i=slope.h2i, ss.gev=ss.gev[i,], H0=H0)
    for (j in 1:ncol(vd.out)) {
		  vanDantzig.ensemble[[j]][,i] = vd.out[,j]
	  }
    setTxtProgressBar(pb, i)
  }
} else {
  pb <- txtProgressBar(min=0,max=n.ensemble,initial=0,style=3)
  for (i in 1:n.ensemble) {
    vd.out = VD_NOLA_R(params=params.vd[i,], T=T, X=X,
      local_sea_level=local_sea_level[,i], intercept.h2i=intercept.h2i,
      slope.h2i=slope.h2i, ss.gev=ss.gev[i,], surge.rise=surge.rise[,i], H0=H0)
    for (j in 1:ncol(vd.out)) {
		  vanDantzig.ensemble[[j]][,i] = vd.out[,j]
	  }
    setTxtProgressBar(pb, i)
  }
}
close(pb)

print(paste(' ... done with the risk assessment!',sep=''))

  return(vanDantzig.ensemble)
}

##==============================================================================
## End
##==============================================================================
