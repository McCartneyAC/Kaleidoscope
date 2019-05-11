// Multiple Imputation Procedures
// Andrew McCartney and Michael Hull

global drive C:\Users\mccar\Desktop\summer intersession\Data Summaries\June2018project
cd "${drive}/Data Files"
use PK_Student_Data_AllYears,clear
cd "${drive}"

**** NOTE: ****
// this imputation is meant to be used only on cohort 2, but can be run with all
// cohorts given appropriate changes made. 

gen 	cohort = 1 if grade == "2" & school_year == 2017
replace cohort = 2 if grade == "1" & school_year == 2017
replace cohort = 3 if grade == "0" & school_year == 2017
replace cohort = 4 if grade == "P" & school_year == 2017
replace cohort = 1 if grade == "1" & school_year == 2016
replace cohort = 2 if grade == "0" & school_year == 2016
replace cohort = 3 if grade == "P" & school_year == 2016
replace cohort = 1 if grade == "0" & school_year == 2015
replace cohort = 2 if grade == "P" & school_year == 2015
table 	cohort school_year
drop if cohort != 2 // Cohort that was in K last year and First grade this year

// gen classrooms
gen classroom = teacher + school_year
tostring(classroom), replace 	// disallows regression on classroom as numeric
								// ergo requires dummies for effects
table classroom 

**** NOTE: ****
// this also requires data to be re-shaped for longitudinal stuff:

// easier to remember variable names
capture rename identified_by_pk  flagged 
capture rename receiving_GRT_services_at_school grtpullout  
capture gen flagged_grtpullout = flagged*grtpullout
capture rename cogat_sas_verbal cogat_verbal
capture rename cogat_sas_quantitative cogat_quant
capture rename cogat_sas_nonverbal cogat_nonverb
capture rename cogat_sas_composite cogat_composite
// add z scores for PALS

capture drop zpals*
gen zpals_fall_k	=	(f_pals_sum_score-55.26483)/25.20546 if grade == "0"
gen zpals_spring_k	=	(s_pals_sum_score-93.52691)/12.47693 if grade == "0"
gen zpals_fall_1	=	(f_pals_sum_score-59.43046)/15.77939 if grade == "1"
gen zpals_spring_1	=	(s_pals_sum_score-51.2797 )/13.46929 if grade == "1"
gen zpals_fall_2	=	(f_pals_sum_score-48.46575)/14.63575 if grade == "2"
gen zpals_spring_2	=	(s_pals_sum_score-64.2438) /13.65534 if grade == "2"


// race dummies
/*
tab race, gen(race_)
label var race_1 "AmIndian"
label var race_2 "Asian"
label var race_3 "BlackAA"
label var race_4 "White"
label var race_5 "AmIndian&White"
label var race_6 "Asian&White"
label var race_7 "BlackAA&White"
label var race_8 "NHorOPI&White"
*/



gen maj = 1 if 	race == 2 | race     == 5 	| race == 12   // 12 = biracial asian+white
gen min = 1 if 	maj  != 1 | hispanic == 1
replace min = 0 if maj == 1 
table min

drop if sti_number =="" | sti_number=="1018142231"
// drop pk observations & frasier
capture drop f_pk* m_pk* s_pk* frasier* Summer_frasier*

// eliminate comparison schools
// drop all non-treatment kids
// drop if treatment != 1


// reshape
reshape wide treatment-min,i(sti_number) j(school_year)

replace disability2017 = 0 if disability2017 == 1 
replace disability2017 = 1 if disability2017 != 0 
table disability2017

**** NOTE:****
// this below versiondrops both late-arrivals into treatment AND attrition, 
// which may not match the proper imputation strategy

drop if treatment2016 != 1 | treatment2017 != 1

// Pre-Imputation Checks

// A) Calculate and note proportions of missingness by variable
mdesc cogat_nonverb2017 flagged2016 zpals_fall_k2016 zpals_fall_12017  dap_scaled_score2016 dap_scaled_score2017 gender2016 min2017 f_pals_esl_services2017 disability2016 if _mi_m == 0


