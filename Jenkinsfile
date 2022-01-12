throttle(['Lock']) {
    node {
        try {
            def remote = [:]
            
            withCredentials([sshUserPrivateKey(credentialsId: 'ssh', keyFileVariable: 'file', passphraseVariable: 'pass', usernameVariable: 'user')]) {
                remote.identityFile = file
                remote.name = 'frontend'
                remote.host = "${VMIP}"
                remote.user = 'azureuser'
                remote.allowAnyHosts = true    
                
                stage ('Cleanup') {
                    writeFile file: 'cleanup.sh', text:
                    "rm -rf teachfront\nkubectl delete deploy frontend-deployment || true\nkubectl delete svc frontend-service || true"
                    sshScript remote: remote, script: "cleanup.sh"
                }
                
                stage ('Scm checkout') {
                    git branch: 'frontend', url: 'https://github.com/Nazar802/demo3.git'
                    sshCommand remote: remote, command: "git clone --branch frontend https://github.com/Nazar802/demo3.git teachfront"
                }
                
                stage ('Kubectl apply') {
                    writeFile file: 'start.sh', text:
                    "kubectl apply -f ~/teachfront/front.yaml"
                    sshScript remote: remote, script: "start.sh"
                }
                
            }
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=' Frontend job succeeded'
                """)
            }
        }
        catch (e) {
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Frontend job failed"
                """)
            }
            throw e
        }
    }
}
