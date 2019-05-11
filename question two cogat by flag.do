// Project Kaleidoscope
// Javits June 2018 Data Project
// Author: Andrew McCartney
// Editors: Michael Hull; Tonya Moon
// Initial Commit: 06/04/18
// Last Updated: 08/24/18


// read in data set 
global drive C:\Users\mccar\Desktop\summer intersession\Data Summaries\June2018project
cd "${drive}"

// if new data have been added since last run:
do javits_data_clean
// then
do javits_data_merge



cd "${drive}/Data Files"
use PK_Student_Data_AllYears,clear
cd "${drive}"

drop CO CP

/*
do do_impute
*/


// Question 2 Analysis
// Differences on CogAT results based on flagged by PK or not 
// Both tx and comparison schools


*______________________________________________________________________________*

// TODO: 
// 1) Standardize PALS scores within fauquier sample (DONE by ANDREW on JUNE 6)
// 2) Data Needs: 
//		A) Who is pulled out for GRT enrichment (covariate?) (missing Walter '17;
//			Kerri will obtain by end of week hopefully) 
//			i) once Kerri has this--what's the crossover between flagged and 
//				pull-out status? 
				table school_year  identified_by_pk // receiving_GRT_services_at_school
//			ii) in first year it is low-- second year CVT issue
// 		B) Student-level FRP or Economic Disadvantage designation (Per TRM: Cannot use) 
//		C) Bring in SpEd status (Andrew can include) (DONE by ANDREW on JUNE 5) 
//		D) Fix PALS == 0 Scores--what generates these? 
// 3) Calculate classroom (teacher by year) ICCs (DONE by ANDREW on JUNE 5)
//		A) use to determine multilevel model or not (DONE by MICHAEL on JUNE 6)

// 4) Basic Descriptive statistics for all groups on all assessments
//		A) means, sds, skewness and kurtosis (DONE by ANDREW on JUNE 5)
// 5) Figures? 
//		A) boxplots of descriptives (as outlier check) (DONE by ANDREW on JUNE 5)
// 6) Models:
// 		A) with and without robust standard errors. Any change in coefficients or SEs? 
//		B) model building: add demos first and then covariates, or covs first and then 
//			demographics, etc.
//		C) Flagged + GRTPullout + flagged*GRTPullout 
//

*______________________________________________________________________________*


// Select cohort
capture drop cohort
gen 	cohort = 1 if grade == "2" & school_year == 2017
replace cohort = 2 if grade == "1" & school_year == 2017
replace cohort = 3 if grade == "0" & school_year == 2017
replace cohort = 4 if grade == "P" & school_year == 2017
replace cohort = 1 if grade == "1" & school_year == 2016
replace cohort = 2 if grade == "0" & school_year == 2016
replace cohort = 3 if grade == "P" & school_year == 2016
replace cohort = 1 if grade == "0" & school_year == 2015
replace cohort = 2 if grade == "P" & school_year == 2015
replace cohort = 5 if grade == "P" & school_year == 2018
replace cohort = 4 if grade == "0" & school_year == 2018
replace cohort = 3 if grade == "1" & school_year == 2018
replace cohort = 2 if grade == "2" & school_year == 2018
replace cohort = 1 if grade == "3" & school_year == 2018
table 	cohort school_year
* drop if cohort != 2 // Cohort that was in K last year and First grade this year

replace disability = 0 if disability == 1 
replace disability = 1 if disability == 4 
replace disability = 1 if disability == 5
replace disability = 1 if disability == 6
replace disability = 1 if disability == 7
replace disability = 1 if disability == 8 
replace disability = 1 if disability == 9
replace disability = 1 if disability == 10 
replace disability = 1 if disability == 11 
replace disability = 1 if disability == 13 
replace disability = 1 if disability == 15
replace disability = 1 if disability == 16  
replace disability = 1 if disability == 19 
label values disability yesno
table disability
// fixed. 


//// assuming minority = ((not (white or asian)) | (hispanic))
gen min = 0 if 	race == 2 | race     == 5 	| race == 12   // 12 = biracial asian+white
replace min = 1 if race == 1
replace min = 1 if race == 3
replace min = 1 if race == 9 
replace min = 1 if race == 14
replace min = 1 if race == 16
replace min = 1 if hispanic == 1
label values min yesno
table min


// balance: 
table school_year identified_by_pk


