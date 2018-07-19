# BRICK v0.2 ![alt text](https://github.com/scrim-network/BRICK/blob/master/brick_logo.png "This is a brick!")


## Synopsis

BRICK (**B**uilding blocks for **R**elevant **I**ce and **C**limate **K**nowledge) is a modular semi-empirical modeling framework to simulate global temperature and sea-level rise. In the default model configuration, first, global mean surface temperature and ocean heat uptake are simulated by DOECLIM. Changes in global mean surface temperature drive changes in global mean sea level (GMSL). The contributions to GMSL from the Greenland and Antarctic ice sheets, thermal expansion, and glaciers and ice caps are simulated.

This repository contains the BRICK model source code and analysis scripts. Analysis codes and the main user interface are written in R and the main physics codes are in Fortran 90.

It contains the sub-models
* DOECLIM (Diffusion-Ocean-Energy CLIMate model)
* SNEASY (Simple Nonlinear EArth SYstem model)
* DAIS (Antarctic ice sheet)
* SIMPLE (Greenland ice sheet)
* GSIC-MAGICC (Glaciers and small ice caps)
* TE (thermal expansion)
* GMSL (Rahmstorf 2007, global mean sea level emulator)
* Van Dantzig flood risk assessment (Van Dantzig, 1956)

### An important note:

