pipeline {
    agent {
        label 'jupyter'
    }
    stages {
        stage('Build') {
            podman build -t pstat115 --pull  --no-cache .
        }
        stage('Test') {
            podman run -it --rm localhost/pstat115 python -e "import otter"
        }
    }
}
