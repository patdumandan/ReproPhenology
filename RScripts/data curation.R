library(dplyr)
library(tidyr)
library(portalr)

Portal_data=load_rodent_data()
Portal_rodent=Portal_data[["rodent_data"]]
Portal_plots=Portal_data[["plots_table"]]

portal1=inner_join(Portal_rodent, Portal_plots, by= c("plot", "month", "year"))%>%
  filter(!(treatment=="removal"))%>%
mutate(month=factor(month), Month=recode(month, "1"= "Jan", "2"="Feb", "3"="Mar", "4"="Apr",
                      "5"="May","6"="Jun", "7"="Jul", "8"="Aug", "9"="Sept",
                      "10"="Oct","11"="Nov", "12"="Dec"))%>%
  select(period, month, Month, day, year, plot, treatment, species, sex, reprod, vagina, nipples,lactation, pregnant, testes,hfl,wgt)
str(portal1)
unique(portal1$species)
unique(portal1$treatment)

#male individuals####
#spetabs an removal plots--what to do??

target_repro=c("S", "M", "R")

#size thresholds####
BA=portal1%>%
  filter(species=="BA",testes %in% target_repro, wgt >=6)%>%
  arrange(wgt)

DM=portal1%>%
  filter(species=="DM",testes %in% target_repro, wgt >=15)%>%
  arrange(wgt)

DO=portal1%>%
  filter(species=="DO",testes %in% target_repro, wgt >=29)%>%
  arrange(wgt)

DS=portal1%>%
  filter(species=="DS",testes %in% target_repro, wgt >=12)%>%
  arrange(wgt)

NEA=portal1%>%
  filter(species=="NA",testes %in% target_repro, wgt >=121)%>%
  arrange(wgt)

OL=portal1%>%
  filter(species=="OL",testes %in% target_repro, wgt >=19)%>%
  arrange(wgt)

OT=portal1%>%
  filter(species=="OT",testes %in% target_repro, wgt >=10)%>%
  arrange(wgt)

PH=portal1%>%
  filter(species=="PH",testes %in% target_repro, wgt >=18)%>%
  arrange(wgt)

PL=portal1%>%
  filter(species=="PL",testes %in% target_repro, wgt >=20)%>%
  arrange(wgt)

PB=portal1%>%
  filter(species=="PB",testes %in% target_repro,wgt >=16)%>%
  arrange(wgt)

PP=portal1%>%
  filter(species=="PP",testes %in% target_repro, wgt >=10)%>%
  arrange(wgt)

PE=portal1%>%
  filter(species=="PE",testes %in% target_repro, wgt >=7)%>%
  arrange(wgt)

PF=portal1%>%
  filter(species=="PF",testes %in% target_repro, wgt >=4)%>%
  arrange(wgt)

PM=portal1%>%
  filter(species=="PM",testes %in% target_repro, wgt >=11)%>%
  arrange(wgt)
#1 individual identified as juv but size within reproductive??

RM=portal1%>%
  filter(species=="RM",testes %in% target_repro, wgt >=4)%>%
  arrange(wgt)

RF=portal1%>%
  filter(species=="RF",testes %in% target_repro, wgt >=11)%>%
  arrange(wgt)

RO=portal1%>%
  filter(species=="RO",testes %in% target_repro, wgt >=6)%>%
  arrange(wgt)

SF=portal1%>%
  filter(species=="SF",testes %in% target_repro, wgt >=39)%>%
  arrange(wgt)

SH=portal1%>%
  filter(species=="SH",testes %in% target_repro, wgt >=51)%>%
  arrange(wgt)

SO=portal1%>%
  filter(species=="SO",testes %in% target_repro, wgt >=68)%>%
  arrange(wgt)

#create full dataset with all species

full_repro_male_dat=rbind(SO,SH,SF,RO,RM,RF,PP,PM,PL,PH,PF,PE,PB,OT,OL,NEA,DS,DO,DM,BA)
write.csv(full_repro_male_dat, "repro_male_all.csv")

