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

        stage('Install Dependencies & Build App') {
            steps {
                sh '''
                # Install Node.js dependencies
                npm install

                # Build the React app (creates dist/ folder)
                npm run build
                '''
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
                            kubeval "$file" --kubernetes-version 1.31.0 --ignore-missing-schemas || true
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
                    # Build Docker image (now that dist/ exists from build stage)
                    docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                    docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest

                    # Login and push
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

                        # Apply all Kubernetes manifests
                        kubectl apply -f k8s/

                        # Update deployment with new image
                        kubectl set image deployment/trend-app-deployment trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${NAMESPACE}

                        # Wait for rollout to complete
                        kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE} --timeout=10m

                        # Wait for pods to be ready
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

                    echo "=== Deployment Verification ==="
                    echo "Pods in namespace ${NAMESPACE}:"
                    kubectl get pods -n ${NAMESPACE}

                    echo "Services in namespace ${NAMESPACE}:"
                    kubectl get svc -n ${NAMESPACE}

                    echo "Checking application health:"
                    # Get LoadBalancer URL and test it
                    LB_URL=\$(kubectl get svc trend-app-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
                    if [ "\$LB_URL" != "pending" ]; then
                        echo "LoadBalancer URL: http://\$LB_URL"
                        # Test health check endpoint
                        curl -f -m 10 http://\$LB_URL/ || echo "Health check failed, but deployment may still be initializing"
                    else
                        echo "LoadBalancer still pending..."
                    fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Deployment successful: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
            echo "Application should be available at the LoadBalancer URL shown above"
        }
        failure {
            echo "❌ Pipeline failed!"
            script {
                // Try to get some debug info on failure
                try {
                    withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                        export KUBECONFIG=\${KUBECONFIG_FILE}
                        echo "=== Debug Info ==="
                        kubectl get pods -n ${NAMESPACE}
                        kubectl get events -n ${NAMESPACE} --sort-by=.metadata.creationTimestamp | tail -10
                        """
                    }
                } catch (Exception e) {
                    echo "Could not retrieve debug info: ${e.getMessage()}"
                }
            }
        }
        always {
            sh '''
            # Clean up Docker images and containers
            docker system prune -f || true
            # Clean up build artifacts
            rm -rf node_modules dist || true
            '''
        }
    }
}
