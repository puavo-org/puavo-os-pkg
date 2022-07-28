pipeline {
  agent {
    docker {
      image 'debian:bullseye'
      args '-u root'
    }
  }

  stages {
    stage('Use archive.opinsys.fi') {
      steps {
        sh '''
          base64 -d <<'EOF' > /etc/apt/trusted.gpg.d/opinsys.gpg
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
EOF
          cat <<'EOF' > /etc/apt/sources.list.d/puavo-os-remote.list
deb http://archive-internal.opinsys.fi/puavo bullseye main contrib non-free
deb-src http://archive-internal.opinsys.fi/puavo bullseye main contrib non-free
EOF
          apt-get update
          apt-get -y dist-upgrade
        '''
      }
    }

    stage('Install puavo-pkg and build dependencies') {
      steps {
        sh '''
          apt-get install -y jq make puavo-pkg
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
