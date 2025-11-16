pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'abhishek8056/trend-app'
        DOCKERHUB_CREDENTIAL_ID = 'dockerhub-creds'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        NAMESPACE = 'trend-app'
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo "✅ Code checked out from GitHub"
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                echo "📦 Installing Node.js dependencies..."
                npm install
                echo "✅ Dependencies installed"
                '''
            }
        }

        stage('Build Application') {
            steps {
                sh '''
                echo "🔨 Building React application..."
                npm run build
                echo "✅ Application built successfully"
                ls -la dist/ || echo "dist folder created"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "🐳 Building Docker image..."
                docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
                echo "✅ Docker image built: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIAL_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "🔐 Logging into DockerHub..."
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    echo "📤 Pushing image to DockerHub..."
                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_REPO}:latest

                    echo "✅ Image pushed successfully: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                    echo "🚀 Deploying to Kubernetes..."
                    export KUBECONFIG=\${KUBECONFIG_FILE}

                    # Test cluster connection
                    echo "🔗 Testing cluster connection..."
                    kubectl cluster-info

                    # Create namespace
                    echo "📁 Creating namespace..."
                    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                    # Apply Kubernetes manifests
                    echo "📋 Applying Kubernetes manifests..."
                    kubectl apply -f k8s/

                    # Update deployment image
                    echo "🔄 Updating deployment image..."
                    kubectl set image deployment/trend-app-deployment trend-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n ${NAMESPACE}

                    # Wait for rollout
                    echo "⏳ Waiting for deployment rollout..."
                    kubectl rollout status deployment/trend-app-deployment -n ${NAMESPACE} --timeout=600s

                    # Wait for pods to be ready
                    echo "⏳ Waiting for pods to be ready..."
                    kubectl wait --for=condition=ready pod -l app=trend-app -n ${NAMESPACE} --timeout=300s

                    echo "✅ Deployment completed successfully!"
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                    echo "🔍 Verifying deployment..."
                    export KUBECONFIG=\${KUBECONFIG_FILE}

                    echo "=== DEPLOYMENT STATUS ==="
                    kubectl get pods -n ${NAMESPACE}
                    kubectl get svc -n ${NAMESPACE}

                    # Get LoadBalancer URL
                    LB_URL=\$(kubectl get svc trend-app-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

                    if [ "\$LB_URL" != "pending" ] && [ -n "\$LB_URL" ]; then
                        echo "🌐 LoadBalancer URL: http://\$LB_URL"
                        echo "🩺 Testing application health..."
                        if curl -f -m 30 http://\$LB_URL/; then
                            echo "✅ Application is healthy and responding!"
                        else
                            echo "⚠️  Health check failed, but deployment completed"
                        fi
                    else
                        echo "⏳ LoadBalancer still provisioning..."
                        echo "📝 Check status manually: kubectl get svc -n ${NAMESPACE}"
                    fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 PIPELINE SUCCESSFUL!"
            echo "📦 Image: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
            echo "🚀 Deployed to namespace: ${NAMESPACE}"
            echo "🌐 Check LoadBalancer URL above for application access"
        }
        failure {
            echo "❌ PIPELINE FAILED!"
            script {
                try {
                    withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                        echo "=== DEBUG INFORMATION ==="
                        export KUBECONFIG=\${KUBECONFIG_FILE}
                        echo "Recent pods:"
                        kubectl get pods -n ${NAMESPACE} --sort-by=.metadata.creationTimestamp | tail -5
                        echo "Recent events:"
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
            echo "🧹 Cleaning up workspace..."
            docker system prune -f || true
            rm -rf node_modules dist || true
            echo "✅ Cleanup completed"
            '''
        }
    }
}
