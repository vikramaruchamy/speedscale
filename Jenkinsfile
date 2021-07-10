#!groovy
 //Best of Jenkinsfile
//Creator Ravichandra

//`Jenkinsfile` is a groovy script DSL for defining CI/CD workflows for Jenkins
pipeline {
  //Chane Agent value to the pools or slave names if you have more than 1 jenkins instance
  agent any
  environment {
    COMMITDATE = ""
  }
  // Pipeline is partitioned into stages
  stages {
    // This is the first phase in the pipeline which will pull the source code from the repository and fetch's the branch name for future use
    stage('setup') {
      steps {
        script {
          COMMITDATE = sh(returnStdout: true, script: "git show -s --format=%ci ${GIT_COMMIT}")
        }
        echo "${COMMITDATE}"
        sh script: 'git rev-parse --abbrev-ref HEAD'
        echo env.GIT_BRANCH
      }
    }
    stage('speedscale') {
      steps {
        script {
          sh 'kubectl apply -f qa-deployment.yaml'
          sh 'kubectl patch deployment nginx-deployment --patch "$(cat scenario.yaml)"  -n qa'
          sh 'sh speedscale.sh'
        }
      }
    }
    stage('deployment') {
      steps {
        sh 'printenv'
        sh 'kubectl apply -f deployment.yaml'
      }
    }
  }
    post{
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}