/*
. mdesc cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score*

    Variable    |     Missing          Total     Percent Missing
----------------+-----------------------------------------------
   cogat_v~2017 |          62            416          14.90
   cogat_q~2017 |          62            416          14.90
   cogat_n~2017 |          62            416          14.90
   cogat_c~2017 |          62            416          14.90
   zpal~l_k2016 |          61            416          14.66
   zpal~g_k2016 |          71            416          17.07
   zpal~l_12017 |          54            416          12.98
   zpal~g_12017 |          70            416          16.83
   dap_sca~2016 |          75            416          18.03
   dap_sca~2017 |          60            416          14.42
----------------+-----------------------------------------------





*/

// B) Examine Missing Data Patterns 
mi set mlong
mi misstable summarize cogat*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score*
mi misstable summarize cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score* race_* f_pals_esl_services* dap_age* disability* *pals_reading_level2017 kbit_verbal2016 kbit_nonverbal2016 kbit_composite_score2016 

/*
. mi misstable summarize cogat*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score*
                                                               Obs<.
                                                +------------------------------
               |                                | Unique
      Variable |     Obs=.     Obs>.     Obs<.  | values        Min         Max
  -------------+--------------------------------+------------------------------
  cogat_v~2017 |        62                 354  |     61         66         137
  cogat_q~2017 |        62                 354  |     67         59         147
  cogat_n~2017 |        62                 354  |     62         65         160
  cogat_c~2017 |        62                 354  |     66         61         149
  zpal~l_k2016 |        61                 355  |     96  -2.192574    1.854169
  zpal~g_k2016 |        71                 345  |     44  -7.335691    .6791006
  zpal~l_12017 |        54                 362  |     76  -3.766335    1.937308
  zpal~g_12017 |        70                 346  |     57  -3.807157    1.835308
  dap_sca~2016 |        75                 341  |     47         63         145
  dap_sca~2017 |        60                 356  |     50         62         153
  -----------------------------------------------------------------------------


  
  // need to deal with low end z scores for actually being missing data. 

*/
mi misstable patterns cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score* 
mi misstable patterns cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score* gender* race_* hispanic* f_pals_esl_services* dap_age* disability* kbit_verbal2016 kbit_nonverbal2016 kbit_composite_score2016
mi misstable patterns cogat_nonverb2017 flagged2016 zpals_fall_k2016  zpals_fall_12017  dap_scaled_score2016 dap_scaled_score2017 gender2016 min2017 dap_age2016 f_pals_esl_services2017 disability2016
/*

. mi misstable patterns cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score*

              Missing-value patterns
                (1 means complete)

              |   Pattern
    Percent   |  1  2  3  4    5  6  7  8    9 10
  ------------+-----------------------------------
       66%    |  1  1  1  1    1  1  1  1    1  1
              |
       11     |  1  1  0  1    1  1  1  1    0  0
        7     |  0  0  1  0    0  0  0  0    1  1
        3     |  1  1  1  1    1  1  1  1    1  0
        3     |  0  0  1  0    0  0  0  0    0  1
        3     |  1  1  1  1    1  1  1  0    1  1
        1     |  1  1  1  0    0  0  0  1    1  1
       <1     |  1  0  1  1    1  1  1  1    1  1
       <1     |  0  0  0  0    0  0  0  0    0  0
       <1     |  0  0  0  0    0  0  0  0    1  0
       <1     |  1  1  0  1    1  1  1  0    0  0
       <1     |  0  0  0  0    0  0  0  0    0  1
       <1     |  0  0  1  0    0  0  0  0    1  0
       <1     |  1  1  0  0    0  0  0  0    0  0
       <1     |  1  1  0  1    1  1  1  1    1  0
       <1     |  1  1  1  1    1  1  1  1    0  1
       <1     |  0  0  1  0    0  0  0  0    0  0
       <1     |  1  0  0  0    0  0  0  1    0  0
       <1     |  1  0  0  1    1  1  1  1    0  0
  ------------+-----------------------------------
      100%    |

  Variables are  (1) zpals_fall_12017  (2) dap_scaled_score2017  (3) zpals_fall_k2016  (4) cogat_composite2017
                 (5) cogat_nonverb2017  (6) cogat_quant2017  (7) cogat_verbal2017  (8) zpals_spring_12017  (9) zpals_spring_k2016
                 (10) dap_scaled_score2016




**** NOTE: ****
// total proportion of complete observations: 88%
// 18% of kids have KBIT
// 70% of kids were never given KBIT but are otherwise complete

*/
// C) If necessary, Identify potential auxiliary variables
tab classroom2016, gen(class_)
pwcorr cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score* gender* race_* hispanic* f_pals_esl_services* dap_age* disability* kbit_verbal2016 kbit_nonverbal2016 kbit_composite_score2016
pwcorr cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score* *pals_reading_level*
// definitely include kbit scores as auxiliary scores
// esl status also
// race maybe? 

