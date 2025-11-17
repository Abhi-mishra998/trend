pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        NAMESPACE = 'trend-app'
        HARDCODE_LB_URL = 'http://k8s-trendapp-trendapp-c1fc9d0bf7-c6d184859c49866d.elb.ap-south-1.amazonaws.com/'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo "Source code successfully checked out"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKERHUB_CREDENTIAL_ID}",
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo "$PASS" | docker login -u "$USER" --password-stdin
                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_REPO}:latest
                    docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBEFILE')]) {
                    sh '''
                    export KUBECONFIG=$KUBEFILE
                    kubectl apply -f k8s/
                    kubectl set image deployment/trend-app-deployment trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${NAMESPACE}
                    kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE}
                    '''
                }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                echo "Application LoadBalancer:"
                echo "${HARDCODE_LB_URL}"

                echo "Performing health check..."
                curl -I --max-time 20 ${HARDCODE_LB_URL} || echo "Health check failed"
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
            echo "Application URL: ${HARDCODE_LB_URL}"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