// generate different values for different PALS
gen PALS_fall_kg 	= f_pals_sum_score if cohort == 2 & grade == "0"
gen PALS_spring_kg 	= s_pals_sum_score if cohort == 2 & grade == "0"
gen PALS_fall_1 	= f_pals_sum_score if cohort == 2 & grade == "1"
gen PALS_spring_1	= s_pals_sum_score if cohort == 2 & grade == "1"
gen PALS_fall_2		= f_pals_sum_score if cohort == 2 & grade == "2"
gen PALS_spring_2	= s_pals_sum_score if cohort == 2 & grade == "2" 

// 1) Standardize PALS scores within fauquier sample

** NOTE **
// this will require standardizing across 5 administrations (later, 6?) 
// and won't work with just the cohort 2 data

su  f_pals_sum_score if grade == "0"
// 		mu = 55.26483	sigma = 25.20546
su  s_pals_sum_score if grade == "0"
//		mu = 93.52691	sigma = 12.47693
su  f_pals_sum_score if grade == "1" 
//		mu = 59.43046	sigma = 15.77939
su  s_pals_sum_score if grade == "1"
//		mu = 51.2797	sigma = 13.46929
su  f_pals_sum_score if grade == "2"
//		mu = 48.46575	sigma = 14.63575
su  s_pals_sum_score if grade == "2"
//		mu = 64.2438	sigma = 13.65535

// Z-Transformations
capture drop zpals*
gen zpals_fall_k	=	(f_pals_sum_score-55.26483)/25.20546 if grade == "0"
gen zpals_spring_k	=	(s_pals_sum_score-93.52691)/12.47693 if grade == "0"
gen zpals_fall_1	=	(f_pals_sum_score-59.43046)/15.77939 if grade == "1"
gen zpals_spring_1	=	(s_pals_sum_score-51.2797 )/13.46929 if grade == "1"
gen zpals_fall_2	=	(f_pals_sum_score-48.46575)/14.63575 if grade == "2"
gen zpals_spring_2	=	(s_pals_sum_score-64.2438) /13.65534 if grade == "2"



// all later analyses on cohort 2 only
drop if cohort != 2 // Cohort that was in K last year and First grade this year
drop if treatment !=1
di _N

// easier to remember variable names
capture rename identified_by_pk  flagged 
capture rename receiving_GRT_services_at_school grtpullout  
capture gen flagged_grtpullout = flagged*grtpullout
capture rename cogat_sas_verbal cogat_verbal
capture rename cogat_sas_quantitative cogat_quant
capture rename cogat_sas_nonverbal cogat_nonverb
capture rename cogat_sas_composite cogat_composite






// 3) Calculate classroom (teacher by year) ICCs
//		A) use to determine multilevel model or not


gen classroom = teacher + school_year
tostring(classroom), replace 	// disallows regression on classroom as numeric
								// ergo requires dummies for effects
table classroom 


// icc dap_scaled_score classroom //if cohort == 2 & treatment == 1
// why doesn't this work?


// DAP
xtmixed dap_scaled_score || classroom: , var

* Icc = var(_cons) / (var(_cons) + var(residual))
di 13.47958 / (13.47958+161.0726)
di 13.78678 / (13.78678 + 180.2549)

/*
. di 13.47958 / (13.47958+161.0726)
ICC = .07722378
*/

// PALS kg fall
xtmixed PALS_fall_kg || classroom: , var

* Icc = var(_cons) / (var(_cons) + var(residual))
di 73.27389 / (73.27389 + 563.4224)
/*
. di 73.27389 / (73.27389 + 563.4224)
ICC = .11508452
*/ 


// PALS g1 fall
xtmixed PALS_fall_1 || classroom: , var

* Icc = var(_cons) / (var(_cons) + var(residual))
di 50.70023 / (50.70023 + 223.7823)
/*
. di 50.70023 / (50.70023 + 223.7823)
ICC = .18471205

*/

// CogAT composite
xtmixed cogat_sas_composite || classroom: , var

* Icc = var(_cons) / (var(_cons) + var(residual))
di 23.38931 / (23.38931 + 220.5794 )
/*
. di 23.38931 / (23.38931 + 220.5794 )
ICC = .09587012
*/














// 4) Basic Descriptive statistics for all groups on all assessments
//		A) means, sds, skewness and kurtosis


do do_summaries // summaries of PALS, DAP, CogAT by race, gender, latinx, school.
				// generates two lists for years 2016-2017 and 2017-2018


				
