
cd "${drive}/Data Files"


// import everything
forvalues i = 15(1)18 {
	import excel using PK_Student_DataSY`i', first clear
	save PK_Student_DataSY`i', replace
clear
}

* Change `i' specification to 15(1)19 when 2019-2020 data are added and so on.

/*
// use a particular data set only
use PK_Student_DataSY15, clear
use PK_Student_DataSY16, clear
use PK_Student_DataSY17, clear
use PK_Student_DataSY18, clear
*/

forvalues j = 15(1)18 {
use PK_Student_DataSY`j', clear


// * label variables as needed
capture rename 	FallIdentified f_pals_identified
capture rename 	Service_ESL f_pals_esl_services
capture rename 	Service_TitleI f_pals_title_1_services
capture rename 	Gender gender
capture rename 	racenumber race
capture rename 	School school
capture replace school = "Mary Walter Elem." 	if school == "Mary Walter Elementary"
capture replace school = "Ritchie Elem." 		if school == "Ritchie Elem"
capture replace school = "Greenville Elem." 	if school == "Greenville Elementary"
capture rename 	Teacher teacher
capture rename 	Birth_month birth_month
capture rename 	FallSummedScore f_pals_sum_score
capture rename 	ReadingLevelCode f_13_pals_reading_level
capture replace f_13_pals_reading_level =. if f_13_pals_reading_level == 22 // 22 is missing no. in PALS, whereas 21 is max score (!!!!)
capture rename 	STINumber sti_number
capture rename 	GR grade
capture replace grade = "P" if grade == "PK"
capture rename 	AgeinMonthsatDAP dap_age
capture rename 	DAPRAWSCORE dap_raw_score
capture rename 	DAPScaledScore dap_scaled_score
capture rename 	PercentileRank dap_percentile_rank
capture rename 	QualitativeDescription dap_qualitative_description
capture rename 	schoolyear school_year
capture tostring(grade), replace // no numeric representation of pre-kindergarten
capture tostring(sti_number), replace // disallows regression on an ID variable. 



// define value labels 
label define yesno 1 yes 0 no
label values treatment hispanic f_pals_identified-f_pals_title_1_services m_pals_identified-m_pals_title_1_services s_pals_identified-s_pals_title_1_services frasier_* identified_by_pk-receiving_GRT_services_at_school invited_to_summer attended_summer Summer_frasier_* yesno
capture label values  gifted_id yesno

label define gndr 1 female 0 male
label values gender gndr

// DAP Qualitative Description
local dapquals `" "Significantly Impaired" "Mildly Impaired" "Below Average" "Average" "High Average" "Superior" "Very Superior" "'
local m : word count `dapquals'
capture forvalues p = 1(1)`m' {
	local b: word `p' of `dapquals'
		replace dap_qualitative_description = "`p'" if dap_qualitative_description == "`b'" 
}
capture destring dap_qualitative_description, replace
capture label define dapqual 1 "Significantly Impaired" 2 "Mildly Impaired" 3 "Below Average" 4 "Average" 5 "High Average" 6 "Superior" 7 "Very Superior"
capture label values dap_qualitative_description dapqual



