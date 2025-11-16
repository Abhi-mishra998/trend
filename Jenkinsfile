pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        NAMESPACE = 'trend-app'
        KUBECONFIG_PATH = 'kubeconfig-creds'
        LB_URL = 'k8s-trendapp-trendapp-c1fc9d0bf7-c6d184859c49866d.elb.ap-south-1.amazonaws.com'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                sh '''
                docker run --rm -v $PWD:/app -w /app node:18-alpine sh -c "
                    npm install &&
                    npm run build
                "
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIAL_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
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
                withCredentials([file(credentialsId: "${KUBECONFIG_PATH}", variable: 'KC')]) {
                    sh '''
                    kubectl apply -f k8s/ --kubeconfig=$KC

                    kubectl set image deployment/trend-app-deployment \
                        trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} \
                        -n ${NAMESPACE} --kubeconfig=$KC

                    kubectl rollout status deployment/trend-app-deployment \
                        -n ${NAMESPACE} --kubeconfig=$KC
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                echo "Application URL: http://${LB_URL}/"
                curl -I --max-time 20 http://${LB_URL}/ || echo "Health check failed"
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
