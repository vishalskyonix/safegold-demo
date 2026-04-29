pipeline {
    agent any

    environment {
        RG   = 'uat-uae-rg'
        VMSS = 'demo-1-vmss'
    }

    stages {

        stage('Verify Repo') {
            steps {
                echo "Verifying GitHub repo is reachable..."
                sh 'git ls-remote https://github.com/vishalskyonix/safegold-demo.git HEAD'
            }
        }

        stage('Deploy to VMSS') {
            steps {
                sh '''
                    # No login credentials needed — VM identity handles it
                    az login --identity

                    echo "Triggering deploy.sh on all VMSS instances..."

                    az vmss run-command invoke \
                      --resource-group ${RG} \
                      --name ${VMSS} \
                      --command-id RunShellScript \
                      --scripts "bash /opt/deploy/deploy.sh" \
                      --instance-id "*"
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 15
                    echo "VMSS instance states:"
                    az vmss list-instances \
                      --resource-group ${RG} \
                      --name ${VMSS} \
                      --query "[].{Instance:name, State:provisioningState}" \
                      --output table
                '''
            }
        }
    }

    post {
        success {
            echo "Build #${BUILD_NUMBER} deployed successfully to all VMSS instances."
        }
        failure {
            echo "Build #${BUILD_NUMBER} failed. SSH into an instance and run: sudo bash /opt/deploy/deploy.sh"
        }
    }
}