label define racevalues 1 "American Indian or Alaskan Native" 2 "Asian" 3 "Black or African American" 5 "White" 6 "Native Hawaiian or Other Pacific Islander" 7 "American Indian or Alaskan Native and Asian" 8 "American Indian or Alaskan Native and Black or African American" 9 "American Indian or Alaskan Native and White" 10 "American Indian or Alaskan Native and Native Hawaiian or Other Pacific Islander" 11 "Asian and Black or African American" 12 "Asian and White" 13 "Asian and Native Hawaiian or Other Pacific Islander" 14 "Black or African American and White" 15 "Black or African American and Native Hawaiian or Other Pacific Islander" 16 "Native Hawaiian or Other Pacific Islander and White" 17 "American Indian or Alaskan Native, Asian And Black or African American" 18 "American Indian or Alaskan Native, Asian and White" 19 "American Indian or Alaskan Native, Asian and Native Hawaiian or Other Pacific Islander" 20 "Asian, Black or African American and White" 21 "Asian, Black or African American and Native Hawaiian or Other Pacific Islander" 22 "Black or African American, White and Native Hawaiian or Other Pacific Islander" 23 "Black or African American, Native Hawaiian or Other Pacific Islander and American Indian or Alaskan Native" 24 "White, Black or African American and American Indian or Alaskan Native" 25 "White, Native Hawaiian or Other Pacific Islander and American Indian or Alaskan Native" 26 "White, Native Hawaiian or Other Pacific Islander and Asian" 27 "American Indian or Alaskan Native, Asian, Black or African American and White" 28 "Asian, Black or African American, White and Native Hawaiian or Other Pacific Islander" 29 "Black or African American, White, Native Hawaiian or Other Pacific Islander and American Indian or Alaskan Native" 30 "White, Native Hawaiian or Other Pacific Islander, American Indian or Alaskan Native and Asian" 31 "Native Hawaiian or Other Pacific Islander, American Indian or Alaskan Native, Asian and Black or African American" 32 "American Indian or Alaskan Native, Asian, Black or African American, White and Native Hawaiian or Other Pacific Islander"
label values race racevalues
//

// define disability labels
label define disavalues 1 "none" 3 "severe disabilities" 4 "multiple disabilities" 5 "orthopedic impairment" 6 "visual impairment" 7 "hearing impairment/deaf" 8 "learning disability" 9 "emotional disturbance" 10 "speech/language impairment" 11 "other health impairment" 12 "deaf-blind" 13 "autism" 14 "traumatic brain injury" 15 "otherwise qualified under 504" 16 "developmental delay" 19 "intellectual disabilities" 
label values disability disavalues

// * recode teacher and school values

// School names first:
//// removes hard names as string elements and replaces them with numbers

local schs `" "Bradley Elem." "Brumfield Elem." "Coleman Elem." "Greenville Elem." "Mary Walter Elem." "Miller Elem." "Pearson Elem." "Pierce Elem." "Ritchie Elem." "Smith Elem." "Thompson Elem." "' 
local m : word count `schs'
capture forvalues p = 1(1)`m' {
	local b: word `p' of `schs'
	 replace school = "`p'" if school == "`b'"
}
destring school, replace
label define schsname 1 "Bradley Elem." 2 "Brumfield Elem." 3 "Coleman Elem." 4 "Greenville Elem." 5 "Mary Walter Elem." 6 "Miller Elem." 7 "Pearson Elem." 8 "Pierce Elem." 9 "Ritchie Elem." 10 "Smith Elem." 11 "Thompson Elem."
label values school schsname
* note that this process will not work if the school names are not entered precisely as in line 128 (two lines above this one) or in line 118 (ten lines above that one)


