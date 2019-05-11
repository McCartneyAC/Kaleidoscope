library(dplyr)
library(readr)
library(readxl)

setwd("C:\\Users\\mccar\\Desktop\\summer intersession\\Data Summaries\\June2018project\\Data Files")

  PK_Student_DataSY15<-readxl::read_xlsx("PK_Student_DataSY15.xlsx")
  PK_Student_DataSY16<-readxl::read_xlsx("PK_Student_DataSY16.xlsx")
  PK_Student_DataSY17<-readxl::read_xlsx("PK_Student_DataSY17.xlsx")
  PK_Student_DataSY18<-readxl::read_xlsx("PK_Student_DataSY18.xlsx")

dat_full<-rbind(PK_Student_DataSY15, 
           PK_Student_DataSY16, 
           PK_Student_DataSY17,
           PK_Student_DataSY18
           )


dat_full <- dat_full %>%
  mutate(
    dap_qualitative_description = case_when(
      dap_qualitative_description == "Significantly Impaired" ~ 1,
      dap_qualitative_description == "Mildly Impaired" ~ 2,
      dap_qualitative_description == "Below Average" ~ 3,
      dap_qualitative_description == "Average" ~ 4,
      dap_qualitative_description == "High Average" ~ 5,
      dap_qualitative_description == "Superior" ~ 6,
      dap_qualitative_description == "Very Superior" ~ 7,
      dap_qualitative_description == 1 ~ 1,
      dap_qualitative_description == 2 ~ 2,
      dap_qualitative_description == 3 ~ 3,
      dap_qualitative_description == 4 ~ 4,
      dap_qualitative_description == 5 ~ 5,
      dap_qualitative_description == 6 ~ 6,
      dap_qualitative_description == 7 ~ 7
    )
  ) %>%
  rename(birth_month = Birth_month)

dat_full<-dat_full %>% 
  mutate(school = case_when(
    school == "Bradley Elem."  ~ 1,
    school == "Brumfield Elem."  ~2, 
    school == "Coleman Elem."  ~ 3,
    school == "Greenville Elem."  ~ 4, 
    school == "Greenville Elementary" ~ 4, 
    school == "Mary Walter Elem."  ~ 5,
    school == "Miller Elem."  ~ 6,
    school == "Pearson Elem."  ~ 7,
    school == "Pierce Elem."  ~ 8,
    school == "Ritchie Elem."  ~ 9,
    school == "Ritchie Elem" ~ 9,
    school == "Smith Elem."  ~ 10,
    school == "Thompson Elem." ~ 11,
    school == 1 ~ 1,
    school == 2 ~ 2,
    school == 3 ~ 3,
    school == 4 ~ 4,
    school == 5 ~ 5,
    school == 6 ~ 6,
    school == 7 ~ 7,
    school == 8 ~ 8,
    school == 9 ~ 9,
    school == 10 ~ 10,
    school == 11 ~ 22
  ))


dat_full <- dat_full %>%
  mutate(
    treatment = case_when(
      school == 1  ~ 0,
      school == 2  ~ 1,
      school == 3  ~ 0,
      school == 4  ~ 0,
      school == 5  ~ 1,
      school == 6  ~ 0,
      school == 7  ~ 1,
      school == 8  ~ 1,
      school == 9  ~ 0,
      school == 10 ~ 0,
      school == 11 ~ 1
    )
  )


dat_full <- dat_full %>% 
  mutate(grade = case_when(
    grade == "PK" ~ "P",
    grade == "P" ~ "P",
    grade == "0" ~ "0",
    grade == "1" ~ "1",
    grade == "2" ~ "2"
  ))


dat_full <- dat_full %>% 
  mutate(disability = case_when(
    disability == 1 ~ 0,
    disability == 2 ~ 1,
    disability == 3 ~ 1,
    disability == 4 ~ 1,
    disability == 5 ~ 1,
    disability == 6 ~ 1,
    disability == 7 ~ 1,
    disability == 8 ~ 1,
    disability == 9 ~ 1,
    disability == 10 ~ 1,
    disability == 11 ~ 1,
    disability == 12 ~ 1,
    disability == 13 ~ 1,
    disability == 14 ~ 1,
    disability == 15 ~ 1,
    disability == 16 ~ 1,
    disability == 17 ~ 1,
    disability == 18 ~ 1,
    disability == 19 ~ 1
    
  ))
dat_full <- dat_full %>% 
  mutate(cohort = case_when(
    grade == "2" & school_year == 2017 ~ 1, 
    grade == "1" & school_year == 2017 ~ 2,
    grade == "0" & school_year == 2017 ~ 3,
    grade == "P" & school_year == 2017 ~ 4,
    grade == "1" & school_year == 2016 ~ 1,
    grade == "0" & school_year == 2016 ~ 2,
    grade == "P" & school_year == 2016 ~ 3,
    grade == "0" & school_year == 2015 ~ 1,
    grade == "P" & school_year == 2015 ~ 2,
    grade == "P" & school_year == 2018 ~ 5,
    grade == "0" & school_year == 2018 ~ 4,
    grade == "1" & school_year == 2018 ~ 3,
    grade == "2" & school_year == 2018 ~ 2,
    grade == "3" & school_year == 2018 ~ 1
  ))

dat_full <- dat_full %>% 
  mutate(f_13_pals_reading_level = 
           replace(`f_1-3_pals_reading_level`, 
                   which(`f_1-3_pals_reading_level` == 22), NA)) %>% 
  mutate(s_13_pals_reading_level 
         = replace(`s_1-3_pals_reading_level`, 
                   which(`s_1-3_pals_reading_level` == 22), NA))
dat_full <- dat_full %>% 
  mutate(min = if_else(race == 2 | race == 5 | race == 12, 0,1)) %>% 
  mutate(min = replace(min, which(hispanic == 1), 1))

setwd("C:\\Users\\mccar\\Desktop\\summer intersession\\")

