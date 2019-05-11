// Project Kaleidoscope
// Javits June 2018 Data Project
// Author: Andrew McCartney
// Editors: Michael Hull; Tonya Moon
// Initial Commit: 06/01/18
// Last Updated: 06/01/18


// Data Needs: 	GRT Identification Information from Schools (past five years)
//				GRT Pull-Out Data From Schools (last and this)
//				FRPL Data from Schools (Per student or per-X basis)

// TODO: 	Add in relevant Teacher-Level Data
// 			Add in Relevant School-Level Data
//			Visualizations of IV/DV ? 
// 			Data Validation Checks? 
//			generate "Prior three years of gifted identification rates" variable
//			descriptive statistics of chars of flagged by us and Identified by District


// load data


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



//  generate cohorts
gen 	cohort = 2 if grade == "2" & school_year == 2018
replace cohort = 3 if grade == "1" & school_year == 2018
replace cohort = 4 if grade == "0" & school_year == 2018
replace cohort = 5 if grade == "P" & school_year == 2018
replace cohort = 1 if grade == "2" & school_year == 2017
replace cohort = 2 if grade == "1" & school_year == 2017
replace cohort = 3 if grade == "0" & school_year == 2017
replace cohort = 4 if grade == "P" & school_year == 2017
replace cohort = 1 if grade == "1" & school_year == 2016
replace cohort = 2 if grade == "0" & school_year == 2016
replace cohort = 3 if grade == "P" & school_year == 2016
replace cohort = 1 if grade == "0" & school_year == 2015
replace cohort = 2 if grade == "P" & school_year == 2015
table 	cohort school_year


// generate pmin
//// assuming minority = ((not (white or asian)) | (hispanic))
capture drop min
gen maj = 1 if 	race == 2 | race     == 5 	| race == 12   // 12 = biracial asian+white
gen min = 1 if 	maj  != 1 | hispanic == 1
drop maj
replace min = 0 if min != 1 // & min !=.
table min

egen 	summin = sum(min), by(teacher)
egen 	students_in_class = count(sti_number), by(teacher)
gen 	pmin = (summin/students_in_class)*100
drop	summin
//


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


// generate variable for ever-flagged (i.e. = 1 for all students for whom flagged ever == 1)
egen ever_flagged = sum(identified_by_pk), by(sti_number) 
replace ever_flagged = 1 if ever_flagged != 0
// replace ever_flagged = 0 if ever_flagged != 1
// label define yesno 1 yes 0 no
label values ever_flagged yesno
table ever_flagged
tab ever_flagged gifted_id




//			descriptive statistics of chars of flagged by us and Identified by District



tab race school if school_year == 2017
/* 

                      |                                                          school
                 race | Bradley E  Brumfield  Coleman E  Greenvill  Mary Walt  Miller El  Pearson E  Pierce El  Ritchie E  Smith Ele  Thompson  |     Total
----------------------+-------------------------------------------------------------------------------------------------------------------------+----------
American Indian or Al |         0          3          0          1          9          4          1          4          4          2          5 |        33 
                Asian |         2          6          0          3          1          9          0          1          6          5          0 |        33 
Black or African Amer |        15         54         10         18         12         36         20         33          7          8          9 |       222 
                White |       171        182        130        240        187        182        160        209        216        158        112 |     1,947 
Native Hawaiian or Ot |         0          0          2          1          0          1          1          1          0          2          1 |         9 
American Indian or Al |         0          0          0          0          0          2          1          0          0          0          0 |         3 
American Indian or Al |         2          0          0          0          1          0          3          0          0          0          0 |         6 
Asian and Black or Af |         1          0          0          0          0          0          0          0          0          0          0 |         1 
      Asian and White |         2          0          1          6          1          4          2          2          2          6          0 |        26 
Black or African Amer |        11         23          6          6         14         18          7          9          6          9          4 |       113 
Black or African Amer |         0          0          0          0          0          0          1          0          0          1          0 |         2 
Native Hawaiian or Ot |         1          2          0          0          2          0          0          1          0          1          3 |        10 
Native Hawaiian or Ot |         0          0          0          0          0          1          0          0          0          0          0 |         1 
----------------------+-------------------------------------------------------------------------------------------------------------------------+----------
                Total |       205        270        149        275        227        257        196        260        241        192        134 |     2,406 



*/
tab race if school_year == 2017

/*


                                   race |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
      American Indian or Alaskan Native |         33        1.37        1.37
                                  Asian |         33        1.37        2.74
              Black or African American |        222        9.23       11.97
                                  White |      1,947       80.92       92.89
Native Hawaiian or Other Pacific Island |          9        0.37       93.27
American Indian or Alaskan Native and B |          3        0.12       93.39
American Indian or Alaskan Native and W |          6        0.25       93.64
    Asian and Black or African American |          1        0.04       93.68
                        Asian and White |         26        1.08       94.76
    Black or African American and White |        113        4.70       99.46
Black or African American and Native Ha |          2        0.08       99.54
Native Hawaiian or Other Pacific Island |         10        0.42       99.96
Native Hawaiian or Other Pacific Island |          1        0.04      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,406      100.00

. 


*/
tab race if school_year == 2017 & gifted_id == 1
/*


                                   race |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                  Asian |          2        2.13        2.13
              Black or African American |          2        2.13        4.26
                                  White |         82       87.23       91.49
Native Hawaiian or Other Pacific Island |          1        1.06       92.55
American Indian or Alaskan Native and W |          1        1.06       93.62
                        Asian and White |          2        2.13       95.74
    Black or African American and White |          4        4.26      100.00
----------------------------------------+-----------------------------------
                                  Total |         94      100.00

*/



// Begin Visualizations



// Begin Modeling








