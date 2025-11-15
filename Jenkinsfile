pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
        NAMESPACE = 'trend-app'
        // Optional: If you want to use the EC2 kubeconfig path directly
        KUBECONFIG_PATH = '/home/ec2-user/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                        docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest

                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_REPO}:latest
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Using EC2 kubeconfig directly
                    sh """
                        export KUBECONFIG=${KUBECONFIG_PATH}

                        # Create namespace if it doesn't exist
                        kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                        # Apply manifests
                        kubectl apply -f k8s/

                        # Update deployment with new image
                        kubectl set image deployment/trend-app-deployment trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${NAMESPACE}

                        # Wait for rollout
                        kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE} --timeout=5m
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=${KUBECONFIG_PATH}

                        kubectl get pods -n ${NAMESPACE}
                        kubectl get svc -n ${NAMESPACE}

                        # Wait until pods are ready
                        kubectl wait --for=condition=ready pod -l app=trend-app -n ${NAMESPACE} --timeout=300s
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment successful: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        always {
            sh "docker system prune -f || true"
        }
    }
}
