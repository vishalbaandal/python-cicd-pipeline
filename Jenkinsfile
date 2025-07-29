pipeline {
  agent any

  environment {
    AWS_REGION       = 'ap-south-1'
    AWS_ACCOUNT_ID   = '533267002821'
    ECR_REPOSITORY   = 'python-app-ecr'
    IMAGE_TAG        = "${GIT_COMMIT}"
    CONTAINER_NAME   = 'python-app-ecr-api'
    ECR_REGISTRY     = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    FULL_IMAGE_NAME  = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
    EC2_USER         = 'ubuntu'
    EC2_HOST         = '15.206.127.90' 
  }

  options {
    timestamps()
    skipStagesAfterUnstable()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Docker Build & Tag') {
      steps {
        sh '''
          echo "[INFO] Logging into ECR..."
          aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

          echo "[INFO] Building Docker image..."
          docker build -t "$ECR_REPOSITORY:$IMAGE_TAG" .

          echo "[INFO] Tagging Docker image..."
          docker tag "$ECR_REPOSITORY:$IMAGE_TAG" "$FULL_IMAGE_NAME"
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          echo "[INFO] Pushing image to ECR..."
          docker push "$FULL_IMAGE_NAME"
        '''
      }
    }

    stage('Deploy to EC2') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {
          sh '''
            echo "[INFO] Executing remote deployment script on EC2..."

            ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST 'bash -s' < ./deploy.sh
          '''
        }
      }
    }
  }

  post {
    success {
      echo "[SUCCESS] Deployment succeeded."
    }

    failure {
      echo "[FAILURE] Deployment failed. Sending email alert..."
      mail to: 'vishalbandal07@gmail.com',
           subject: "❌ Jenkins Job Failed: ${env.JOB_NAME} [#${env.BUILD_NUMBER}]",
           body: "Build failed. View logs at: ${env.BUILD_URL}"
    }

    cleanup {
      echo "[INFO] Cleaning up dangling Docker images..."
      sh "docker image prune -f"
    }
  }
}
