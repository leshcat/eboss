pipeline {
  agent any
  stages {
    stage('hello world') {
      steps {
        parallel(
          "hello world": {
            echo 'Hello world!'
            sh 'date'
            
          },
          "hello world 2 parallel": {
            echo 'wow'
            
          }
        )
      }
    }
    stage('stage 2') {
      steps {
        sh 'arch'
      }
    }
  }
}