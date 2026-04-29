pipeline {
    agent any

    environment {
        RG   = 'uat-uae-rg'
        VMSS = 'demo-1-vmss'
        REPO = 'https://github.com/vishalskyonix/safegold-demo.git'
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
                    az login --identity

                    echo "Fetching all VMSS instance IDs..."
                    INSTANCE_IDS=$(az vmss list-instances \
                      --resource-group ${RG} \
                      --name ${VMSS} \
                      --query "[].instanceId" \
                      --output tsv)

                    echo "Instances found: $INSTANCE_IDS"

                    for ID in $INSTANCE_IDS; do
                        echo "Deploying to instance $ID ..."
                        az vmss run-command invoke \
                          --resource-group ${RG} \
                          --name ${VMSS} \
                          --command-id RunShellScript \
                          --scripts "
                            cd /tmp
                            rm -rf safegold-demo
                            git clone https://github.com/vishalskyonix/safegold-demo.git
                            chmod +x /tmp/safegold-demo/deploy.sh
                            bash /tmp/safegold-demo/deploy.sh
                          " \
                          --instance-id $ID
                        echo "Instance $ID done."
                    done
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
            echo "Build #${BUILD_NUMBER} failed."
        }
    }
}