table school_year flagged if treatment == 1				
				


				
				
				
// 5) Figures? 
//		A) boxplots of descriptives (as outlier check)
cd "${drive}"
do do_boxplots
do do_histograms
// these are just temporary for outlier checks
// Visualizations will be in R with ggplot2.












// 6) Models:
// 		A) with and without robust standard errors. Any change in coefficients or SEs? 
//		B) model building: add demos first and then covariates, or covs first and then 
//			demographics, etc.
//		C) Flagged + GRTPullout + flagged*GRTPullout 
//






// race dummies
tab race, gen(race_)
label var race_1 "AmIndian"
label var race_2 "Asian"
label var race_3 "BlackAA"
label var race_4 "White"
label var race_5 "NHorOPI"
label var race_6 "AmIndian&Black"
label var race_7 "AmIndian&White"
label var race_8 "Asian&black"
label var race_9 "Asian&White"
label var race_10 "BlackAA&White"
label var race_11 "NHorOPI&White"
label var race_12 "NHorOPI&un"
label var race_13 "NHorOPI&un"

//// Assessments Only
**NOTE**
// this will require widening the data set by student to allow for time-variant
// PALS scores
//reshape wide stubnames, i(varlist) j(varname)
// drop problematic observations
drop if sti_number =="" | sti_number=="1018142231" | sti_number=="101794" | sti_number=="1017946753" | sti_number=="1017946823" | sti_number=="1018094058" 
drop if teacher == 505
// drop pk observations & frasier
capture drop f_pk* m_pk* s_pk* frasier* Summer_frasier*
capture drop if school_year == .
reshape wide treatment-min,i(sti_number) j(school_year)
di _N

gen grtpullever = grtpullout2016 + grtpullout2017
replace grtpullever = 1 if grtpullever == 2
table grtpullever




global demographics gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016
global assessments zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017
di ${demographics}
di ${assessments}

/*
Based on the ICCs we will need to account for clustering. Since we are not 
interested in making inferences at the upper level, there are a few ways to do 
this. The first, and most straight forward is to run the regression using the 
cluster option:
*/
 

//// Demographics Only 
 
// regress varlist, cluster(teacher id var)

// demographic predictors only
reg cogat_sas_composite gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services, cluster(classroom)
reg cogat_sas_quantitative gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services, cluster(classroom)
reg cogat_sas_nonverbal gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services, cluster(classroom)
reg cogat_sas_verbal gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services, cluster(classroom)
  
/*
With this method we will only be adjusting the standard error estimates, the 
coefficients will remain the same as a regression without adjusting for 
clustering. Another method is to use a linear mixed model; Stata’s equivalent 
to a HLM model:
*/
 
// xtmixed varlist || teacher id var:, mle
xtmixed cogat_sas_composite gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services || classroom:, mle
xtmixed cogat_sas_quantitative gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services || classroom:, mle
xtmixed cogat_sas_nonverbal gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services || classroom:, mle
xtmixed cogat_sas_verbal gender race_1-race_3 race_5-race_8 hispanic f_pals_esl_services || classroom:, mle

 

 
// assessments varlist:
// zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 dap_scaled_score2016 dap_scaled_score2017
// regress varlist, cluster(teacher id var)

// assessment predictors only
**NOTE**
// clustering for kinder teacher only :( 
reg cogat_sas_composite2017 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017, cluster(teacher2016)
reg cogat_sas_quantitative2017 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017, cluster(teacher2016)
reg cogat_sas_nonverbal2017 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017, cluster(teacher2016)
reg cogat_sas_verbal2017 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017, cluster(teacher2016)
 
/*
. reg cogat_sas_verbal2017 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_
> score2017, cluster(teacher2016)

Linear regression                               Number of obs     =        274
                                                F(6, 16)          =      99.52
                                                Prob > F          =     0.0000
                                                R-squared         =     0.3279
                                                Root MSE          =     10.157

                                   (Std. Err. adjusted for 17 clusters in teacher2016)
--------------------------------------------------------------------------------------
                     |               Robust
cogat_sas_verbal2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------------+----------------------------------------------------------------
    zpals_fall_k2016 |   .0964143   .9229644     0.10   0.918    -1.860183    2.053011
  zpals_spring_k2016 |  -1.171522   .8119883    -1.44   0.168     -2.89286    .5498162
    zpals_fall_12017 |   3.661043   1.457382     2.51   0.023     .5715311    6.750556
  zpals_spring_12017 |   1.528055   1.312665     1.16   0.261     -1.25467     4.31078
dap_scaled_score2016 |   .2728144   .0430218     6.34   0.000     .1816123    .3640164
dap_scaled_score2017 |   .1134894   .0405753     2.80   0.013     .0274735    .1995052
               _cons |   58.30353   6.445303     9.05   0.000      44.6401    71.96696
--------------------------------------------------------------------------------------


**** NOTE:****
// find out what is going on with the PALS in fall of first grade--the test is slightly
// different from all other PALS; be ready to note what those exact differences are. 
*/ 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/*
With this method we will only be adjusting the standard error estimates, the 
coefficients will remain the same as a regression without adjusting for 
clustering. 
*/
 

