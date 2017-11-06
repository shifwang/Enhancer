# iRF simulations and data analyses

This repository contains scripts to run the simulations and case studies
described in *iterative Random Forests to discover predictive and stable
high-order interactions*.

* `enhancer.R`: R script used to run `iRF` on the enhancer data.
* `splicing.R`: R script used to run `iRF` on the splicing data.
* `simulations/booleanSimulations.R`: R script used to run `iRF` on simulated
  data using the boolean generative modesl described in the paper.
* `simulations/enhancerSimulations.R`: R script used to run `iRF` on simulated
  enhancer data as described in the paper.
* `runtime/irf.R`: R script used to run the runtime analysis for iRF.
* `runtime/rulefit.R`: R script used to run the runtime analysis for rulefit.
* `runtime/rulefit`: R package for running rulefit, also available through:
  http://statweb.stanford.edu/~jhf/R_RuleFit.html. Note, the package here is set
  up for use on linux systems.

Data for the above analyses are included in the `data` directory.

* `irfSuppData1.csv`: Processed data for the enhancer case study 
  (Supporting Data 1).
* `irfSuppData2.csv`: Description of the splicing assays including 
  ENCODE accession number, assay name, and assay type (Supporting Data 2).
* `irfSuppData3.csv`: Processed data used for the splicing case study 
  (Supporting Data 3).
* `enhancer.Rdata`: data used for the enhancer case study
  * `X`: 7809 x 80 feature matrix providing measurements for each assay at a
    given genomic region. Columns 1-38 and 43-45 represent histone marks,
    columns 39-42 control assays, and columns 46-80 TFs.
  * `Y`: length 7809 response vector, 1 indicating active element.
  * `train.id`: length 3912 vector giving the indices of training observations.
  * `test.id`: length 3897 vector giving the indices of testing observations.
  * `varnames.all`: 80 x 2 data frame, the first column giving a unique
    identifier for each assay and the second column giving collapsed terms used
    to group replicate assays.

* `splice.Rdata`: data used for the splicing case study
  * `x`: 23823 x 270 feature matrix providing measurements for each assay for a
    given exon. Columns 1-254 represent TFs and columns 255-270 histone marks.
  * `y`: length 23823 response vector, 1 indicating a highly spliced exon.
  * `train.id`: length 11911 vector giving the indices of training observations.
  * `test.id`: length 11912 vector giving the indices of testing observations.
  * `varnames.all`: 270 x 2 data frame, the first column giving a unique 
    identifier for each assay and the second column giving collapsed terms used
    to group replicate assays.

* `rfSampleSplitNoise.Rdata`: data used for noising the enhancer simulation
  * `pred.prob`: 7809 x 20 matrix, giving the predicted probability that each
    genomic element is active. These probabilities were generated using the
    sample splitting procedure described in S4.4 and used to noise the enhancer
    simulation.
