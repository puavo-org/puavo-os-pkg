pipeline {
  agent {
    docker {
      image 'debian:bullseye'
      args '-u root'
    }
  }

  stages {
    stage('Install puavo-pkg and build dependencies') {
      steps {
        sh '''
          apt-get update
          apt-get -y dist-upgrade
          apt-get install -y make puavo-pkg
        '''
      }
    }

    stage('Build puavo-pkg packages') {
      steps {
        sh '''
          make all
        '''
      }
    }
  }
}
