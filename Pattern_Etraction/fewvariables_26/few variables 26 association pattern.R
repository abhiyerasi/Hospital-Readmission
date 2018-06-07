##################### Reading the Desired datasets into the environment ##################
rm(list=ls(all=T)) # Clear the global environment
setwd('E:/PHD/ML/Datasets and Description/feature variables') # Set Working directory

library(arules)
library(ROSE)
##### Train
train = read.csv('train_variables.csv' ,header = T,na.strings = '?')
train =ovun.sample(target~.,train,method="under")
train1=train$data
str(train1)

### Descritize all the variables which are numeric
train1$age=discretize(train1$age)
train1$num_lab_procedures=discretize(train1$num_lab_procedures)
train1$num_procedures=as.factor(train1$num_procedures)
train1$num_medications=discretize(train1$num_medications)
train1$num_diagnoses=discretize(train1$num_diagnoses)
train1$admission_source_id=discretize(train1$admission_source_id)
train1$No_of_days_Stayed=discretize(train1$No_of_days_Stayed)
train1$Month=discretize(train1$Month)
train1$year=as.factor(train1$year)

# Extract the patterns using the arules
rules <- apriori(train1,
                 parameter = list(minlen=2, supp=0.01, conf=0.6),
                 appearance = list(rhs=c("target=Within30days"),
                                   default="lhs"),
                 control = list(verbose=F))

# Sort the them by lift
rules.sorted <- sort(rules, by="lift",decreasing = T)
inspect(head(rules.sorted,10))


library(arulesViz)
plot(head(rules.sorted,10))
plot(head(rules.sorted,10), method="graph", control=list(type="items"))
plot(head(rules.sorted,10), method="graph",engine = "html", control=list(type="items"))

x=as(head(rules.sorted,10), "data.frame")
write.csv(x,"finalrules.csv")
