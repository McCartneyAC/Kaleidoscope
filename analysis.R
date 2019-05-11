# Question 1 A
# Andrew McCartney and Michael Hull
# Initial Commit 

library(mccrr)
library(ggmosaic)
library(ggthemes)
library(readxl)
library(magrittr)
library(tidyverse)



setwd("C:\\Users\\mccar\\Desktop\\summer intersession\\Data Summaries\\June2018project")
race2016<-read_xlsx("question 1a R\\race16.xlsx")
gender2016<-read_xlsx("question 1a R\\gender16.xlsx")
pk17<-read_xlsx("Data Files\\PK_Student_DataSY17.xlsx")


cohort1<-pk17 %>% 
  filter(GR == "2") %>% 
  filter(treatment == 1)
rm(pk17)


racecounts2016<-race2016 %>% 
  filter(treatment == 1) %>% 
  select(-treatment)  %>% 
  reshape2::melt(id.vars = "School", measure.vars = c("Black", "White", "Hispanic", "Asian", "Indian", "Multi")) %>% 
  group_by(variable)  %>% 
  summarize(n=sum(value))


gendcounts2016<-gender2016 %>% 
  filter(treatment == 1) %>% 
  select(-treatment) %>% 
  reshape2::melt(id.vars = "School") %>% 
  group_by(variable) %>% 
  summarize(n = sum(value))



gifted17 <- cohort1 %>% 
  filter(gifted_id == 1) %>% 
  select(School, `race number`, hispanic)

racecounts2017 <- gifted17 %>% 
  mutate(racemin = if_else(`race number` %in% c(2,5,12), 0, 1)) %>% 
  mutate(min = if_else(racemin | hispanic, 1, 0)) %>% 
  select(School, min) %>% 
  reshape2::melt(id.vars = "School") %>% 
  count(value) %>% 
  mutate(group = if_else(value == 1, "underrepresented", "overrepresented")) %>% 
  select(-value) 


racecounts2017

race<-racecounts2016 %>% 
  mutate(group = if_else(variable %in% c("White", "Asian"), "overrepresented", "underrepresented")) %>% 
  group_by(group) %>% 
  summarize(sum(n)) %>% 
  left_join(racecounts2017) %>% 
  rename("Incoming 2017" =n, "2016 and Prior" = `sum(n)`) %>% 
  reshape2::melt()
race
fauq1
fauq1<-ggplot(data=race) + geom_mosaic(aes(weight = value, x = product(variable), fill = group))
fauq1 +
  scale_fill_manual(values=uvapal)+
  labs(
    title="Over- and Under-Represented Race/Ethnicity Groups in Treatment School Gifted ID",
    x = "Gifted ID by Time",
    y = "Percent by Demographic",
    fill = "Demographic Groups"
  ) + 
  theme_bw() +
  annotate("text", x = 0.25, y = 0.50, color = "white", label = "Pearson's Chi Squared Test:
X-squared = 0.0089, 
df = 1,
p-value = 0.92" )

race %>% 
  spread(key = variable, value = value) 
  select(-group) %>% 
  chisq.test()

