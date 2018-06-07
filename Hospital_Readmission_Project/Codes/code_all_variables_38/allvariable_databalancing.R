##################### Reading the Desired datasets into the environment ##################
rm(list=ls(all=T)) # Clear the global environment
setwd('E:/PHD/ML/Datasets and Description') # Set Working directory


##### Train
train = read.csv('Train.csv' ,header = T,na.strings = '?')
train_diagnosis=read.csv('Train_Diagnosis_TreatmentData.csv',header = T,na.strings = '?')
train_hospitilization=read.csv('Train_HospitalizationData.csv',header = T,na.strings = '?')

##### Test
test = read.csv('Test.csv' ,header = T,na.strings = '?')
test_diagnosis=read.csv('Test_Diagnosis_TreatmentData.csv',header = T,na.strings = '?')
test_hospitilization=read.csv('Test_HospitalizationData.csv',header = T,na.strings = '?')

##### Check the no of na in the dataset
sum(is.na(train$weight)) 

################ Merge the Data Frames ###########################
#### Train
train_final = merge(train,train_diagnosis,by="patientID")
train_final = merge(train_final,train_hospitilization,by='patientID')

#### Test
test_final = merge(test,test_diagnosis,by="patientID")
test_final = merge(test_final,test_hospitilization,by='patientID')

#### Check the structur and summary
str(train_final)
str(test_final)
summary(train_final)

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
testfake = subset(test_final,select = -c(weight, payer_code,medical_specialty))

### Get the data frame only if the discharge disposition id is not equal to 11,19,20,21##
train_dis_11=trainfake[trainfake$discharge_disposition_id==11,]
train_dis_19=trainfake[trainfake$discharge_disposition_id==19,]
train_dis_20=trainfake[trainfake$discharge_disposition_id==20,]
train_dis_21=trainfake[trainfake$discharge_disposition_id==21,]

table(train_dis_11$readmitted)
table(train_dis_19$readmitted)
table(train_dis_20$readmitted)
table(train_dis_21$readmitted)


### As the discharge disposition of 11,13,14,19,20,21 are not making up any predictions so we will be removing them from 
### train data and as they are under the case of No condition we will be replacing them with NO directly.

### 768 data points are been droped from the train data
train_discharge=trainfake[!(trainfake$discharge_disposition_id==11 | trainfake$discharge_disposition_id==19 | trainfake$discharge_disposition_id==20 |trainfake$discharge_disposition_id==21),]
test_discharge=testfake

###################### Cross tabs with target and the variables by using Ggplot #############################
dev.off()

