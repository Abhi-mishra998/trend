pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
        NAMESPACE = 'trend-app'
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'
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
                            kubeval "$file" --kubernetes-version 1.28.0 --ignore-missing-schemas || true
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
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG_FILE')]) {
                    script {
                        sh """
                        export KUBECONFIG=\${KUBECONFIG_FILE}

                        # Test kubectl connection first
                        kubectl cluster-info

                        # Create namespace if it doesn't exist
                        kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                        # Apply manifests (Service should expose ports 80/443)
                        kubectl apply -f k8s/

                        # Update deployment with new image
                        kubectl set image deployment/trend-app-deployment trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${NAMESPACE}

                        # Wait for rollout
                        kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE} --timeout=10m

                        # Wait for pods to be ready (retry to avoid SG or network issues)
                        kubectl wait --for=condition=ready pod -l app=trend-app -n ${NAMESPACE} --timeout=600s
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                    export KUBECONFIG=\${KUBECONFIG_FILE}
                    echo "Pods in namespace ${NAMESPACE}:"
                    kubectl get pods -n ${NAMESPACE}
                    echo "Services in namespace ${NAMESPACE}:"
                    kubectl get svc -n ${NAMESPACE}
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
