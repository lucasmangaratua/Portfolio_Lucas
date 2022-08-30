library(randomForest)
library(caret)

# Read Data
data = read.csv("2017-gltd-tree-mortality-rate-input-data.csv", 
                header=TRUE,sep=",")
data$Tingkat_Mortalita_Sebenarnya <- data$Actual_Deaths / data$Exposures
View(data)

#Training vs Test data
set.seed(1)
Train <- sample(nrow(data), floor(0.7*nrow(data)), replace=FALSE)
dataTrain <- data[Train,]
dataTest <- data[-Train,]
View(dataTrain)

# Random Forest
set.seed(123)
rf <- randomForest(Tingkat_Mortalita_Sebenarnya~Durasi+Umur+
                     Jenis_Kelamin+Kategori_Cacat+Jenis_Pekerjaan+
                     Indeks_Gaji_Bulanan,
                   data=dataTrain,
                   ntree = 500,
                   mtry = 1,
                   importance=T)
print(rf)
attributes(rf)

# number of trees with lowest MSE
which.min(rf$mse)
# RMSE of this optimal random forest
sqrt(rf$mse[which.min(rf$mse)])

#RSME for data OOB
rmse <- sqrt(tail(rf$mse,1))
rmse

# Prediction - test data
PredictedDR <- predict(rf, newdata=dataTest)
View(PredictedDR)
PredictedDeaths<-PredictedDR*dataTest$Exposures
ExpectedDR<-dataTest$Expected_Deaths/dataTest$Exposures
Model_Predictions<-cbind(dataTest,PredictedDR,PredictedDeaths,ExpectedDR)
MSE_E<- sum((Model_Predictions$Expected_Deaths-Model_Predictions$Actual_Deaths)^2)/nrow(Model_Predictions)
MSE_P<- sum((Model_Predictions$PredictedDeaths-Model_Predictions$Actual_Deaths)^2)/nrow(Model_Predictions)
MSE_E
MSE_P


# Error rate of Random Forest
plot(rf, cex = 3, main = "Plot Random Forest")

# Variable Importance
varImpPlot(rf,
           sort = T,
           n.var = 6,
           main = "Variable Importance")
importance(rf)
varUsed(rf)

# Tune mtry
set.seed(123)
t <- tuneRF(dataTrain[,-6], dataTrain[,6],
            stepFactor = 0.5,
            plot = TRUE,
            ntreeTry = 250,
            trace = TRUE,
            improve = 0.05)

# Write out details of R model to excel file 
TestData<-dataTest[,-c(8:10,12)]
Model_Predictions_Bind<-cbind(TestData,PredictedDR,PredictedDeaths)
write.csv(Model_Predictions_Bind, "ModelPrediction.csv")