reg cogat_composite2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
	dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
	f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)
/*

. reg cogat_composite2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
>         dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
>         f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)

Linear regression                               Number of obs     =        286
                                                F(11, 15)         =     177.58
                                                Prob > F          =     0.0000
                                                R-squared         =     0.4918
                                                Root MSE          =     9.7352

                                      (Std. Err. adjusted for 16 clusters in teacher2016)
-----------------------------------------------------------------------------------------
                        |               Robust
    cogat_composite2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   1.766856   1.284707     1.38   0.189     -.971432    4.505143
       zpals_fall_k2016 |   1.926916   1.148601     1.68   0.114    -.5212687    4.375101
       zpals_fall_12017 |   3.024471   .7426021     4.07   0.001     1.441653     4.60729
   dap_scaled_score2016 |   .1899023   .0653223     2.91   0.011     .0506712    .3291334
   dap_scaled_score2017 |   .0447342   .0433515     1.03   0.318    -.0476672    .1371357
             gender2017 |  -1.017282   .9938332    -1.02   0.322    -3.135587    1.101024
                min2017 |  -2.929485   1.402102    -2.09   0.054    -5.917994    .0590242
            dap_age2016 |  -.7615958   .1945512    -3.91   0.001    -1.176272   -.3469197
f_pals_esl_services2017 |    3.66189   2.019405     1.81   0.090    -.6423702     7.96615
         disability2017 |   -.731914    1.67053    -0.44   0.668    -4.292564    2.828736
            grtpullever |   11.75041   1.959131     6.00   0.000     7.574622     15.9262
                  _cons |   124.2808   15.59083     7.97   0.000     91.04973    157.5119
-----------------------------------------------------------------------------------------


*/	
reg cogat_verbal2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
	dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
	f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)
/*
. reg cogat_verbal2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
>         dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
>         f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)

Linear regression                               Number of obs     =        286
                                                F(11, 15)         =     256.10
                                                Prob > F          =     0.0000
                                                R-squared         =     0.4108
                                                Root MSE          =     9.5545

                                      (Std. Err. adjusted for 16 clusters in teacher2016)
-----------------------------------------------------------------------------------------
                        |               Robust
       cogat_verbal2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   .6218857   1.347282     0.46   0.651    -2.249777    3.493549
       zpals_fall_k2016 |   .1487553   1.174213     0.13   0.901     -2.35402    2.651531
       zpals_fall_12017 |   3.514448   .8595339     4.09   0.001     1.682395    5.346501
   dap_scaled_score2016 |   .2478758   .0602433     4.11   0.001     .1194702    .3762814
   dap_scaled_score2017 |   .0271211   .0439128     0.62   0.546    -.0664769     .120719
             gender2017 |  -.0566741   1.254228    -0.05   0.965    -2.729998     2.61665
                min2017 |  -3.183896   1.243984    -2.56   0.022    -5.835386   -.5324056
            dap_age2016 |  -.5858246   .1745767    -3.36   0.004     -.957926   -.2137232
f_pals_esl_services2017 |   2.992252   2.557112     1.17   0.260    -2.458103    8.442607
         disability2017 |   .0105543   2.313513     0.00   0.996    -4.920582    4.941691
            grtpullever |   7.680448   2.207701     3.48   0.003     2.974845    12.38605
                  _cons |   109.2857   13.76556     7.94   0.000     79.94513    138.6263
-----------------------------------------------------------------------------------------




*/

reg cogat_nonverb2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
	dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
	f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)
margins
marginsplot
avplots

