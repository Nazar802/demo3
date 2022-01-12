throttle(['Lock']) {
    node {
        try {
            def remote = [:]
            
            withCredentials([sshUserPrivateKey(credentialsId: 'ssh', keyFileVariable: 'file', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                remote.identityFile = file
                remote.name = 'backend'
                remote.host = "${VMIP}"
                remote.user = 'azureuser'
                remote.allowAnyHosts = true    
                
                stage ('Cleanup') {
                    writeFile file: 'cleanup.sh', text:
                    "rm -rf teachback\nkubectl delete deploy backend-deployment || true\nkubectl delete svc teachua || true"
                    sshScript remote: remote, script: "cleanup.sh"
                }
        
                stage ('Scm checkout') {
                    git branch: 'backend', url: 'https://github.com/Nazar802/demo3.git'
                    sshCommand remote: remote, command: "cd ~ && git clone --branch backend https://github.com/Nazar802/demo3.git teachback"
                }
                
                stage ('Kubectl apply') {
                    writeFile file: 'start.sh', text:
                    "kubectl apply -f ~/backend/back-secret.yaml\nkubectl apply -f ~/teachback/back.yaml"
                    sshScript remote: remote, script: "start.sh"
                }
                
            }
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=' Backend job succeeded'
                """)
            }
        }
        catch (e) {
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Backend job failed"
                """)
            }
            throw e
        }
    }
}
