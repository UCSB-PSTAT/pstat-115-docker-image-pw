pipeline {
    agent {
        label 'jupyter'
    }
    stages {
        stage('Build') {
            sh podman build -t pstat115 --pull  --no-cache .
        }
        stage('Test') {
            sh podman run -it --rm localhost/pstat115 python -e "import otter"
        }
    }
}
