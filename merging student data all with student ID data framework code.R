setwd("C:\\Users\\mccar\\Desktop\\summer intersession")
##################
library(tidyverse)
library(readxl)
##################


studat<-read_xlsx("PK Student Data ALL.xlsx")
IDS<-read_xlsx("student identification.xlsx")

# in case there are numeric/character vector issues:
# check and fix using this protocol:
# class(IDS$`sti number`)
# class(studat$`sti number`)
# studat$`sti number`<-as.numeric(studat$`sti number`)

full<-studat %>%
  inner_join(IDS, by = "sti number", check_na_matches=T)

full

write_csv(full, "student data full.csv")

# check for accuracy
students<-read_csv("student data full.csv")
students