train_readmitted=trainfake[trainfake$readmitted=="Within30days",]
ggplot(train_discharge, aes(gender)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(age)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(max_glu_serum)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(A1Cresult)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(metformin)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(repaglinide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(nateglinide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(chlorpropamide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(glimepiride)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(acetohexamide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(glipizide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(glyburide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(tolbutamide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(pioglitazone)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(rosiglitazone)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(acarbose)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(miglitol)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(troglitazone)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(tolbutamide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(tolazamide)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(insulin)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(glyburide.metformin)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(glipizide.metformin)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(metformin.rosiglitazone)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(metformin.pioglitazone)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(change)) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(as.factor(admission_type_id))) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(as.factor(discharge_disposition_id))) + geom_bar(aes(fill =readmitted ), position = "dodge")
ggplot(train_discharge, aes(as.factor(admission_source_id))) + geom_bar(aes(fill =readmitted ), position = "dodge")


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

####################### Case 1 using all the varaibles without droping ##############

################### Split the dataset into test and train ####################
library(caret)
set.seed(9983)
train <- createDataPartition(train_new$target, times = 1, p = 0.7, list = F)
train_data <- train_new[train,]
validation_data <- train_new[-train,]

###################### Balancing techniques ###############################

library(ROSE)
library(rpart)
table(train_data$target)
# Upsampling the data
data_balanced_over <- ovun.sample(target ~ ., data = train_data, method = "over",N=50000, seed = 1)$data
# Smoting
data_balanced_smote <- SMOTE(target ~ ., train_data, perc.over = 300, perc.under=100)
# Rose Smoting
data_balanced_rose <- ROSE(target ~ ., train_data, seed = 1,N=40000)$data
# Under
data_under <- ovun.sample(target~. ,train_data,method="under")$data
################# Modeling Techniques #####################################

######### Logistic Regression #####################3
ctrl <- trainControl(method = "repeatedcv", number = 5, savePredictions = TRUE,verboseIter = T)

# Using smote
mod_fit_smote <- train(target~.,data=data_balanced_smote, method="glm", family="binomial",
                 trControl = ctrl, tuneLength = 2)
summary(mod_fit_smote)
mod_fit_smote

# Using over
mod_fit_over <- train(target~.,data=data_balanced_over, method="glm", family="binomial",
                       trControl = ctrl, tuneLength = 2)
summary(mod_fit_over)
mod_fit_over

# Using rose
mod_fit_rose <- train(target~.,data=data_balanced_rose, method="glm", family="binomial",
                       trControl = ctrl, tuneLength = 2)
summary(mod_fit_rose)
mod_fit_rose


# Using under
mod_fit_under <- train(target~.,data=data_under, method="glm", family="binomial",
                      trControl = ctrl, tuneLength = 2)
summary(mod_fit_under)
mod_fit_under
## Metric for verification
pred_under = predict(mod_fit_under, newdata=validation_data)
confusionMatrix(data=pred_under, validation_data$target,positive = "NO")

library(pROC)
roc(as.numeric(validation_data$target),as.numeric(pred_under))

pred_smote = predict(mod_fit_smote, newdata=validation_data)
confusionMatrix(data=pred_smote, validation_data$target,positive = "NO")

library(pROC)
roc(as.numeric(validation_data$target),as.numeric(pred_smote))

pred_over = predict(mod_fit_over, newdata=validation_data)
confusionMatrix(data=pred_over, validation_data$target,positive = "NO")

library(pROC)
roc(as.numeric(validation_data$target),as.numeric(pred_over))

pred_rose = predict(mod_fit_rose, newdata=validation_data)
confusionMatrix(data=pred_rose, validation_data$target,positive = "NO")

library(pROC)
roc(as.numeric(validation_data$target),as.numeric(pred_rose))

varImp(mod_fit_over)
#####################################################################################
######################### Naive Bayes #######################################
library(e1071)
## Under
y_under=data_under$target
x_under=subset(data_under,select=-c(target))


model_under = train(x_under,y_under,'nb',trControl=trainControl(method='cv',number=10,verboseIter = T))
model_under

## Over
y=data_balanced_over$target
x=subset(data_balanced_over,select=-c(target))

model = train(x,y,'nb',trControl=trainControl(method='cv',number=10,verboseIter = T))
model

## rose
y_rose=data_balanced_rose$target
x_rose=subset(data_balanced_rose,select=-c(target))

model_rose = train(x_rose,y_rose,'nb',trControl=trainControl(method='cv',number=3,verboseIter = T))
model_rose

## Smote
y_smote=data_balanced_smote$target
x_smote=subset(data_balanced_smote,select=-c(target))

model_smote = train(x_smote,y_smote,'nb',trControl=trainControl(method='cv',number=3,verboseIter = T))
model_smote


### Predicting on validation
valid_under=predict(model_under,subset(validation_data,select=-c(target)),type = "raw")
confusionMatrix(validation_data$target,valid_under)

roc(as.numeric(validation_data$target),as.numeric(valid_under))

valid=predict(model,subset(validation_data,select=-c(target)),type = "raw")
confusionMatrix(validation_data$target,valid)

roc(as.numeric(validation_data$target),as.numeric(valid))

valid_rose=predict(model_rose,subset(validation_data,select=-c(target)),type = "raw")
confusionMatrix(validation_data$target,valid_rose)

roc(as.numeric(validation_data$target),as.numeric(valid_rose))

valid_smote=predict(model_smote,subset(validation_data,select=-c(target)),type = "raw")
confusionMatrix(validation_data$target,valid_smote)

roc(as.numeric(validation_data$target),as.numeric(valid_smote))

### Predicting on test data
naive_test=predict(model_under,test_copy)
frame_naive=data.frame(patientID,naive_test)
table(frame_naive$naive_test)
write.csv(frame_naive,"frame_niave.csv")
varImp(model)

############################ Decision Tree ##################
# Build a Classification model using rpart 
library(rpart)
library(rattle)
library(rpart.plot)
require(maptree)
dev.off()
############# Over ###################3
DT_over <- rpart(target~., data=data_balanced_over,cp=0.0068) # Default cp = 0.01
draw.tree(DT_over,cex = 0.7)
# Write rules
sink("featurerules.txt")
print(asRules(DT_over))
sink()

plotcp(DT_over)
rpart.plot(DT_over)

# Predict on Train and Test data
predCartTest_dt <- predict(DT_over, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt,positive = "Within30days")

library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt))
print(auc)

################ smote ######################3
DT_smote <- rpart(target~., data=data_balanced_smote,cp=0.015) # Default cp = 0.01
plotcp(DT_smote)
draw.tree(DT_smote,cex = 0.8)
rpart.plot(DT_smote)

# Predict on Train and Test data
predCartTest_dt_smote <- predict(DT_smote, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt_smote)
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt_smote))
print(auc)

########### Rose ############3333
DT_rose <- rpart(target~., data=data_balanced_rose,cp=0.0027) # Default cp = 0.01
plotcp(DT_rose)
rpart.plot(DT_rose,faclen = 2,tweak = 1.2)
plot(printcp(DT_rose), type='b')

# Predict on Train and Test data
predCartTest_dt_rose <- predict(DT_rose, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt_rose,positive = "Within30days")
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt_rose))
print(auc)

