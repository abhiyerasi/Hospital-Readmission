##################### Reading the Desired datasets into the environment ##################
rm(list=ls(all=T)) # Clear the global environment
setwd('E:/PHD/ML/Datasets and Description/feature variables') # Set Working directory


##### Train
train = read.csv('train_variables.csv' ,header = T,na.strings = '?')

##### Test
test = read.csv('test_variables.csv' ,header = T,na.strings = '?')

#### Check the structur and summary
str(train)
str(test)

patientID=test$patientID
test$patientID=NULL
################################################################################3
####################### Case 2 using only few variables ##############
library(polycor)
corcatnum=hetcor(train)

cat=train[sapply(train,is.factor)]
num=train[sapply(train,is.numeric)]

chisq.test(cat$race,cat$target)#ok
chisq.test(cat$gender,cat$target)#notok
chisq.test(cat$max_glu_serum,cat$target)#ok
chisq.test(cat$A1Cresult,cat$target)#ok
chisq.test(cat$admission_type_id,cat$target)#ok
chisq.test(cat$discharge_disposition_id,cat$target)#ok
chisq.test(cat$diagnosis_1_ICD_Level,cat$target) #ok
chisq.test(cat$diagnosis_2_ICD_Level,cat$target) #ok
chisq.test(cat$diagnosis_3_ICD_Level,cat$target) #ok
chisq.test(cat$Sulfonylurea_9,cat$target) #ok
chisq.test(cat$Thiazolidinediones_5,cat$target) #ok
chisq.test(cat$Begunaide_5,cat$target) #ok
chisq.test(cat$meglitinides_2,cat$target) #ok
chisq.test(cat$glucosides,cat$target) #not ok
chisq.test(cat$insulin,cat$target) #ok

cor(num)
chisq.test(num$age,cat$target) #ok
chisq.test(num$num_lab_procedures,cat$target)#ok
chisq.test(num$num_procedures,cat$target)
chisq.test(num$num_medications,cat$target)
chisq.test(num$num_diagnoses,cat$target)
chisq.test(num$No_of_days_Stayed,cat$target)
chisq.test(num$year,cat$target)
################### Split the dataset into test and train ####################
cols=c('race',"max_glu_serum","A1Cresult","admission_type_id","Sulfonylurea_9",
        "Thiazolidinediones_5","diabetesMed","Begunaide_5","meglitinides_2","insulin","age","num_lab_procedures",
        "num_procedures","num_medications","num_diagnoses","year","No_of_days_Stayed","target")
cols1=c('race',"max_glu_serum","A1Cresult","admission_type_id","Sulfonylurea_9",
       "Thiazolidinediones_5","diabetesMed","Begunaide_5","meglitinides_2","insulin","age","num_lab_procedures",
       "num_procedures","num_medications","num_diagnoses","year","No_of_days_Stayed")

train_final=train[cols]
test_final=test[cols1]

library(caret)
set.seed(9983)
train_rows <- createDataPartition(train_final$target, times = 1, p = 0.7, list = F)
train_data <- train_final[train_rows,]
validation_data <- train_final[-train_rows,]

###################### Balancing techniques ###############################

library(ROSE)
library(DMwR)
library(rpart)
table(train_data$target)
# Upsampling the data
data_balanced_over <- ovun.sample(target ~ ., data = train_data, method = "over",N=50000, seed = 1)$data
# Smoting
data_balanced_smote <- SMOTE(target ~ ., train_data, perc.over = 300, perc.under=100)
# Rose Smoting
data_balanced_rose <- ROSE(target ~ ., train_data, seed = 1,N=40000)$data
# Under sampling
data_under <- ovun.sample(target ~ ., train_data,method = "under")$data
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

## Rose
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

## Predict on test
naive_test=predict(model_under,test_copy)
frame_naive=data.frame(patientID,naive_test)
table(frame_naive$naive_test)
write.csv(frame_naive,"frame_niave.csv")
varImp(model)

############################ Decision Tree ##################
# Build a Classification model using rpart 
library(rpart)
library(rpart.plot)
library(rattle)
require(maptree)
############# Over ###################3
DT_over <- rpart(target~., data=data_balanced_over,cp=0.005) # Default cp = 0.01

plotcp(DT_over)
draw.tree(DT_over,cex = 0.8,pch = 0.5)
rpart.plot(DT_over)

# To extract rules
sink("rules_over.txt")
rp <- asRules(DT_over)
print(rp)
sink()


##Predict on Train and Test data
predCartTest_dt <- predict(DT_over, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt,positive = "NO")

library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt))
print(auc)

################ smote ######################3
DT_smote <- rpart(target~., data=data_balanced_smote,cp=0.0065) # Default cp = 0.01

plotcp(DT_smote)
rpart.plot(DT_smote,faclen = 1,tweak = 1.2)
draw.tree(DT_smote,cex = 0.7)

# To extract Rules
sink("rules_smote.txt")
rp <- asRules(DT_smote)
print(rp)
sink()

# Predict on Train and Test data
predCartTest_dt_smote <- predict(DT_smote, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt_smote)
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt_smote))
print(auc)

########### Rose ############3333
DT_rose <- rpart(target~., data=data_balanced_rose,cp=0.005) # Default cp = 0.01
print(DT_rose)
rpart.plot(DT_rose)
plot(printcp(DT_rose), type='b')

# Predict on Train and Test data
predCartTest_dt_rose <- predict(DT_rose, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt_rose,positive = "Within30days")
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt_rose))
print(auc)

################### Under sampling ################
DT_under <- rpart(target~., data=data_under) # Default cp = 0.01
print(DT_under)
plot(printcp(DT_under), type='b')

# Predict on Train and Test data
predCartTest_dt_under <- predict(DT_under, newdata=validation_data, type="class")
confusionMatrix(validation_data$target,predCartTest_dt_under,positive = "NO")
library(pROC)
auc <- roc(as.numeric(validation_data$target), as.numeric(predCartTest_dt_under))
print(auc)

## Predict on test
dt_test=predict(DT_rose,test,type="class")
frame_dt=data.frame(patientID,dt_test)
table(frame_dt$dt_test)
################################################################################

#### Ada Boost
library(ada) 

## Under
ada_under = ada(target ~ ., iter = 30,data = data_under, loss="logistic") 
ada_under

# predict the values using model on test data sets. 
val_ada_under = predict(ada_under, validation_data);
confusionMatrix(validation_data$target,val_ada_under)

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_under))
print(auc)
## Over
library(ada) 
ada_over = ada(target ~ ., iter = 30,data = data_balanced_over, loss="logistic") 
ada_over

# predict the values using model on test data sets. 
val_ada_over = predict(ada_over, validation_data);
confusionMatrix(validation_data$target,val_ada_over)

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_over))
print(auc)

## Smote
ada_smote = ada(target ~ ., iter = 20,data = data_balanced_smote, loss="logistic") 
ada_smote

# predict the values using model on test data sets. 
val_ada_smote = predict(ada_smote, validation_data);
confusionMatrix(validation_data$target,val_ada_smote)

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_smote))
print(auc)

## Rose
ada_rose = ada(target ~ ., iter = 10,data = data_balanced_rose, loss="logistic") 
ada_rose

# predict the values using model on test data sets. 
val_ada_rose = predict(ada_rose, validation_data);
confusionMatrix(validation_data$target,val_ada_rose,positive = "NO")

auc <- roc(as.numeric(validation_data$target), as.numeric(val_ada_rose))
print(auc)

## Predict on test
ada_test=predict(ada_rose,test)
frame_ada=data.frame(patientID,ada_test)
table(frame_ada$ada_test)
###########################################################################