// Imputation Phases
mi set mlong
// Phase 1) Imputation Phase
// https://stats.idre.ucla.edu/stata/seminars/mi_in_stata_pt1_new/
mi register imputed cogat_*2017 zpals_*_k2016 zpals_*_12017 dap_scaled_score* ///
f_pals_esl_services* *pals_reading_level2017 kbit_verbal2016 ///
kbit_nonverbal2016 kbit_composite_score2016 dap_age2016
mi register regular flagged2016 gender* disability* min2017


// MICE Imputation: 
mi impute chained  (regress) cogat_verbal2017  cogat_quant2017 cogat_nonverb2017 ///
 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 ///
 dap_scaled_score2016 dap_scaled_score2017 dap_age2016 (logit) ///
 f_pals_esl_services2017 , add(12) rseed(7486)

/*

Multivariate imputation                     Imputations =       12
Chained equations                                 added =       12
Imputed: m=1 through m=12                       updated =        0

Initialization: monotone                     Iterations =      120
                                                burn-in =       10

    cogat_ver~2017: linear regression
    cogat_qua~2017: linear regression
    cogat_non~2017: linear regression
    zpals_fall_k~6: linear regression
    zpals_sp~k2016: linear regression
    zpals_fa~12017: linear regression
    zpals_sp~12017: linear regression
    dap_scale~2016: linear regression
    dap_scale~2017: linear regression
       dap_age2016: linear regression
    f_pals_es~2017: logistic regression

------------------------------------------------------------------
                   |               Observations per m             
                   |----------------------------------------------
          Variable |   Complete   Incomplete   Imputed |     Total
-------------------+-----------------------------------+----------
    cogat_ver~2017 |        306            5         5 |       311
    cogat_qua~2017 |        306            5         5 |       311
    cogat_non~2017 |        306            5         5 |       311
    zpals_fall_k~6 |        309            2         2 |       311
    zpals_sp~k2016 |        309            2         2 |       311
    zpals_fa~12017 |        311            0         0 |       311
    zpals_sp~12017 |        300           11        11 |       311
    dap_scale~2016 |        296           15        15 |       311
    dap_scale~2017 |        307            4         4 |       311
       dap_age2016 |        308            3         3 |       311
    f_pals_es~2017 |        311            0         0 |       311
------------------------------------------------------------------
(complete + incomplete = total; imputed is the minimum across m
 of the number of filled-in observations.)

*/ 
	  
	  
	  
// Phase 2) Analytical Phase
mi estimate: xtmixed cogat_nonverb2017 flagged2016 zpals_fall_k2016 zpals_fall_12017  dap_scaled_score2016 dap_scaled_score2017 gender2016 min2017 f_pals_esl_services2017 disability2016 || teacher2016:, mle

/*


*/

mi estimate: reg cogat_quant2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)

