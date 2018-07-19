##==============================================================================
## GrabOutputFiles.R
##
## Handy script to grab the output files from Wong and Keller (2017)
## that are too large to be included with the Github repository.
##
## Original code: 10 July 2018
##
## Questions? Tony Wong (anthony.e.wong@colorado.edu)
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

dl.path <- 'https://download.scrim.psu.edu/Wong_etal_BRICK/NOLA_Wong_etal_2017/'

# output that belongs in output_model directory
download.file(paste(dl.path,'output_model/VanDantzig_fd-gamma_2065_08May2017.nc',sep=''),
              '../output_model/VanDantzig_fd-gamma_2065_08May2017.nc', method='curl')
download.file(paste(dl.path,'output_model/VanDantzig_fd-uniform_2065_08May2017.nc',sep=''),
              '../output_model/VanDantzig_fd-uniform_2065_08May2017.nc', method='curl')
download.file(paste(dl.path,'output_model/VanDantzig_fd-none_2065_08May2017.nc',sep=''),
              '../output_model/VanDantzig_fd-none_2065_08May2017.nc', method='curl')

download.file(paste(dl.path,'output_model/BRICK_physical_fd-gamma_08May2017.nc',sep=''),
              '../output_model/BRICK_physical_fd-gamma_08May2017.nc', method='curl')
download.file(paste(dl.path,'output_model/BRICK_physical_fd-uniform_08May2017.nc',sep=''),
              '../output_model/BRICK_physical_fd-uniform_08May2017.nc', method='curl')
download.file(paste(dl.path,'output_model/BRICK_physical_allslr_08May2017.nc',sep=''),
              '../output_model/BRICK_physical_allslr_08May2017.nc', method='curl')

# output that belongs in the output_calibration directory
download.file(paste(dl.path,'output_calibration/rho_simple_fixed_07May2017.csv',sep=''),
              '../output_calibration/rho_simple_fixed_07May2017.csv', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_calibratedParameters_07May2017.nc',sep=''),
              '../output_calibration/BRICK_calibratedParameters_07May2017.nc', method='curl')

download.file(paste(dl.path,'output_calibration/DAISfastdyn_calibratedParameters_uniform_29Jan2017.nc',sep=''),
              '../output_calibration/DAISfastdyn_calibratedParameters_uniform_29Jan2017.nc', method='curl')
download.file(paste(dl.path,'output_calibration/DAISfastdyn_calibratedParameters_gamma_29Jan2017.nc',sep=''),
              '../output_calibration/DAISfastdyn_calibratedParameters_gamma_29Jan2017.nc', method='curl')

download.file(paste(dl.path,'output_calibration/BRICK_postcalibratedParameters_fd-uniform_08May2017.nc',sep=''),
              '../output_calibration/BRICK_postcalibratedParameters_fd-uniform_08May2017.nc', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_postcalibratedParameters_fd-gamma_08May2017.nc',sep=''),
              '../output_calibration/BRICK_postcalibratedParameters_fd-gamma_08May2017.nc', method='curl')

download.file(paste(dl.path,'output_calibration/BRICK_estimateGEV-AnnMean_12Apr2017.nc',sep=''),
              '../output_calibration/BRICK_estimateGEV-AnnMean_12Apr2017.nc', method='curl')

download.file(paste(dl.path,'output_calibration/BRICK_Sobol-1-tot_04Aug2017-Build-AIS-2065.txt',sep=''),
              '../output_calibration/BRICK_Sobol-1-tot_04Aug2017-Build-AIS-2065.txt', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_Sobol-1-tot_04Aug2017-Build-AIS-GEV-2065.txt',sep=''),
              '../output_calibration/BRICK_Sobol-1-tot_04Aug2017-Build-AIS-GEV-2065.txt', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_Sobol-1-tot_06Aug2017-Build-GEV-2065.txt',sep=''),
              '../output_calibration/BRICK_Sobol-1-tot_06Aug2017-Build-GEV-2065.txt', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_Sobol-2_04Aug2017-Build-AIS-2065.txt',sep=''),
              '../output_calibration/BRICK_Sobol-2_04Aug2017-Build-AIS-2065.txt', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_Sobol-2_04Aug2017-Build-AIS-GEV-2065.txt',sep=''),
              '../output_calibration/BRICK_Sobol-2_04Aug2017-Build-AIS-GEV-2065.txt', method='curl')
download.file(paste(dl.path,'output_calibration/BRICK_Sobol-2_06Aug2017-Build-GEV-2065.txt',sep=''),
              '../output_calibration/BRICK_Sobol-2_06Aug2017-Build-GEV-2065.txt', method='curl')

##==============================================================================
## End
##==============================================================================
