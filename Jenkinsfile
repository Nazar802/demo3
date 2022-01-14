throttle(['Lock']) {
    node {
        try {
            def remote = [:]
            
            withCredentials([sshUserPrivateKey(credentialsId: 'ssh', keyFileVariable: 'file', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                remote.identityFile = file
                remote.name = 'terraform'
                remote.host = "${VMIP}"
                remote.user = 'azureuser'
                remote.allowAnyHosts = true    
                
                /*stage ('Terraform destroy') {
                    writeFile file: 'cleanup.sh', text:
                    "cd ~/cluster\nterraform destroy -auto-approve\n cd ..\nrm -rf cluster"
                    sshScript remote: remote, script: "cleanup.sh"
                }
                
                stage ('Scm checkout') {
                    git branch: 'terraformk8s', url: 'https://github.com/Nazar802/demo3.git'
                    sshCommand remote: remote, command: "git clone --branch terraformk8s https://github.com/Nazar802/demo3.git cluster"
                }
                
                stage ('Terraform apply') {
                    writeFile file: 'start.sh', text:
                    "cd ~/cluster\nterraform init\nterraform apply -auto-approve"
                    sshScript remote: remote, script: "start.sh"
                }
                
                stage ('Connect to cluster') {
                    writeFile file: 'connect.sh', text:
                    "az account set --subscription ${SUBSCRIPTION_ID}\naz aks get-credentials --resource-group azure-k8stest --name k8stest --overwrite-existing"
                    sshScript remote: remote, script: "connect.sh"
                }*/
                
                stage ('Connect to ACR') {
                    writeFile file: 'connect.sh', text:
                    "docker login ${ACR_ADDR} -u${ACR_UID} -p${ACR_PASS}\ncat ~/.docker/config.json\nkubectl create secret generic regcred --from-file=.dockerconfigjson=/home/azureuser/.docker/config.json --type=kubernetes.io/dockerconfigjson"
                    sshScript remote: remote, script: "connect.sh"
                }
                
            }
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=' Kubernetes job succeeded'
                """)
            }
        }
        catch (e) {
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Kubernetes job failed"
                """)
            }
            throw e
        }
    }
}
