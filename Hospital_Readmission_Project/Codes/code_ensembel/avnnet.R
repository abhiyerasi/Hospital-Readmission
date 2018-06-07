rm(list=ls(all=T))
setwd('E:/PHD/ML/Datasets and Description')

# Importing the dataset

## Train
train = read.csv('Train.csv' ,header = T,na.strings = '?')
train_diagnosis=read.csv('Train_Diagnosis_TreatmentData.csv',header = T,na.strings = '?')
train_hospitilization=read.csv('Train_HospitalizationData.csv',header = T,na.strings = '?')

## Test
test = read.csv('Test.csv' ,header = T,na.strings = '?')
test_diagnosis=read.csv('Test_Diagnosis_TreatmentData.csv',header = T,na.strings = '?')
test_hospitilization=read.csv('Test_HospitalizationData.csv',header = T,na.strings = '?')

# Check the structure
str(train)
str(train_diagnosis)
str(train_hospitilization)

length(levels(train_hospitilization$patientID))
################ Merge the Data Frames First ###########################
# Train
train_final = merge(train,train_diagnosis,by="patientID")
train_final = merge(train_final,train_hospitilization,by='patientID')

# Test
test_final = merge(test,test_diagnosis,by="patientID")
test_final = merge(test_final,test_hospitilization,by='patientID')

# Check the structure
str(train_final)
str(test_final)
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

trainfake = subset(train_final, select = -c(weight, payer_code,medical_specialty))
testfake = subset(test_final,select = -c(weight, payer_code,medical_specialty))

### Get the data frame only if the discharge disposition id is not equal to 11,19,20,21##
### As the discharge disposition of 11,19,20,21 are not making up any predictions so we will be removing them from 
### train data and as they are under the case of No condition we will be replacing them with NO directly.
train_discharge=trainfake[!(trainfake$discharge_disposition_id==11 | trainfake$discharge_disposition_id==19 | trainfake$discharge_disposition_id==20 |trainfake$discharge_disposition_id==21),]
test_discharge=testfake


####################### levels Equalising #########################
# convert some numeric attributes to factors
cols=c("admission_type_id","discharge_disposition_id","admission_source_id")

train_discharge[cols] = lapply(train_discharge[cols], factor)
test_discharge[cols] = lapply(test_discharge[cols], factor)

# Convert the levels of admission type id into two levels
levels(train_discharge$admission_type_id)=c("emergency","emergency","casual","casual","casual","casual","emergency","casual")
levels(test_discharge$admission_type_id)=c("emergency","emergency","casual","casual","casual","casual","emergency","casual")

# Convert the levels of discharge_disposition_id 
levels(train_discharge$discharge_disposition_id)=c("dis_home","Another_hopital","SNF","ICF","Another_ICU","Home_HomeHealthSevrice","AMA","Nothing","Nothing","Nothing","Nothing","Nothing","MF","SNF","Nothing","Nothing","Null","Another_Rehab","Long_term","Nothing","Not_Mapped","Nothing","Pshychiartic","Expired")
levels(test_discharge$discharge_disposition_id)=c("dis_home","Another_hopital","SNF","ICF","Another_ICU","Home_HomeHealthSevrice","AMA","Nothing","Nothing","Expired","Nothing","MF","SNF","Nothing","Null","Nothing","Another_Rehab","Long_term","Nothing","Not_Mapped","Pshychiartic")

# Convert the levels of admission_source_id
levels(train_discharge$admission_source_id)=c(1,2,3,4,5,4,7,8,9,4,11,13,14,9,9,22,25)
levels(test_discharge$admission_source_id)=c(1,2,3,4,5,4,7,8,9,4,14,9,9,22,25)

# Convert age two numeric from ordinal
levels(train_discharge$age)=c(5,15,25,35,45,55,65,75,85,95)
levels(test_discharge$age)=c(5,15,25,35,45,55,65,75,85,95)

# Create the features named No of days and the month in which they stayed in hospital before discharge
cols=c("Admission_date","Discharge_date")
train_discharge[cols] = lapply(train_discharge[cols], as.Date)
test_discharge[cols] = lapply(test_discharge[cols], as.Date)

train_discharge$No_of_days_Stayed=train_discharge$Discharge_date-train_discharge$Admission_date
train_discharge$No_of_days_Stayed=as.numeric(train_discharge$No_of_days_Stayed)
train_discharge$Month =as.factor(format(as.Date(train_discharge$Admission_date), "%m"))

test_discharge$No_of_days_Stayed=test_discharge$Discharge_date-test_discharge$Admission_date
test_discharge$No_of_days_Stayed=as.numeric(test_discharge$No_of_days_Stayed)
test_discharge$Month = as.factor(format(as.Date(test_discharge$Admission_date), "%m"))

# Just renaming the levels for better intiution
levels(train_discharge$A1Cresult)=c("abnormal","abnormal","not_tested","normal")
levels(test_discharge$A1Cresult)=c("abnormal","abnormal","not_tested","normal")

levels(train_discharge$max_glu_serum)=c("abnormal","abnormal","not_tested","normal")
levels(test_discharge$max_glu_serum)=c("abnormal","abnormal","not_tested","normal")

######################### Remove the variables which are not sensing##################################
str(train_discharge)
str(test_discharge)

train_drop = subset(train_discharge, select = -c(patientID,acetohexamide,AdmissionID,Admission_date,Discharge_date))

test_patientid=test_discharge$patientID
test_drop = subset(test_discharge, select = -c(patientID,acetohexamide,AdmissionID,Admission_date,Discharge_date))

