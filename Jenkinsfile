pipeline {
    agent any
    
    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        KUBECONFIG_CREDENTIAL_ID = 'kubeconfig-creds'
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
        NAMESPACE = 'trend-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        
        stage('Lint & Validate') {
            parallel {
                stage('Dockerfile Lint') {
                    steps {
                        script {
                            sh '''
                                if command -v hadolint &> /dev/null; then
                                    hadolint Dockerfile || true
                                else
                                    echo "hadolint not installed, skipping..."
                                fi
                            '''
                        }
                    }
                }
                stage('Terraform Validate') {
                    steps {
                        dir('infrastructure') {
                            sh '''
                                terraform fmt -check || true
                                terraform init -backend=false
                                terraform validate
                            '''
                        }
                    }
                }
                stage('Kubernetes Validate') {
                    steps {
                        sh '''
                            if command -v kubeval &> /dev/null; then
                                kubeval k8s/*.yaml --kubernetes-version 1.29.0 || true
                            else
                                echo "kubeval not installed, skipping..."
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    sh """
                        docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                        docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                    """
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo 'Testing Docker image...'
                        sh """
                            # Run container in background
                            docker run -d --name test-container -p 3001:3000 ${DOCKERHUB_REPO}:${IMAGE_TAG}

                            # Wait for container to be ready
                            sleep 10

                            # Test HTTP endpoint
                            if command -v curl &> /dev/null; then
                                curl -f http://localhost:3001 || exit 1
                            else
                                docker exec test-container wget --quiet --tries=1 --spider http://localhost:3000 || exit 1
                            fi

                            # Cleanup
                            docker stop test-container
                            docker rm test-container
                        """
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    echo 'Pushing to DockerHub...'
                    withCredentials([usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIAL_ID}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                            docker push ${DOCKERHUB_REPO}:latest
                            docker logout
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying to Kubernetes with image: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIAL_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                            # Create namespace if not exists
                            kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                            # Apply all Kubernetes manifests
                            kubectl apply -f k8s/namespace.yaml
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            kubectl apply -f k8s/hpa.yaml

                            # Update deployment image
                            kubectl set image deployment/trend-app-deployment \
                                trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} \
                                -n ${NAMESPACE}

                            # Wait for rollout
                            kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE} --timeout=5m

                            # Verify deployment
                            kubectl get pods -n ${NAMESPACE}
                            kubectl get svc -n ${NAMESPACE}
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo 'Verifying deployment health...'
                    withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIAL_ID}", variable: 'KUBECONFIG')]) {
                        sh """
                            # Check pod status
                            kubectl get pods -n ${NAMESPACE} -l app=trend-app
                            
                            # Check service
                            kubectl get svc -n ${NAMESPACE} trend-app-service
                            
                            # Get LoadBalancer URL (if available)
                            kubectl get svc trend-app-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "LoadBalancer pending..."
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Deployed image: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            // Cleanup
            sh 'docker system prune -f || true'
        }
    }
}
