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
                        sh '''
                            if command -v hadolint &>/dev/null; then
                                hadolint Dockerfile || true
                            else
                                echo "hadolint not installed, skipping..."
                            fi
                        '''
                    }
                }

                stage('Terraform Validate') {
                    steps {
                        dir('infrastructure') {
                            sh '''
                                terraform init -backend=false
                                terraform fmt -check || true
                                terraform validate
                            '''
                        }
                    }
                }

                stage('Kubernetes Validate') {
                    steps {
                        sh '''
                            if command -v kubeval &>/dev/null; then
                                for file in k8s/*.yaml; do
                                    echo "Validating: $file"
                                    kubeval "$file" --kubernetes-version 1.29.0 || true
                                done
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
                    sh """
                        echo 'Building Docker image...'
                        docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                        docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                    """
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    sh """
                        echo 'Testing Docker container...'

                        docker run -d --name test-container -p 3001:3000 ${DOCKERHUB_REPO}:${IMAGE_TAG}

                        # Wait for the container to be healthy
                        for i in {1..30}; do
                            if curl -f http://localhost:3001 > /dev/null 2>&1; then
                                echo 'App is responding!'
                                break
                            fi
                            echo "Waiting for app to start... attempt \$i"
                            sleep 5
                        done

                        # Final check
                        curl -f http://localhost:3001 || exit 1

                        docker stop test-container || true
                        docker rm test-container || true
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIAL_ID}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin

                            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                            docker push ${DOCKERHUB_REPO}:latest

                            docker logout || true
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([string(credentialsId: "${KUBECONFIG_CREDENTIAL_ID}", variable: 'KUBECONFIG_CONTENT')]) {
                        sh '''
                            echo "$KUBECONFIG_CONTENT" | base64 -d > /tmp/kubeconfig
                            export KUBECONFIG=/tmp/kubeconfig

                            # Create namespace if it doesn't exist
                            kubectl create namespace ''' + NAMESPACE + ''' --dry-run=client -o yaml | kubectl apply -f -

                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/namespace.yaml || true
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            kubectl apply -f k8s/hpa.yaml || true
                            kubectl apply -f k8s/resource-quota.yaml || true
                            kubectl apply -f k8s/network-policy.yaml || true

                            # Update the deployment with the new image
                            kubectl set image deployment/trend-app-deployment trend-app=''' + DOCKERHUB_REPO + ''':''' + IMAGE_TAG + ''' -n ''' + NAMESPACE + '''

                            # Wait for rollout to complete
                            kubectl rollout status deployment/trend-app-deployment -n ''' + NAMESPACE + ''' --timeout=5m
                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    withCredentials([string(credentialsId: "${KUBECONFIG_CREDENTIAL_ID}", variable: 'KUBECONFIG_CONTENT')]) {
                        sh '''
                            echo "$KUBECONFIG_CONTENT" | base64 -d > /tmp/kubeconfig
                            export KUBECONFIG=/tmp/kubeconfig

                            echo "Checking pod status..."
                            kubectl get pods -n ''' + NAMESPACE + '''

                            echo "Checking service status..."
                            kubectl get svc -n ''' + NAMESPACE + '''

                            echo "Waiting for pods to be ready..."
                            kubectl wait --for=condition=ready pod -l app=trend-app -n ''' + NAMESPACE + ''' --timeout=300s

                            echo "External URL:"
                            kubectl get svc trend-app-service -n ''' + NAMESPACE + ''' -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" || echo "LoadBalancer pending..."
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
            echo "Image deployed: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        always {
            sh "docker system prune -f || true"
        }
    }
}
