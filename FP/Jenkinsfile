pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = "docker.io"
        DOCKER_IMAGE_NAME = "EPAMFP_devsrc"
        DOCKER_IMAGE_TAG = "latest"
    }
    
    stages {
        stage("Build Docker Image") {
            steps {
                git branch: "dev", url: "https://github.com/olsydor/EPAMFP.git"
                sh "docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG ."
            }
        }
        
        stage("Push Docker Image") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'olsydor', passwordVariable: 'EHHb4G')]) {
                    sh "docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD"
                    sh "docker tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"
                    sh "docker push $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"
                }
            }
        }
    }
}