// label teacher numbers
capture destring teacher, replace
// ideally this could be split up to be multi-line without extending, but stata
// looses its cool and composure when i try to do the /// thing at the end so
// this only works when written on a single line.
label define techrs  1	"Bardenhagen" 101	"Martin" 102	"Propst" 103	"Steiner" 104	"Stright" 105	"Reutzel" 106	"Hoffman" 107	"Bourdeau" 108	"Alvarez" 109	"Baier" 110	"Durden" 111	"Hinnefeld" 112	"Hume" 113	"Rowe" 114	"Olinger" 201	"Baxter" 202	"Fox" 203	"Linn" 204	"Nye" 205	"Byvik" 206	"Carter" 207	"Fisher" 208	"Romine" 209	"Johnston" 210	"Brown" 211	"Goolsby" 212	"Todd" 213	"West" 214	"Toelke" 215	"Chernay" 216	"Gray" 217	"O'Hara" 218	"Warren" 219 "Fletcher" 220 "Kraiwan" 221 "Hull" 222 "Stauffer" 223 "Corcoran" 301	"Olinger" 302	"Taylor" 303	"Ward" 304	"Green" 305	"Chamberlain" 306	"Millerson" 307	"Miller" 308	"Alsharkawi" 309	"Crane" 310	"Ellis" 311	"Graham" 312	"Witowski" 401	"Dalton" 402	"Holmes" 403	"Roda" 404	"Ventresco" 405	"Moon" 406	"Reder" 407	"Augustine" 408	"Rouse" 409	"Anderson" 410	"Lechner" 411	"Schultz" 412	"Swanson" 413	"Vercammen" 501	"Carrol" 502	"RIVERA, TIONE " 503	"Simpson" 504	"Forman" 505	"Walkowsky" 506	"Curtis" 507	"Tyson" 508	"Wilcox" 509	"Bunch" 510	"Funk" 511	"Lacey" 512	"Kelly" 513	"Stribling" 514	"Carroll" 515	"Rehbein" 516	"Christofferson" 517	"Stafford" 518	"Grena" 519	"Sichko" 520	"Yonkey" 601	"Kraus" 602	"Sutphin" 603	"Wilson" 604	"Bowers" 605	"Hurtack" 606	"Duby" 607	"Pyle" 608	"Dungan" 609	"Crile" 610	"Keller" 611	"Loy" 612	"Reed" 613	"Taylor" 614	"Anderson" 615	"Swanson" 701	"Rees" 702	"Summers" 703	"Williams" 704	"Foley" 705	"Hillin" 706	"Lenox" 707	"Kosters" 708	"Martens" 709	"Owens" 710	"Van Tassel" 711	"Seymour" 712	"Bland" 713	"Kiecana" 714	"Gee" 715	"Knight" 716	"Robinson" 801	"Eckenrode" 802	"Robbins" 803	"Smith" 804	"Thompson" 805	"Brill" 806	"McLoughlin" 807	"Norris" 808	"Turner" 809	"Higgins" 810	"Corpening" 811	"Nagel" 812	"Parker" 813	"Perryman" 814	"Wood" 815	"Beaver" 816	"Bennett" 817	"Ryan" 818	"Williams" 901	"Rodea" 902	"Scandalis" 903	"Smith" 904	"Elphee" 905	"Leach" 906	"Yergey" 907	"Poulin" 908	"Depue" 909	"Falsone" 910	"Hoke" 911	"McNeal" 912	"Strange" 913	"Wilt" 914	"Warren" 1001	"Biegert" 1002	"Ramsier" 1003	"Sansom" 1004	"Mullikin" 1005	"Schoenike" 1006	"Larkin" 1007	"Lanier" 1008	"Angelos" 1009	"Compton" 1010	"Gaskin" 1101	"Boisvert" 1102	"Piper" 1103	"Harrison" 1104	"Mills" 1105	"Keith" 1106	"Kroes" 1107	"Zevillanos" 1108	"Kane" 1109	"Burrow" 1110	"Mann" 1111	"Carino"
label values teacher techrs

// re-code treatment and control designations
replace treatment = 0 if school == 1
replace treatment = 1 if school == 2 
replace treatment = 0 if school == 3
replace treatment = 0 if school == 4
replace treatment = 1 if school == 5
replace treatment = 0 if school == 6 
replace treatment = 1 if school == 7 
replace treatment = 1 if school == 8 
replace treatment = 0 if school == 9 
replace treatment = 0 if school == 10 
replace treatment = 1 if school == 11

// Generate Tags for Cohort:
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


// Create Disability as a Binary
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

//// assuming minority = ((not (white or asian)) | (hispanic))
gen min = 0 if 	race == 2 | race     == 5 	| race == 12   // 12 = biracial asian+white
replace min = 1 if race == 1
replace min = 1 if race == 3
replace min = 1 if race == 9 
replace min = 1 if race == 14
replace min = 1 if race == 16
replace min = 1 if hispanic == 1
label values min yesno


// save output of an individual doc. Do not run as a unit. 
* save PK_Student_DataSY15_clean, replace
* save PK_Student_DataSY16_clean, replace
* save PK_Student_DataSY`j'_clean, replace
save PK_Student_DataSY`j'_clean, replace
}

cd "${drive}"





// clean over now merge:

cd "${drive}/Data Files"


// append all years together. 
use PK_Student_DataSY15_clean, clear
append using PK_Student_DataSY16_clean
append using PK_Student_DataSY17_clean
append using PK_Student_DataSY18_clean
// append using PK_Student_DataSY19_clean
// * done

save PK_Student_Data_AllYears, replace 

cd "${drive}"
