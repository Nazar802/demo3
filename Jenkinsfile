throttle(['Lock']) {
    node {
        env.NODEJS_HOME = "${tool 'NodeJS'}"
        env.PATH="${NODEJS_HOME}/bin:${env.PATH}"
        try {
            def remote = [:]
            
            stage ('Scm checkout') {
                git branch: 'frontImage', url: 'https://github.com/Nazar802/demo3.git'
            }
            
            stage ('Npm install') {
                sh "npm install"
            }
            
            stage ('Npm build') {
                sh "npm run build"
            }
            
            withSonarQubeEnv ('SonarQube') {
                stage ('Sonar Scan') {
                    def sonarScanner = tool name: 'SonarQube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    def sonarCMD = "${sonarScanner}/bin/sonar-scanner"
                    sh "${sonarCMD} -Dsonar.projectKey=frontend -Dsonar.sources=. -Dsonar.projectName=frontend"
                }
            }
            
            stage("Quality Gate"){
                timeout(time: 1, unit: 'HOURS') {
                    def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            sh  ("""
                            curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=' Rewrite the code. Quality gate for backend failed'
                            """)
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                }
            } 
            
            stage ('Docker Build') {
                def dockerHome = tool name: 'Docker', type: 'dockerTool'
                def dockerCMD = "${dockerHome}/bin/docker"
                sh "${dockerCMD} build . -t ${ACR_ADDR}/frontend:latest"
            }
                
            stage ('Docker Push') {
                def dockerHome = tool name: 'Docker', type: 'dockerTool'
                def dockerCMD = "${dockerHome}/bin/docker"
                sh "${dockerCMD} login ${ACR_ADDR} -u${ACR_UID} -p${ACR_PASS}"
                sh "${dockerCMD} push ${ACR_ADDR}/frontend:latest"
            }
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=' Front Image job succeeded'
                """)
            }
        }
        catch (e) {
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Front Image job failed"
                """)
            }
            throw e
        }
    }
}
