pipeline {
  agent any

  stages {
    stage('Terraform Apply') {
      steps {
        script {
        
          withCredentials([usernamePassword(
            credentialsId: 'jenkins-coviam-aws-access-key',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY',
            usernameVariable: 'AWS_ACCESS_KEY_ID')]
          ) {
            docker.image('hashicorp/terraform:0.12.3').inside("--entrypoint=''") {
              
              def workspace = 'feature-branch-testing'
              if (BRANCH_NAME == 'master') {
                workspace = 'production'
              }
              if (BRANCH_NAME == 'qa') {
                workspace = 'qa'
              }

              sh "terraform init -input=false"
              sh "terraform workspace new ${workspace} || terraform workspace select ${workspace}"
              sh "terraform apply -input=false -auto-approve"
            }
          }
        }
      }
    }
  }

}

