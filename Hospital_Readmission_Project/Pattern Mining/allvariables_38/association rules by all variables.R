##################### Reading the Desired datasets into the environment ##################
library(arules)
library(ROSE)
##### Train
##################### Reading the Desired datasets into the environment ##################
rm(list=ls(all=T)) # Clear the global environment
setwd('E:/PHD/ML/Datasets and Description') # Set Working directory


##### Train
train = read.csv('Train.csv' ,header = T,na.strings = '?')
train_diagnosis=read.csv('Train_Diagnosis_TreatmentData.csv',header = T,na.strings = '?')
train_hospitilization=read.csv('Train_HospitalizationData.csv',header = T,na.strings = '?')

################ Merge the Data Frames ###########################
#### Train
train_final = merge(train,train_diagnosis,by="patientID")
train_final = merge(train_final,train_hospitilization,by='patientID')


#### Check the structur and summary
str(train_final)


################################################################################3
############################### Analysis Of The Data #################################

## Percentage of Null Vlaues in the column wise
train_null_values=data.frame(sapply(train_final, function(x) sum(is.na(x))))
colnames(train_null_values)="Null_value_Count"

train_null_values$Null_value_Count=(train_null_values$Null_value_Count/nrow(train_final))*100

train_null_values['Columns']=row.names(train_null_values)

finalnavalues=train_null_values[apply(train_null_values[1],1,function(z) !any(z==0)),] 

library(ggplot2)
ggplot(finalnavalues, aes(x=Columns, y=Null_value_Count)) + stat_summary(geom="bar")

################### Actions Based on Na values percentage ###################
#### Train and Test
trainfake = subset(train_final, select = -c(weight, payer_code,medical_specialty))
### Get the data frame only if the discharge disposition id is not equal to 11,19,20,21##

### As the discharge disposition of 11,13,14,19,20,21 are not making up any predictions so we will be removing them from 
### train data and as they are under the case of No condition we will be replacing them with NO directly.

### 768 data points are been droped from the train data
train_discharge=trainfake[!(trainfake$discharge_disposition_id==11 | trainfake$discharge_disposition_id==19 | trainfake$discharge_disposition_id==20 |trainfake$discharge_disposition_id==21),]


####################### levels Equalising #########################
# convert some numeric attributes to factors
cols=c("admission_type_id","discharge_disposition_id","admission_source_id")

train_discharge[cols] = lapply(train_discharge[cols], factor)

# Convert the levels of admission type id into two levels
levels(train_discharge$admission_type_id)=c("emergency","emergency","casual","casual","casual","casual","emergency","casual")

# Convert the levels of discharge_disposition_id 
levels(train_discharge$discharge_disposition_id)=c("dis_home","Another_hopital","SNF","ICF","Another_ICU","Home_HomeHealthSevrice","AMA","Nothing","Nothing","Nothing","Nothing","Nothing","MF","SNF","Nothing","Nothing","Null","Another_Rehab","Long_term","Nothing","Not_Mapped","Nothing","Pshychiartic","Expired")

# Convert the levels of admission_source_id
levels(train_discharge$admission_source_id)=c(1,2,3,4,5,4,7,8,9,4,11,13,14,9,9,22,25)

# Convert age two numeric from ordinal
levels(train_discharge$age)=c(5,15,25,35,45,55,65,75,85,95)

# Create the features named No of days and the month in which they stayed in hospital before discharge
cols=c("Admission_date","Discharge_date")
train_discharge[cols] = lapply(train_discharge[cols], as.Date)

train_discharge$No_of_days_Stayed=train_discharge$Discharge_date-train_discharge$Admission_date
train_discharge$No_of_days_Stayed=as.numeric(train_discharge$No_of_days_Stayed)
train_discharge$Month =as.factor(format(as.Date(train_discharge$Admission_date), "%m"))


# Just renaming the levels for better intiution
levels(train_discharge$A1Cresult)=c("abnormal","abnormal","not_tested","normal")

levels(train_discharge$max_glu_serum)=c("abnormal","abnormal","not_tested","normal")

######################### Remove the variables which are not sensing##################################
str(train_discharge)