/*
. reg cogat_nonverb2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
>         dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
>         f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)

Linear regression                               Number of obs     =        286
                                                F(11, 15)         =      62.73
                                                Prob > F          =     0.0000
                                                R-squared         =     0.4254
                                                Root MSE          =     10.296

                                      (Std. Err. adjusted for 16 clusters in teacher2016)
-----------------------------------------------------------------------------------------
                        |               Robust
      cogat_nonverb2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   3.421141   1.330267     2.57   0.021     .5857441    6.256537
       zpals_fall_k2016 |    2.75018   .9518195     2.89   0.011     .7214251    4.778935
       zpals_fall_12017 |   2.355976   .5836891     4.04   0.001     1.111872     3.60008
   dap_scaled_score2016 |   .1129794   .0710343     1.59   0.133    -.0384267    .2643855
   dap_scaled_score2017 |   .0693898   .0392406     1.77   0.097    -.0142495    .1530292
             gender2017 |  -.3180496   1.206827    -0.26   0.796     -2.89034    2.254241
                min2017 |  -.9179573   1.297768    -0.71   0.490    -3.684084     1.84817
            dap_age2016 |  -.7783179   .2115914    -3.68   0.002    -1.229314   -.3273215
f_pals_esl_services2017 |   2.704996   1.245475     2.17   0.046     .0503277    5.359664
         disability2017 |   .2948902   1.920266     0.15   0.880     -3.79806    4.387841
            grtpullever |    11.0281      1.777     6.21   0.000     7.240514    14.81569
                  _cons |   128.6026   16.71686     7.69   0.000     92.97145    164.2337
-----------------------------------------------------------------------------------------



. di "Cohen's d =" 3.41/16
Cohen's d =.213125




*/
reg cogat_quant2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
	dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
	f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)
/*

. reg cogat_quant2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
>         dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
>         f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)

Linear regression                               Number of obs     =        286
                                                F(11, 15)         =      39.64
                                                Prob > F          =     0.0000
                                                R-squared         =     0.3868
                                                Root MSE          =     11.214

                                      (Std. Err. adjusted for 16 clusters in teacher2016)
-----------------------------------------------------------------------------------------
                        |               Robust
        cogat_quant2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   .1428171    1.73835     0.08   0.936    -3.562388    3.848022
       zpals_fall_k2016 |   2.219353   1.486283     1.49   0.156    -.9485841    5.387289
       zpals_fall_12017 |   2.207791   .9819483     2.25   0.040     .1148178    4.300764
   dap_scaled_score2016 |   .1722447    .076699     2.25   0.040     .0087646    .3357247
   dap_scaled_score2017 |   .0029909   .0585198     0.05   0.960    -.1217411    .1277228
             gender2017 |  -2.554297   .9037528    -2.83   0.013    -4.480601   -.6279938
                min2017 |  -4.404462   1.774995    -2.48   0.025    -8.187775   -.6211486
            dap_age2016 |  -.8072764   .2034166    -3.97   0.001    -1.240849   -.3737041
f_pals_esl_services2017 |   4.194024   2.327023     1.80   0.092    -.7659083    9.153956
         disability2017 |  -2.095792   2.184877    -0.96   0.353    -6.752747    2.561162
            grtpullever |   11.04091   1.813649     6.09   0.000      7.17521    14.90661
                  _cons |   137.0318   17.97326     7.62   0.000     98.72268    175.3409
-----------------------------------------------------------------------------------------





*/	
capture drop used
gen used = 1 if cogat_composite2017 != . & flagged2016 != . & zpals_fall_k2016 != . & zpals_fall_12017 != . & dap_scaled_score2016 != . & dap_scaled_score2017 != . & gender2017 != . & min2017 != . & dap_age2016 != . & f_pals_esl_services2017 != . & disability2017 != . & grtpullever!= . 
replace used = 0 if used != 1

tab used


 
do do_demo_tables // demographic tables by flagged / not-flagged / total
 



reg cogat_nonverb2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  ///
	dap_scaled_score2016 dap_scaled_score2017 gender2017  min2017 dap_age2016  ///
	f_pals_esl_services2017 disability2017 grtpullever, cluster(teacher2016)
avplot flagged2016
avplot min2017
avplot grtpullever
avplot disability2017
avplot dap_age2016



























// Earlier models















xtmixed cogat_nonverb2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  dap_scaled_score2016 dap_scaled_score2017 gender2016 min2017 dap_age2016 f_pals_esl_services2017 disability2016 || teacher2016:, mle

