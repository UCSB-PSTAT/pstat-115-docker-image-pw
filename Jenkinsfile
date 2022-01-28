pipeline {
    agent {
        label 'jupyter'
    }
    stages {
        stage('Build') {
            steps {
                sh podman build -t pstat115 --pull  --no-cache .
            }
        }
        stage('Test') {
            steps {
                sh podman run -it --rm localhost/pstat115 python -e "import otter"
            }
        }
    }
}