###################3 Under sampling ################
DT_under <- rpart(target~., data=data_under,cp=0.0035) # Default cp = 0.01
print(DT_under)
plotcp(DT_under)
rpart.plot(DT_under,digits = 0,tweak = 1.2)

# Predict on Train and Test data
predCartTest_dt_under <- predict(DT_under, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt_under,positive = "NO")
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt_under))
print(auc)

## Predict on the test
dt_test=predict(DT_rose,test_copy,type="class")
frame_dt=data.frame(patientID,dt_test)
table(frame_dt$dt_test)
################################################################################

#### Ada Boost
library(ada) 

### Under
ada_under = ada(target ~ ., iter = 5,data = data_under, loss="logistic") 
ada_under

# predict the values using model on test data sets. 
val_ada_under = predict(ada_under, validation_data)
confusionMatrix(validation_data$target,val_ada_under)
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_under))
print(auc)

#### Over
library(ada) 
ada_over = ada(target ~ ., iter = 30,data = data_balanced_over, loss="logistic") 
ada_over

# predict the values using model on test data sets. 
val_ada_over = predict(ada_over, validation_data);
confusionMatrix(validation_data$target,val_ada_over)

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_over))
print(auc)

#### Smote
ada_smote = ada(target ~ ., iter = 20,data = data_balanced_smote, loss="logistic") 
ada_smote

# predict the values using model on test data sets. 
val_ada_smote = predict(ada_smote, validation_data);
confusionMatrix(validation_data$target,val_ada_smote)

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_smote))
print(auc)

#### Rose
ada_rose = ada(target ~ ., iter = 10,data = data_balanced_rose, loss="logistic") 
ada_rose

# predict the values using model on test data sets. 
val_ada_rose = predict(ada_rose, validation_data);
confusionMatrix(validation_data$target,val_ada_rose,positive = "NO")

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_rose))
print(auc)

## Predict on the test
ada_test=predict(ada_rose,test_copy)
frame_ada=data.frame(patientID,ada_test)
table(frame_ada$ada_test)
###########################################################################
