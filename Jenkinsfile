def parallelStages = [:]
def firstStage = [:]
def driveCommand = "flutter drive --driver=test_driver/integration_test.dart --target=integration_test/main_test.dart"
def complementCommand =  "--no-pub --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk"

pipeline {
  agent any
    stages{
      stage('Identifying connected devices'){
        steps{
          script {
            sh('adb start-server')
              def devices = sh (
                  script: "adb devices -l | awk \'NR>1 {print \$1}\'",
                  returnStdout: true
                  ).trim().split('\n')

              def isFirstIteration = true;
              for (String device : devices){
                def deviceCopy = new String(device)
                if(isFirstIteration){
                  firstStage["${deviceCopy}"] = {
                    stage("Building APK and running Flutter Driver on device ${deviceCopy}"){
                      sh 'pwd'
                        sh "${driveCommand} -d ${deviceCopy}"
                    }
                  }
                  isFirstIteration = false;
                } else {

                  parallelStages["${deviceCopy}"] = {
                    stage("Running flutter drive on Device ID: ${deviceCopy}"){
                      sh 'pwd'
                        sh "${driveCommand} ${complementCommand} -d ${deviceCopy}"
                    }
                  }
                }
            }
            firstStage.values()[0].call()
              parallel(parallelStages)
          }
        } 
      }
    }
}