/*
. xtmixed cogat_nonverb2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_s
> core2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016, cluster(
> teacher2016)
note: race_52016 dropped because of collinearity
note: race_62016 dropped because of collinearity
note: race_82016 dropped because of collinearity

Mixed-effects regression                        Number of obs     =        274

                                                Wald chi2(16)     =          .
Log pseudolikelihood = -1035.5622               Prob > chi2       =          .

                                      (Std. Err. adjusted for 17 clusters in teacher2016)
-----------------------------------------------------------------------------------------
                        |               Robust
      cogat_nonverb2017 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   3.564633   1.318589     2.70   0.007     .9802458     6.14902 **
       zpals_fall_k2016 |   3.609293   1.078282     3.35   0.001     1.495898    5.722688 **
     zpals_spring_k2016 |   .3712022   .9277124     0.40   0.689    -1.447081    2.189485
       zpals_fall_12017 |   2.339363   .9554288     2.45   0.014     .4667572    4.211969 *
     zpals_spring_12017 |   .9314211   1.074555     0.87   0.386    -1.174668     3.03751
   dap_scaled_score2016 |   .1282995   .0726751     1.77   0.077    -.0141411    .2707401
   dap_scaled_score2017 |   .0801745   .0458654     1.75   0.080      -.00972     .170069
             gender2016 |  -.9384111   1.260338    -0.74   0.457    -3.408628    1.531806
             race_12016 |   18.73222   6.174279     3.03   0.002     6.630852    30.83358 **
             race_22016 |   14.27846   2.518153     5.67   0.000     9.342973    19.21395 ***
             race_32016 |   14.64838   1.635455     8.96   0.000     11.44294    17.85381 ***
             race_42016 |   15.82004   1.755177     9.01   0.000     12.37996    19.26012 ***
             race_72016 |   14.97066   5.537953     2.70   0.007     4.116474    25.82485 **
            dap_age2016 |  -.7693283   .1876939    -4.10   0.000    -1.137202   -.4014551 ***
           hispanic2016 |     1.1488   2.082871     0.55   0.581    -2.933551    5.231152
f_pals_esl_services2016 |  -5.148662    2.94008    -1.75   0.080    -10.91111    .6137879
f_pals_esl_services2017 |   4.845923   2.933167     1.65   0.099    -.9029797    10.59482
         disability2016 |  -.0587275   .1305412    -0.45   0.653    -.3145836    .1971286
                  _cons |    111.961   18.12733     6.18   0.000     76.43213      147.49 ***
-----------------------------------------------------------------------------------------

------------------------------------------------------------------------------
                             |               Robust           
  Random-effects Parameters  |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------+------------------------------------------------
                sd(Residual) |    10.5961   .6125705      9.461002    11.86738
------------------------------------------------------------------------------





*/

// treatment on treated 

ivregress 2sls cogat_composite2017 attended_summer2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)
ivregress 2sls cogat_verbal2017 attended_summer2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)
ivregress 2sls cogat_nonverb2017 attended_summer2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)
ivregress 2sls cogat_quant2017 attended_summer2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)


/*


*/
xtmixed cogat_verbal2017 attended_summer2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016 || teacher2016:, mle
xtmixed cogat_quant2017 attended_summer2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016 || teacher2016:, mle


xtmixed cogat_composite2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016 || teacher2016:, mle
xtmixed cogat_verbal2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016 || teacher2016:, mle
xtmixed cogat_nonverb2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  dap_scaled_score2016 dap_scaled_score2017 gender2016 min2017 dap_age2016  f_pals_esl_services2017 disability2016 || teacher2016:, mle
xtmixed cogat_quant2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016 || teacher2016:, mle













//
tab cohort, gen(cohort_)
tab school, gen(school_)
tab school_year, gen(schoolyr_)
rename school_year schyr

egen zpals_f = rowmean(zpals_fall_k  zpals_fall_1  zpals_fall_2)
egen zpals_s = rowmean(zpals_spring_k  zpals_spring_1  zpals_spring_2)



xtmixed dap_scaled_score || classroom: , var
xtmixed dap_scaled_score gender min disability cohort_2 cohort_3 schoolyr_2 zpals_f f_pals_esl_services || classroom: school_*, mle

gen zpals_i = zpals_f*zpals_s
xtmixed dap_scaled_score zpals_f zpals_s  || classroom: school_2 school_5 school_8 school_11, mle
margins
marginsplot zpals_f zpals_s







































