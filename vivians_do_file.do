*********************************************
*		Field Experiments					*
*		Analysis of RCTs	 				*
* 		Activity							*
*		Vivian Wong							*
*		3/18/2014							*
*********************************************

* Change directory file 
cd "/Users/vcw2n/Box Sync/Box Sync/Field Experiments/Fall 2017/Week 9 Data Analysis"

* Open data
use class_workingstar.dta, clear

* Look at the nested data structure of the data
*browse

* Look at variables in your dataset
describe
sum

*************************************************************
** Part 1: Check Assumptions for RCT 
*************************************************************

** Assumption 1: Independence **

* Simple Balance Check based on sample means
sum k_female k_frl k_white k_black k_sped k_pullout tk_frl if t_smallclass == 1
sum k_female k_frl k_white k_black k_sped k_pullout tk_frl if t_smallclass == 0

/* To examine balance, analyze the baseline covariates as you would analyze the outcomes
For example: if you have a randomized block design, include the blocks in the model
Use an F-test to test the joint null hypothesis that all baseline covariates = 0 
See the two methods below. */

* Method 1: Run a regression (with block fixed effects if there are blocks), perform incremental f-test
reg t_smallclass k_female k_frl tk_frl k_white k_black k_sped k_pullout i.schid, vce(cluster schid)
test k_female k_frl tk_frl k_white k_black k_sped k_pullout 

* Method 2: Stacked Regressions 
* It provides control values for baseline covariates, and differences in means. 
* But the standard errors do not account for clustered data structure. 
set matsize 1000
mvreg  k_female k_frl tk_frl k_white k_black k_sped k_pullout = t_smallclass i.schid
test t_smallclass 

** Make a balance plot of effect size differences to summarize your results 
include "cov_balance_unwt.do"
local covariates k_female k_frl tk_frl k_white k_black k_sped k_pullout
ttest_cov_unwt, t(t_smallclass) c(`covariates') b(schid)

** Assumption 2: Exclusion Restriction **

* Check class size and assignment status 
tab class_size t_smallclass
table t_smallclass, c(mean class_size freq) format(%9.1f) 

* A2: Compare treatment receipt to treatment assignment
tab actual_smallclass t_smallclass

* A2: Check for overall attrition cases 
tab attrit

** A2: Check differential attrition by treatment cases
tab attrit t_smallclass

** A2: Check for compositional differences of kids who attrited by treatment group
table attrit, c(mean k_female mean k_frl mean tk_frl mean k_white freq) by(t_smallclass) format(%9.2f) 

** A3: Inteference **

/* One possible threat is Hawthrone/John Henry Effects
Construct a test by examining the effects of class size only among control classrooms
Note that this is not an automatic test for every RCT. You have to devise clever tests to probe 
assumptions based on context and threat to validity */

xtset schid
xtreg gkrank class_size if t_smallclass == 0, fe vce(cluster schid)

** Calculate the treatment effect by the average difference in class size (15 students) between small and regular 
display 7*_b[class_size]

* Asterisks this out if you do not want the do file to stop here. 
stop

*************************************************************
** Part 2: Find the ICC and Rs for the student and school covariates
*************************************************************

* Problem 1: Estimate the unconditional model
xtmixed gkrank || schid: , var

* Problem 2: Calculate R2^2 for School Level Covariates

* Create school-level mean covariates
egen k_female_mean = mean(k_female), by(schid)
egen k_frl_mean = mean(k_frl), by(schid)
browse schid stdntid k_female_mean k_female k_frl_mean k_frl

* Run mixed effects model with school-level covariates
xtmixed gkrank k_female_mean k_frl_mean || schid:   , var

* Problem 3: Calculate R1^2 for student Level Covariates
gen c_frl = k_frl - k_frl_mean
gen c_female = k_female - k_female_mean
browse schid stdntid k_female_mean k_female c_female k_frl_mean k_frl c_frl

* Run mixed effects model
xtmixed gkrank c_frl c_female || schid: , var

*************************************************************************************
** Part 3: Estimate RCT Treatment Effects for cluster and randomized block designs **
*************************************************************************************

** Analyzing Cluster RCTs **
* Caution: We are assuming that this is a cluster two level RCT design where students are nested in classes, and classes are randomly assigned.
* Caution: We are ignoring the school level clustering as a class exercise, but you should not do this in practice

* Estimate unconditional model using classid is the cluster variable 
xtmixed gkrank || classid: , var

* Cluster RCT with no covariates
xtmixed gkrank t_smallclass || classid: , var

* Cluster RCT with percentage of students FRL included
xtmixed gkrank t_smallclass tk_frl || classid: , var

* Cluster RCT with class and student level covariates:
xtmixed gkrank t_smallclass tk_frl  c_female || classid: , var

****************************************
** Analyzing randomized block designs **
****************************************
* Note: These are two level models where students are nested in schools, and treatment is at the student level

* Randomized block design with a fixed treatment
xtmixed gkrank t_smallclass || schid: , var

* Randomized block design with a random treatment
xtmixed gkrank t_smallclass || schid: t_smallclass , var cov(un)

* Randomized block design with cross-level interactions (treatment x unbanicity)
gen treat_innercity = t_smallclass*innercity
gen treat_suburban = t_smallclass*suburban
gen treat_urban = t_smallclass*urban

xtmixed gkrank t_smallclass innercity treat_innercity || schid:  t_smallclass, var cov(un)

* Randomized block design with Fixed Effects with three almost equivalent methods

** Create 80 school fixed effects
tab schid, gen(s)
** Run fixed effects model, omit one school fixed effect due to multicollinearity
** Standard errors are wrong here, but the coefficient is right
reg gkrank t_smallclass s2-s79

** Run fixed effects model with shortcut indicators for school, clustered standard errors
** Coefficient should be the same, but the standard errors now account for nested data
reg gkrank t_smallclass i.schid, vce(cluster schid)

** Instead of running a random effects model, run a fixed effects model
xtset schid
xtreg gkrank t_smallclass, fe vce(cluster schid)