repro_male_all=read.csv("repro_male_all.csv")

#read in individual rodents
indivs=summarize_individual_rodents()%>%
  filter(!(treatment=="removal"& NA), sex=="M")%>%
  mutate(spp=recode(species, "NA"="NEA")) 

#summarize repro_male count
repro_dat=repro_male_all%>%
  group_by(month, year, treatment, species)%>%
  summarise(reproductive=n())

total_rodents=indivs%>%
  group_by(month, year, treatment, species)%>%
  summarise(abundance=n())
  
total_proportion=left_join(repro_dat, total_rodents)%>%
 mutate(proportion=reproductive/abundance, spp=recode(species, "NA"="NEA"))

unique(total_proportion$spp)
#figure out how to address the NA in species

#### PB proportions#####

PBex=portal1%>%
  filter(species=="PB",testes %in% target_repro,wgt>=16, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PBcon=portal1%>%
  filter(species=="PB",testes %in% target_repro,wgt>=16, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PB_all_ex=portal1%>%
  filter(species=="PB", treatment=="exclosure", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

PB_all_con=portal1%>%
  filter(species=="PB", treatment=="control", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

pb1=left_join(PB_all_ex, PBex)
pb2=left_join(PB_all_con,PBcon)
pb3=rbind(pb1,pb2)

pb4=pb3%>%
  mutate(proportion=repro/count, species="PB")
write.csv(pb4, "PB_props.csv")
PB_props=read.csv("PB_props.csv")


#### PP proportions#####

PPex=portal1%>%
  filter(species=="PP",testes %in% target_repro,wgt>=10, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PPcon=portal1%>%
  filter(species=="PP",testes %in% target_repro,wgt>=10, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PP_all_ex=portal1%>%
  filter(species=="PP", treatment=="exclosure", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

PP_all_con=portal1%>%
  filter(species=="PP", treatment=="control", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

pp1=left_join(PP_all_ex, PPex)
pp2=left_join(PP_all_con,PPcon)
pp3=rbind(pp1,pp2)

pp4=pp3%>%
  mutate(proportion=repro/count, species="PP")%>%
  filter(proportion<=1)
write.csv(pp4, "PP_props.csv")
PP_props=read.csv("PP_props.csv")

#### PE proportions#####

PEex=portal1%>%
  filter(species=="PE",testes %in% target_repro,wgt>=7, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PEcon=portal1%>%
  filter(species=="PE",testes %in% target_repro,wgt>=7, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PE_all_ex=portal1%>%
  filter(species=="PE", treatment=="exclosure", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

PE_all_con=portal1%>%
  filter(species=="PE", treatment=="control", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

pe1=left_join(PE_all_ex, PEex)
pe2=left_join(PE_all_con,PEcon)
pe3=rbind(pe1,pe2)

pe4=pe3%>%
  mutate(proportion=repro/count, species="PE")
write.csv(pe4, "PE_props.csv")
PE_props=read.csv("PE_props.csv")

#### PF proportions#####

PFex=portal1%>%
  filter(species=="PF",testes %in% target_repro,wgt>=4, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PFcon=portal1%>%
  filter(species=="PF",testes %in% target_repro,wgt>=4, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PF_all_ex=portal1%>%
  filter(species=="PF", treatment=="exclosure", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

PF_all_con=portal1%>%
  filter(species=="PF", treatment=="control", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

pf1=left_join(PF_all_ex, PFex)
pf2=left_join(PF_all_con,PFcon)
pf3=rbind(pf1,pf2)

pf4=pf3%>%
  mutate(proportion=repro/count, species="PF")
write.csv(pf4, "PF_props.csv")
PF_props=read.csv("PF_props.csv")

#### PM proportions#####

PMex=portal1%>%
  filter(species=="PM",testes %in% target_repro,wgt>=11, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PMcon=portal1%>%
  filter(species=="PM",testes %in% target_repro,wgt>=11, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PM_all_ex=portal1%>%
  filter(species=="PM", treatment=="exclosure", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

PM_all_con=portal1%>%
  filter(species=="PM", treatment=="control", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

pm1=left_join(PM_all_ex, PMex)
pm2=left_join(PM_all_con,PMcon)
pm3=rbind(pm1,pm2)

pm4=pm3%>%
  mutate(proportion=repro/count, species="PM")
write.csv(pm4, "PM_props.csv")
PM_props=read.csv("PM_props.csv")

#### RM proportions#####

RMex=portal1%>%
  filter(species=="RM",testes %in% target_repro,wgt>=4, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

RMcon=portal1%>%
  filter(species=="RM",testes %in% target_repro,wgt>=4, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

RM_all_ex=portal1%>%
  filter(species=="RM", treatment=="exclosure", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

RM_all_con=portal1%>%
  filter(species=="RM", treatment=="control", sex=="M")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

rm1=left_join(RM_all_ex, RMex)
rm2=left_join(RM_all_con,RMcon)
rm3=rbind(rm1,rm2)

rm4=rm3%>%
  mutate(proportion=repro/count, species="RM")
write.csv(rm4, "RM_props.csv")
RM_props=read.csv("RM_props.csv")

#combine all male indivs####

all_sp=rbind(PB_props, PE_props, PP_props, PF_props, PM_props, RM_props)%>%
  arrange(repro)

write.csv(all_sp, "all_props_NA.csv")
all_props=read.csv("./reconfigured_data/all_props_NA.csv")
hist(all_sp$proportion) #overdispersed 0 and 1 proportions
min(all_props$proportion, na.rm=T)
sum(all_props$repro, na.rm=T)
#5257/11646= TOTAL NUMBER OF REPRODUCTIVE INDIVIDUALS IN BOTH CONTROL AND EXCLOURES
#female indivs####
target_vag=c("S", "P", "B")
target_nip=c("R", "E", "B")
target_sp=c("PB", "PP", "PE", "PF", "PM", "RM")
portal2=portal1%>%
  filter(vagina %in% target_vag | nipples %in% target_nip |
           pregnant== "P" | lactation=="L")%>%
  filter(species %in%target_sp)

#portal3=portal2%>%
#  filter(species %in%target_sp)

#write.csv(portal3, "female_repro.csv")
#fem_rep=read.csv("female_repro.csv")

#size thresholds####
PBf=portal2%>%
  filter(species=="PB", wgt>=20)%>%
  arrange(wgt)

PPf=portal2%>%
  filter(species=="PP", wgt>=5)%>%
  arrange(wgt)
#have an individual considered juvenile but with enlarged nipples

PEf=portal2%>%
  filter(species=="PE", wgt >=12)%>%
  arrange(wgt)

PFf=portal2%>%
  filter(species=="PF", wgt >=5)%>%
  arrange(wgt)

PMf=portal2%>%
  filter(species=="PM", wgt >=13, treatment=="exclosure")%>%
  arrange(wgt)

RMf=portal2%>%
  filter(species=="RM", wgt >=5)%>%
  arrange(wgt)

#### PMf proportions#####

PMfex=portal2%>%
  filter(species=="PM", wgt >=13, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PMfcon=portal2%>%
  filter(species=="PM", wgt >=13, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PMf_all_con=portal1%>%
  filter(species=="PM",sex=="F", treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

PMf_all_ex=portal1%>%
  filter(species=="PM", treatment=="exclosure", sex=="F")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

pmf1=left_join(PMf_all_ex, PMfex)
pmf2=left_join(PMf_all_con,PMfcon)
pmf3=rbind(pmf1,pmf2)

pmf4=pmf3%>%
  mutate(proportion=repro/count, species="PM")
write.csv(pmf4, "PMf_props.csv")
PMf_props=read.csv("./reconfigured_data/PMf_props.csv")

#### PBf proportions#####

PBfex=portal2%>%
  filter(species=="PB", wgt >=20, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PBfcon=portal2%>%
  filter(species=="PB", wgt >=20, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PBf_all_con=portal1%>%
  filter(species=="PB",sex=="F", treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

PBf_all_ex=portal1%>%
  filter(species=="PB", treatment=="exclosure", sex=="F")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

pbf1=left_join(PBf_all_ex, PBfex)
pbf2=left_join(PBf_all_con,PBfcon)
pbf3=rbind(pbf1,pbf2)

pbf4=pbf3%>%
  mutate(proportion=repro/count, species="PB")
write.csv(pbf4, "PBf_props.csv")
PBf_props=read.csv("./reconfigured_data/PBf_props.csv")

#### PPf proportions#####

PPfex=portal2%>%
  filter(species=="PP", wgt >=5, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PPfcon=portal2%>%
  filter(species=="PP", wgt >=5, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PPf_all_con=portal1%>%
  filter(species=="PP",sex=="F", treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

PPf_all_ex=portal1%>%
  filter(species=="PP", treatment=="exclosure", sex=="F")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

ppf1=left_join(PPf_all_ex, PPfex)
ppf2=left_join(PPf_all_con,PPfcon)
ppf3=rbind(ppf1,ppf2)

ppf4=ppf3%>%
  mutate(proportion=repro/count, species="PP")
write.csv(ppf4, "PPf_props.csv")
PPf_props=read.csv("./reconfigured_data/PPf_props.csv")

#### PEf proportions#####

PEfex=portal2%>%
  filter(species=="PE", wgt >=12, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PEfcon=portal2%>%
  filter(species=="PE", wgt >=12, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PEf_all_con=portal1%>%
  filter(species=="PE",sex=="F", treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

PEf_all_ex=portal1%>%
  filter(species=="PE", treatment=="exclosure", sex=="F")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

pef1=left_join(PEf_all_ex, PEfex)
pef2=left_join(PEf_all_con,PEfcon)
pef3=rbind(pef1,pef2)

pef4=pef3%>%
  mutate(proportion=repro/count, species="PE")
write.csv(pef4, "PEf_props.csv")
PEf_props=read.csv("./reconfigured_data/PEf_props.csv")

#### PFf proportions#####

PFfex=portal2%>%
  filter(species=="PF", wgt >=5, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

PFfcon=portal2%>%
  filter(species=="PF", wgt >=5, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

PFf_all_con=portal1%>%
  filter(species=="PF",sex=="F", treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

PFf_all_ex=portal1%>%
  filter(species=="PF", treatment=="exclosure", sex=="F")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

pff1=left_join(PFf_all_ex, PFfex)
pff2=left_join(PFf_all_con,PFfcon)
pff3=rbind(pff1,pff2)

pff4=pff3%>%
  mutate(proportion=repro/count, species="PF")
write.csv(pff4, "PFf_props.csv")
PFf_props=read.csv("./reconfigured_data/PFf_props.csv")

#### RMf proportions#####

RMfex=portal2%>%
  filter(species=="RM", wgt >=5, treatment=="exclosure")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="exclosure")

RMfcon=portal2%>%
  filter(species=="RM", wgt >=5, treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(repro=n())%>%
  mutate(trt="control")

RMf_all_con=portal1%>%
  filter(species=="RM",sex=="F", treatment=="control")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="control")

RMf_all_ex=portal1%>%
  filter(species=="RM", treatment=="exclosure", sex=="F")%>%
  group_by(month,Month, year)%>%
  summarize(count=n())%>%
  mutate(trt="exclosure")

rmf1=left_join(RMf_all_ex, RMfex)
rmf2=left_join(RMf_all_con,RMfcon)
rmf3=rbind(rmf1,rmf2)

rmf4=rmf3%>%
  mutate(proportion=repro/count, species="RM")
write.csv(rmf4, "RMf_props.csv")
RMf_props=read.csv("./reconfigured_data/RMf_props.csv")

#combine all female indivs####
all_female_sp=rbind(PBf_props, PEf_props, PPf_props, PFf_props, PMf_props, RMf_props)%>%
  arrange(repro)
write.csv(all_female_sp, "all_fem_props.csv")