These codes are only for reproducing and expanding on the work done in [Wong and Keller (2017)](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1002/2017EF000607). If you want the latest and greatest BRICK codes, go check out the [main BRICK repository](https://github.com/scrim-network/BRICK) on Github.


## Directory structure

./
   * BRICK "home" directory

./calibration/
   * R scripts related to the (pre-/post-)calibration of the physical models, including reading data, likelihood functions, and sub-model stand-alone calibration drivers (some of these may be antiquated)
   * Other routines related to the analysis of calibrated model output

./data/
   * data for radiative forcing (DOECLIM) and calibration

./fortran/
   * Fortran versions of all physical models are available, and are wrapped in R calling functions in ./fortran/R/

./output_model/
   * physical model output (i.e., temperature, sea-level rise)

./output_calibration/
   * statistical model output (i.e., posterior parameter values)

./R/
   * models in R, as needed. No R versions of the main BRICK sea-level rise models, because they are too slow for large ensembles

## Workflow

<span style="font-size:30pt;font-weight:900">TODO - edit this to match Wong and Keller<span>

### To reproduce the work of Wong and Keller 2017

1. Checkout the model codes. 
~~~~
git clone https://github.com/tonyewong/NOLA_SLR_DeepUncertainty.git
~~~~

2. Create the dynamic libraries necessary to run the model in Fortran. You might need to modify the `Makefile` to use your preferred Fortran compiler. Further help can be found at `NOLA_SLR_DeepUncertainty/fortran/README`.
~~~~
cd NOLA_SLR_DeepUncertainty/fortran
mkdir obj
make
~~~~

3. Open R and install the relevant R packages.
~~~~
R
setwd('NOLA_SLR_DeepUncertainty/Useful')
source('InstallPackages.R')
~~~~

4. Calibrate the default BRICK model configuration (DOECLIM+SIMPLE+GSIC+TE) parameters using instrumental period data. This should not take longer than an hour or two on a modern multi-core computer.
~~~~
source('BRICK_calib_driver.R')
~~~~

Alternatively, you can submit this as a batch job to a cluster. The PBS script provided will require some modification for whatever machine you are using.
~~~~
qsub calib_brick.pbs
~~~~

5. Calibrate the DAIS parameters using paleoclimate data. This will take about 12 hours with a modern laptop.
~~~~
source('DAISfastdyn_calib_driver.R')
~~~~

Alternatively, you can use a similar batch submission script to run this on a cluster. That's probably preferably, if you care about not blowing out your laptop fan like a bad transmission. Note that this script will require modification, depending on the specifics of your machine.
~~~~
qsub calib_dais.pbs
~~~~

If you are reproducing the results from scratch, then you will need to run the `DAISfastdyn_calib_driver.R` routine two times: once with the `fd.priors` parameter equal to `g` (gamma prior distributions), and once with `fd.priors = u` (uniform prior distributions). These denote the type of prior distribution used for the Antarctic ice sheet fast dynamics parameters.

6. Combine modern and paleo calibration parameters, and calibrate the joint set to sea level data using rejection sampling; make hindcasts and projections of sea level; project local sea level for New Orleans, Louisiana (NOLA), to serve as input to assess flood risks in the next stage.

Note: if you run your own calibrations, files names must be edited to point to the correct files. By default, they point to the file names as used in the Wong and Keller 2017 paper. 

To fully reproduce all of the experiments from that work, you must run the `processingPipeline_BRICKscenarios.R` routine two times: once with `fd.priors = g` and once with `fd.priors = u`. The following file names will also need to be modified within the processing pipeline script if you are not using the standard results from Wong and Keller (2017), which are the defaults:
  * `filename.rho_simple_fixed` - the CSV file containing the fixed autocorrelation for the Greenland ice sheet; output from `BRICK_calib_driver.R`
  * `filename.BRICKcalibration` - the netCDF file output from `BRICK_calib_driver.R` containing the calibrated parameter estimates for the non-DAIS components of BRICK
  * `filename.DAIScalibration` - the netCDF file output from `DAIS_calib_driver.R` containing the calibrated parameter estimates for the DAIS model (paleo calibration)
  * `filename.gevstat` - calibrated estimates of stationary Generalized Extreme Value distribution parameters from the Grand Isle, Louisiana tide gauge station. As of this writing, there are only about 40 years of data from this site, so fitting a non-stationary GEV distribution is out of the question (see [Klufas et al. (2017)](https://arxiv.org/abs/1709.08776v1)).
  * by default, `l.dopaleo = FALSE` because we never presented the paleoclimate AIS simulations in the 2017 paper. If you want those simulations, change this to `TRUE`, but be prepared for a long run time.
  * if you want to modify this to assess flood hazard at other sites, change the `lat.fp` and `lon.fp` fingerprint latitude/longitude values in this script.
~~~~
source('processingPipeline_BRICKscenarios.R')
~~~~

Again, here is an alternative submission script to run this processing pipeline, because it might take a while:
~~~~
qsub postproc_brick.pbs
~~~~
Of course, you will need to modify some paths in that script.

7. Calibrate the GEV parameters and set up the Van Dantzig flood risk model. At this point, if you are producing your own calibrated projections instead of using the Wong and Keller (2017) ones, you will need to modify the following within `processingPipeline_VanDantzig_allScenarios.R`:
  * `filename.gamma` - the BRICK physical model output for the gamma prior distributions, from `processingPipeline_BRICKscenarios.R`
  * `filename.uniform` - the BRICK physical model output for the uniform prior distributions, from `processingPipeline_BRICKscenarios.R`
  * If you want to fit GEV distributions to the Grand Isle tide gauge data, then comment out the `filename.gevstat` and `filename.gevmcmc` lines. Otherwise, use the defaults which were fit for the Wong and Keller (2017) study.
~~~~
source('processingPipeline_VanDantzig_allScenarios.R')
~~~~

Here is a submission script to run this on a cluster:
~~~~
qsub postproc_vandantzig.pbs
~~~~
Of course, you will need to modify some paths in that script.

Note that the GEV parameters used in Wong and Keller (2017) are on the Van Dantzig output file ( **FILL IN HERE**). You can sample from the same one using the default file settings in this script.


8. Supplemental Sobol' sensitivity analyses

<span style="font-weight:900;font-size=33pt;color=red">TODO</span>

9. Supplemental Pensacola and Galveston tide gauge analysis, to asses the representation uncertainty associated with the data records.

<span style="font-weight:900;font-size=33pt;color=red">TODO</span>

10. Create plots and analysis, Wong and Keller (2017) study. Note: file names must be edited to point to the correct files, if you have run your own calibrations and analyses. Also note: the directory in which you save the plots must be changed to match somewhere on your own machine.
~~~~
source('analysis_and_plots_BRICKscenarios.R')
~~~~

Note that in each of these scripts, some edits will be necessary. These will include pointing at the proper file names. The BRICK and DAIS calibration driver scripts produce calibrated parameter files with date-stamps in their names. You will need to make sure the processing pipeline script points at the current calibrated parameters files. The processing pipeline script, in turn, produces several netCDF output files from your fully calibrated BRICK parameters. These file names also include date-stamps. You will need to make sure the analysis and plotting script points at the current files. You will also need to modify the directory in which your plots will be saved.

## Contributors

Please enjoy the code and offer us any suggestions. It is our aim to make the model accessible and usable by all. We are always interested to hear about potential improvements to the model, both in the statistical calibration framework as well as the physical sub-models for climate and contributions to sea-level rise.

Questions? Tony Wong (<anthony.e.wong@colorado.edu>)

## License

Copyright 2016 Tony Wong, Alexander Bakker

This file is part of BRICK (Building blocks for Relevant Ice and Climate Knowledge). BRICK is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

BRICK is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with BRICK.  If not, see <http://www.gnu.org/licenses/>.
