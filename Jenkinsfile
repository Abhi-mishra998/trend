pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
        NAMESPACE = 'trend-app'
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config' // Updated kubeconfig path
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint & Validate') {
            parallel {
                stage('Dockerfile Lint') {
                    steps {
                        sh '''
                        command -v hadolint >/dev/null 2>&1 || echo "Hadolint not installed"
                        hadolint Dockerfile || true
                        '''
                    }
                }
                stage('Kubernetes Validate') {
                    steps {
                        sh '''
                        command -v kubeval >/dev/null 2>&1 || echo "Kubeval not installed"
                        for file in k8s/*.yaml; do
                            echo "Validating: $file"
                            kubeval "$file" --kubernetes-version 1.28.0 || true
                        done
                        '''
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIAL_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                    docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_REPO}:latest
                    docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
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
                sh """
                export KUBECONFIG=${KUBECONFIG_PATH}
                kubectl get pods -n ${NAMESPACE}
                kubectl get svc -n ${NAMESPACE}
                kubectl wait --for=condition=ready pod -l app=trend-app -n ${NAMESPACE} --timeout=300s
                """
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