/*

. mi estimate: reg cogat_quant2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_s
> caled_score2016 dap_scaled_score2017 gender2016 race_*2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teach
> er2016)

Multiple-imputation estimates                   Imputations       =         32
Linear regression                               Number of obs     =        277
                                                Average RVI       =     0.8404
                                                Largest FMI       =     0.1928
                                                Complete DF       =         16
DF adjustment:   Small sample                   DF:     min       =      11.83
                                                        avg       =      14.14
                                                        max       =      14.32
Model F test:       Equal FMI                   F(  17,   10.8)   =      97.05
Within VCE type:       Robust                   Prob > F          =     0.0000

                                     (Within VCE adjusted for 17 clusters in teacher2016)
-----------------------------------------------------------------------------------------
        cogat_quant2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |  -.2730531   2.056191    -0.13   0.896    -4.674184    4.128077
       zpals_fall_k2016 |   1.781539   1.467955     1.21   0.245    -1.360427    4.923505
     zpals_spring_k2016 |  -2.195297   1.159685    -1.89   0.079    -4.677466    .2868727
       zpals_fall_12017 |   2.608594   1.737456     1.50   0.155    -1.110204    6.327392
     zpals_spring_12017 |   2.425697   1.112149     2.18   0.046     .0452646    4.806129 *
   dap_scaled_score2016 |   .2171993   .0603197     3.60   0.003     .0880458    .3463528 **
   dap_scaled_score2017 |   .0774795   .0531451     1.46   0.167    -.0365984    .1915573
             gender2016 |  -3.620792   1.009768    -3.59   0.003    -5.782108   -1.459476 **
             race_12016 |   13.44272   3.426306     3.92   0.001     6.109172    20.77626 **
             race_22016 |   25.81928   2.790472     9.25   0.000     19.72949    31.90908 ***
             race_32016 |   6.819295   2.277794     2.99   0.009     1.943648    11.69494 **
             race_42016 |   12.70176   2.234408     5.68   0.000     7.919285    17.48423 ***
             race_52016 |          0  (omitted)
             race_62016 |          0  (omitted)
             race_72016 |   13.33814   4.773482     2.79   0.014     3.121159    23.55513 *
             race_82016 |          0  (omitted)
           hispanic2016 |  -3.462102   2.931902    -1.18   0.257    -9.737866    2.813662
f_pals_esl_services2016 |  -15.37098   4.395497    -3.50   0.003    -24.77916    -5.96279 **
f_pals_esl_services2017 |   16.87891   4.874722     3.46   0.004     6.444721    27.31311 **
         disability2016 |  -.2783502   .1900894    -1.46   0.165    -.6852103    .1285099
                  _cons |    60.2596   8.733713     6.90   0.000      41.5505     78.9687 ***
-----------------------------------------------------------------------------------------


*/

mi estimate: reg cogat_nonverb2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)
/*
. mi estimate: reg cogat_nonverb2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap
> _scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 dap_age2016 hispanic2016 f_pals_esl_services* disability2016,
>  cluster(teacher2016)

Multiple-imputation estimates                   Imputations       =         32
Linear regression                               Number of obs     =        277
                                                Average RVI       =     0.2430
                                                Largest FMI       =     0.1731
                                                Complete DF       =         16
DF adjustment:   Small sample                   DF:     min       =      12.11
                                                        avg       =      14.17
                                                        max       =      14.32
Model F test:       Equal FMI                   F(  18,   13.3)   =     533.58
Within VCE type:       Robust                   Prob > F          =     0.0000

                                     (Within VCE adjusted for 17 clusters in teacher2016)
-----------------------------------------------------------------------------------------
      cogat_nonverb2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   3.838685    1.40992     2.72   0.016     .8200761    6.857293 *
       zpals_fall_k2016 |   3.690818   1.135102     3.25   0.006     1.261149    6.120487 **
     zpals_spring_k2016 |   .2293686   .9324293     0.25   0.809    -1.766443    2.225181
       zpals_fall_12017 |   2.335029   1.002378     2.33   0.035     .1895548    4.480503 *
     zpals_spring_12017 |   .8669682   1.122787     0.77   0.453    -1.536225    3.270161
   dap_scaled_score2016 |    .124755   .0747038     1.67   0.117    -.0352476    .2847576
   dap_scaled_score2017 |   .0834214   .0509818     1.64   0.124    -.0258697    .1927125
             gender2016 |  -1.105625   1.324863    -0.83   0.418    -3.941353    1.730102
             race_12016 |   18.21928   6.350581     2.87   0.012     4.626765     31.8118 *
             race_22016 |   29.38057   1.693393    17.35   0.000     25.69454    33.06661 ***
             race_32016 |    14.3479   1.722512     8.33   0.000     10.66023    18.03558 ***
             race_42016 |   15.65496   1.877297     8.34   0.000     11.63642    19.67349 ***
             race_52016 |          0  (omitted)
             race_62016 |          0  (omitted)
             race_72016 |   14.63266   5.766504     2.54   0.023     2.290194    26.97513 *
             race_82016 |          0  (omitted)
            dap_age2016 |  -.7875614   .1986897    -3.96   0.001     -1.21284   -.3622828 **
           hispanic2016 |  -.0258457   2.450337    -0.01   0.992    -5.270605    5.218913
f_pals_esl_services2016 |  -4.621833    3.05594    -1.51   0.152    -11.16292    1.919259
f_pals_esl_services2017 |   5.768985   3.351304     1.72   0.107    -1.404315    12.94229
         disability2016 |  -.0806585   .1363731    -0.59   0.563    -.3725458    .2112289
                  _cons |    113.601   18.99492     5.98   0.000     72.93446    154.2676 ***
-----------------------------------------------------------------------------------------



*/
di "d = " (3.83/15)
// d = .25533333