train_drop = subset(train_discharge, select = -c(patientID,acetohexamide,AdmissionID,Admission_date,Discharge_date))

############################## Imputation ##################################
target=train_drop$readmitted
traintoput=subset(train_drop,select =-c(readmitted))

library(DMwR)
imputeddata=centralImputation(traintoput)

######################### ICD Code for 3 diagnosis columns #######################
diagnosis_ICD_codes = function(icd) {
  code <- as.numeric(icd)
  result <- "Other";
  if (code >= 0 & code <= 139) {
    result <- "Parasitic";
  }
  else if(code > 139 & code <= 239) {
    result <- "Neoplasms";
  }
  else if (code > 239 & code <= 279) {
    result <- "E_N_M";
  }
  else if (code > 279 & code <= 289) {
    result <- "BloodDiseases";
  }
  else if (code > 289 & code <= 319) {
    result <- "MentalDisorders";
  }
  else if (code > 319 & code <= 389) {
    result <- "NervousSystems";
  }
  else if (code > 390 & code <= 459) {
    result <- "Circulatory";
  }
  else if (code > 459 & code <= 519) {
    result <- "Respiratory";
  }
  else if (code > 520 & code <= 579) {
    result <- "Digestive";
  }
  else if (code > 579 & code <= 629) {
    result <- "Gentitorinary";
  }
  else if (code > 629 & code <= 679) {
    result <- "Ginic";
  }
  else if (code > 679 & code <= 709) {
    result <- "Skin";
  }
  else if (code > 709 & code <= 739) {
    result <- "Masculoskeletal";
  }
  else if (code > 739 & code <= 759) {
    result <- "CongenitalAnamolies";
  }
  else if (code > 759 & code <= 779) {
    result <- "ParinetalPeriod";
  }
  else if (code > 779 & code <= 799) {
    result <- "NoSymptoms";
  }
  else if (code > 799 & code <= 999) {
    result <- "Injury";
  }
  else {
    result <- "Other";
  }
  return(result)
}


imputeddata$diagnosis_1_ICD_Level = sapply(imputeddata$diagnosis_1, diagnosis_ICD_codes)
imputeddata$diagnosis_2_ICD_Level = sapply(imputeddata$diagnosis_2, diagnosis_ICD_codes)
imputeddata$diagnosis_3_ICD_Level = sapply(imputeddata$diagnosis_3, diagnosis_ICD_codes)


imputeddata$diagnosis_1_ICD_Level <- as.factor(imputeddata$diagnosis_1_ICD_Level)
imputeddata$diagnosis_2_ICD_Level <- as.factor(imputeddata$diagnosis_2_ICD_Level)
imputeddata$diagnosis_3_ICD_Level<- as.factor(imputeddata$diagnosis_3_ICD_Level)

imputeddata=subset(imputeddata,select=-c(diagnosis_1,diagnosis_2,diagnosis_3))

### Reverting the train and test datasets back
train_new=imputeddata
train_new$target=target

str(train_new)

# Under sample the data
train =ovun.sample(target~.,train_new,method="under")
train1=train$data
str(train1)

# Descritize the numeric columns
library(arules)
train1$num_lab_procedures=discretize(train1$num_lab_procedures)
train1$num_procedures=as.factor(train1$num_procedures)
train1$num_medications=discretize(train1$num_medications)
train1$num_diagnoses=discretize(train1$num_diagnoses)
train1$No_of_days_Stayed=discretize(train1$No_of_days_Stayed)


rules <- apriori(train1,
                 parameter = list(minlen=2, supp=0.02, conf=0.6),
                 appearance = list(rhs=c("target=Within30days"),
                                   default="lhs"),
                 control = list(verbose=F))
rules.sorted <- sort(rules, by="lift",decreasing = T)
inspect(head(rules.sorted,10))

dev.off()
library(arulesViz)
plot(head(rules.sorted,10))
plot(head(rules.sorted,10), method="graph",engine="html", control=list(type="items"))
plot(head(rules.sorted,10), method="paracoord", control=list(type="items"))

x=as(head(rules.sorted,10), "data.frame")
write.csv(x,"finalrulesall.csv")
