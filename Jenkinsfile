throttle(['Lock']) {
    node {
        try {
            stage ('Scm checkout') {
                git branch: 'backImage', url: 'https://github.com/Nazar802/demo3.git'
            }
            
            withSonarQubeEnv ('SonarQube') {
                stage ('Mvn Package') {
                    def mvnHome = tool name: 'Maven', type: 'maven'
                    def mvnCMD = "${mvnHome}/bin/mvn"
                    sh "${mvnCMD} clean package sonar:sonar"
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
            
            stage ('Upload To Nexus') {
                def mavenPom = readMavenPom file: 'pom.xml'
                nexusArtifactUploader artifacts: [
                        [artifactId: 'TeachUA', 
                        classifier: '', 
                        file: "target/dev.war", 
                        type: 'war'
                        ]
                    ], 
                    credentialsId: 'nexus', 
                    groupId: 'com.softserve.teachua', 
                    nexusUrl: '${NEXUS_SERVER}', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'backend/', 
                    version: "${mavenPom.version}"
            }
            
            stage ('Docker Build') {
                def dockerHome = tool name: 'Docker', type: 'dockerTool'
                def dockerCMD = "${dockerHome}/bin/docker"
                sh "${dockerCMD} build . -t ${ACR_ADDR}/backend:latest"
            }
                
            stage ('Docker Push') {
                def dockerHome = tool name: 'Docker', type: 'dockerTool'
                def dockerCMD = "${dockerHome}/bin/docker"
                sh "${dockerCMD} login ${ACR_ADDR} -u${ACR_UID} -p${ACR_PASS}"
                sh "${dockerCMD} push ${ACR_ADDR}/backend:latest"
            }
            
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=' Back Image job succeeded'
                """)
            }
        }
        catch (e) {
            withCredentials([string(credentialsId: 'chatID', variable: 'notif')]) {
                sh  ("""
                curl -s -X POST https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d parse_mode=markdown -d text=" Back Image job failed"
                """)
            }
            throw e
        }
    }
}
