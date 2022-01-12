throttle(['Lock']) {
    node {
        try {
            def remote = [:]
            
            withCredentials([sshUserPrivateKey(credentialsId: 'ssh', keyFileVariable: 'file', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                remote.identityFile = file
                remote.name = 'ingress'
                remote.host = "${VMIP}"
                remote.user = 'azureuser'
                remote.allowAnyHosts = true    
                
                stage ('Cleanup') {
                    writeFile file: 'cleanup.sh', text:
                    "rm -rf ingress\nkubectl delete ing teachua-ingress || true"
                    sshScript remote: remote, script: "cleanup.sh"
                }
        
                stage ('Scm checkout') {
                    git branch: 'ingress', url: 'https://github.com/Nazar802/demo3.git'
                    sshCommand remote: remote, command: "cd ~ && git clone --branch ingress https://github.com/Nazar802/demo3.git ingress"
                }
                
                stage ('Kubectl apply') {
                    writeFile file: 'start.sh', text:
                    "kubectl apply -f ~/ingress/ingress.yaml"
                    sshScript remote: remote, script: "start.sh"
                }
            }
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Ingress job succeeded. Infrastructure is deployed.\nGo to http://teachua.centralus.cloudapp.azure.com/"
                """)
            }
        }
        catch (e) {
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Ingress job failed"
                """)
            }
            throw e
        }
    }
}