mi estimate: reg cogat_verbal2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teacher2016)



/*
. mi estimate: reg cogat_verbal2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_
> scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 hispanic2016 f_pals_esl_services* disability2016, cluster(teac
> her2016)

Multiple-imputation estimates                   Imputations       =         32
Linear regression                               Number of obs     =        277
                                                Average RVI       =     2.3182
                                                Largest FMI       =     0.6147
                                                Complete DF       =         16
DF adjustment:   Small sample                   DF:     min       =       5.97
                                                        avg       =      13.83
                                                        max       =      14.32
Model F test:       Equal FMI                   F(  17,    4.4)   =    1064.32
Within VCE type:       Robust                   Prob > F          =     0.0000

                                     (Within VCE adjusted for 17 clusters in teacher2016)
-----------------------------------------------------------------------------------------
       cogat_verbal2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   .1000606    1.60051     0.06   0.951    -3.325714    3.525835 
       zpals_fall_k2016 |  -.0906747    1.02706    -0.09   0.931    -2.288982    2.107633
     zpals_spring_k2016 |  -1.196479   .9178316    -1.30   0.213    -3.161028    .7680707
       zpals_fall_12017 |   3.961294   1.555151     2.55   0.023     .6326851    7.289902 *
     zpals_spring_12017 |   1.151357   1.286162     0.90   0.385    -1.601526     3.90424
   dap_scaled_score2016 |   .2753227   .0470149     5.86   0.000     .1746638    .3759816 ***
   dap_scaled_score2017 |   .0882688    .043204     2.04   0.060    -.0042943    .1808319
             gender2016 |    -.52178   1.256763    -0.42   0.684     -3.21171     2.16815
             race_12016 |   12.54412   4.615861     2.72   0.016     2.664485    22.42375 *
             race_22016 |   17.68409   1.933351     9.15   0.000     12.94793    22.42025 ***
             race_32016 |   7.050351   1.192989     5.91   0.000     4.496656    9.604046 ***
             race_42016 |   11.20145   1.331517     8.41   0.000     8.351489    14.05141 ***
             race_52016 |          0  (omitted)
             race_62016 |          0  (omitted)
             race_72016 |   10.41408   1.946085     5.35   0.000     6.248711    14.57945 ***
             race_82016 |          0  (omitted)
           hispanic2016 |  -2.256718   2.130418    -1.06   0.307    -6.817579    2.304143
f_pals_esl_services2016 |  -9.810516   2.107763    -4.65   0.000    -14.32212   -5.298914 ***
f_pals_esl_services2017 |   10.36257   2.437534     4.25   0.001     5.144365    15.58077 **
         disability2016 |  -.0995499   .1541511    -0.65   0.529    -.4294901    .2303903
                  _cons |   51.05867   5.871069     8.70   0.000     38.48656    63.63079 ***
-----------------------------------------------------------------------------------------


*/

// OR


mi estimate:  reg cogat_nonverb2017 flagged2016 zpals_fall_k2016 ///
	zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 ///
	dap_scaled_score2017 gender2016 min2017  f_pals_esl_services2017 ///
	disability2016, cluster(teacher2016)