## releveling the test dataset so doesnt make issue while predicting using the model
levels(test_drop$chlorpropamide)=c("No","Steady","Down","Up")
levels(test_drop$troglitazone)=c("No","Steady")
levels(test_drop$metformin.pioglitazone)=c("No","Steady")

str(train_drop)
str(test_drop)

# Drop all the dataframes which were not making any sense
rm(train,trainfake,finalnavalues,train_diagnosis,train_dis_11,train_dis_19,train_dis_20,train_dis_21,train_discharge,train_final,train_hospitilization,train_null_values)
rm(test,test_diagnosis,test_discharge,test_final,test_hospitilization,testfake)

################################ Imputation ##################################
target=train_drop$readmitted
traintoput=subset(train_drop,select =-c(readmitted))
fulldata=rbind(traintoput,test_drop)

library(DMwR)
imputeddata=centralImputation(fulldata)

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
train_new=imputeddata[1:33882,]
test_new=imputeddata[33883:48512,]
test_new$patientID=test_patientid
train_new$target=target

test_copy=test_new
patientID=test_copy$patientID
test_copy$patientID=NULL
# clean some global variables
rm(fulldata,imputeddata,test_drop,train_drop,traintoput)

str(train_new)
#########################Split the dataset into test and train 

train_new$acetohexamide=NULL

str(train_new)
library(caret)
set.seed(9983)
train <- createDataPartition(train_new$target, times = 1, p = 0.7, list = F)
train_data <- train_new[train,]
validation_data <- train_new[-train,]
##################### Model Building ####################

# Split the data where target is no and with in 30days and make two dataframes
train_no=train_data[train_data$target=="NO",]
train_readmitted=train_data[train_data$target=="Within30days",]


# Make the n sample dataframes
train_1=train_no[1:3000,]
train_2=train_no[3001:6000,]
train_3=train_no[6001:9000,]
train_4=train_no[9001:12000,]
train_5=train_no[12001:15000,]
train_6=train_no[15001:18000,]
train_7=train_no[18001:20387,]

# Combine the train sampled models and readmitted
model1=rbind(train_1,train_readmitted)
model2=rbind(train_2,train_readmitted)
model3=rbind(train_3,train_readmitted)
model4=rbind(train_4,train_readmitted)
model5=rbind(train_5,train_readmitted)
model6=rbind(train_6,train_readmitted)
model7=rbind(train_7,train_readmitted)


# Build the model using the baseline of caret
model11 = train(subset(model1,select=-c(target)),model1$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))
model22 = train(subset(model2,select=-c(target)),model2$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))
model33 = train(subset(model3,select=-c(target)),model3$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))
model44 = train(subset(model4,select=-c(target)),model4$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))
model55 = train(subset(model5,select=-c(target)),model5$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))
model66 = train(subset(model6,select=-c(target)),model6$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))
model77 = train(subset(model7,select=-c(target)),model7$target,'avNNet',trControl=trainControl(method='cv',number=2,verboseIter = T))

# Check the summary of the model
model11
model22
model33
model44
model55
model66
model77

# Predict on the validation data
dt_test1=predict(model11,subset(validation_data,select=-c(target)),type = "prob")
dt_test2=predict(model22,subset(validation_data,select=-c(target)),type = "prob")
dt_test3=predict(model33,subset(validation_data,select=-c(target)),type = "prob")
dt_test4=predict(model44,subset(validation_data,select=-c(target)),type = "prob")
dt_test5=predict(model55,subset(validation_data,select=-c(target)),type = "prob")
dt_test6=predict(model66,subset(validation_data,select=-c(target)),type = "prob")
dt_test7=predict(model77,subset(validation_data,select=-c(target)),type = "prob")



# Attach all the predicted  value and take the average
final_no=dt_test1+dt_test2+dt_test3+dt_test4+dt_test5+dt_test6+dt_test7
final_no$NO=final_no$NO/7
final_no$Within30days=final_no$Within30days/7

y=data.frame(final_no$Within30days,validation_data$target)
y=y[y$validation_data.target=="Within30days",]
mean(y$final_no.Within30days)

# Adjust threshold suchthat accuracy is nearby 50 and no information rate is low
final_no$NO=ifelse(final_no$NO>0.5,1,0)
final_no$Within30days=ifelse(final_no$Within30days>0.4657,1,0)
final_no$Within30days=as.factor(final_no$Within30days)

table(final_no$Within30days)

target=validation_data$target
levels(target)=c(0,1)
table(target)

table(target,final_no$Within30days)

x=confusionMatrix(target,final_no$Within30days,positive = '0')
x
library(pROC)
roc(as.numeric(final_no$Within30days),as.numeric(target))

# Predict on the test dataset
test1=predict(model11,test_new,type = "prob")
test2=predict(model22,test_new,type = "prob")
test3=predict(model33,test_new,type = "prob")
test4=predict(model44,test_new,type = "prob")
test5=predict(model55,test_new,type = "prob")
test6=predict(model66,test_new,type = "prob")
test7=predict(model77,test_new,type = "prob")

final_no=test1+test2+test3+test4+test5+test6+test7
final_no$NO=final_no$NO/7
final_no$Within30days=final_no$Within30days/7

final_no$Within30days=ifelse(final_no$Within30days>0.5,1,0)
final_no$pred=as.factor(final_no$Within30days)
levels(final_no$pred)=c("NO","Within30days")


final_cluster=data.frame(test_patientid,final_no$pred)
xyz=merge(final_cluster,test_new,by.x = "test_patientid",by.y = "patientID")
write.csv(xyz,"xyz.csv")
table(final_cluster$final_no.pred)
write.csv(final_cluster,"final_cluster_avnnet.csv")
colnames(test_new)