reg cogat_nonverb2017 flagged2016 zpals_fall_k2016 ///
	zpals_spring_k2016 zpals_fall_12017 zpals_spring_12017 dap_scaled_score2016 ///
	dap_scaled_score2017 gender2016 min2017  f_pals_esl_services2017 ///
	disability2016 if _mi_m == 0, cluster(teacher2016)

/*
. mi estimate:  xtmixed cogat_composite2017 flagged2016 zpals_fall_k2016 zpals_spring_k2016 zpals_fall_12017 zpals_spring_12
> 017 dap_scaled_score2016 dap_scaled_score2017 gender2016 race_*2016 hispanic2016 f_pals_esl_services* dap_age* disability2
> 016 || teacher2016:, mle

Multiple-imputation estimates                   Imputations       =         32
Mixed-effects ML regression                     Number of obs     =        277

Group variable: teacher2016                     Number of groups  =         17
                                                Obs per group:
                                                              min =          1
                                                              avg =       16.3
                                                              max =         19
                                                Average RVI       =     0.0024
                                                Largest FMI       =     0.0176
DF adjustment:   Large sample                   DF:     min       = 100,119.38
                                                        avg       =   2.41e+11
                                                        max       =   4.69e+12
Model F test:       Equal FMI                   F(  19, 7.5e+07)  =      11.39
                                                Prob > F          =     0.0000

-----------------------------------------------------------------------------------------
    cogat_composite2017 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------------+----------------------------------------------------------------
            flagged2016 |   1.934935   1.811931     1.07   0.286    -1.616384    5.486254
       zpals_fall_k2016 |   3.112263   1.026906     3.03   0.002     1.099563    5.124962 *
     zpals_spring_k2016 |  -.8375983   1.141115    -0.73   0.463    -3.074142    1.398946
       zpals_fall_12017 |   3.697334    1.26242     2.93   0.003     1.223037    6.171631 **
     zpals_spring_12017 |   .8543869   .9575099     0.89   0.372    -1.022298    2.731072
   dap_scaled_score2016 |   .2024779   .0618748     3.27   0.001      .081205    .3237507 **
   dap_scaled_score2017 |   .0686296   .0577387     1.19   0.235    -.0445375    .1817967 
             gender2016 |   -1.95954   1.261701    -1.55   0.120     -4.43243     .513349
             race_12016 |   16.84775   11.69048     1.44   0.150    -6.065175    39.76067
             race_22016 |   26.93215   12.21682     2.20   0.027     2.987565    50.87674 *
             race_32016 |   10.93671   9.984155     1.10   0.273    -8.631874    30.50529
             race_42016 |   14.94597   9.916917     1.51   0.132    -4.490828    34.38277
             race_52016 |          0  (omitted)
             race_62016 |          0  (omitted)
             race_72016 |   13.72084   10.24732     1.34   0.181    -6.363535    33.80522
             race_82016 |          0  (omitted)
           hispanic2016 |  -1.094518   1.985641    -0.55   0.581    -4.986304    2.797268
f_pals_esl_services2016 |  -9.217346   5.526909    -1.67   0.095    -20.04989    1.615196
f_pals_esl_services2017 |   8.311293   5.646672     1.47   0.141     -2.75598    19.37857
            dap_age2016 |   .0918487   .4508945     0.20   0.839    -.7918882    .9755857
            dap_age2017 |  -.9094154   .4632401    -1.96   0.050    -1.817349   -.0014814 *
         disability2016 |  -.0811921   .2071156    -0.39   0.695    -.4871312    .3247471
                  _cons |   122.4365   19.80183     6.18   0.000     83.62559    161.2473
-----------------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects Parameters  |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------+------------------------------------------------
teacher2016: Identity        |
                   sd(_cons) |    2.89679   .8795955      1.597548    5.252669
-----------------------------+------------------------------------------------
                sd(Residual) |   9.580841   .4208116      8.790569    10.44216
------------------------------------------------------------------------------


*/

// Phase 3) Pooling Phase



egen missing = rowmiss(cogat_nonverb2017 flagged2016 zpals_fall_k2016  ///
	zpals_fall_12017 dap_scaled_score2016 dap_scaled_score2017 gender2016 min2017 ///
	dap_age2016 f_pals_esl_services2017 disability2016)

table missing if _mi_m == 0


































