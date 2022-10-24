def BRANCH
def VERSION

pipeline {

    agent {
        kubernetes {
            label 'build-service-pod'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: build-service
spec:
  containers:
  - name: docker
    image: docker:18.09.2
    command: ["cat"]
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: kubectl
    image: quay.io/roboll/helmfile:v0.144.0
    command: ["cat"]
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    options {
        skipDefaultCheckout true
    }

    // environment {
    //     VERSION = ''
    // }

    stages {
        stage ('Checkout') {
            steps {
                script {
                    def repo = checkout scm
                    VERSION = sh(script: 'git log -1 --format=\'%h.%ad\' --date=format:%Y%m%d-%H%M | cat', returnStdout: true).trim()
                    BRANCH = repo.GIT_BRANCH.take(20).replaceAll('/', '_')
                    if (BRANCH != 'master') {
                        VERSION += "-${branch}"
                    }
                    sh "echo 'Building revision: ${VERSION}'"
                }
            }
        }
        stage ('Build') {
            steps {
                container('docker') {
                    script {
                        sh "docker build . -t daryamorgen/demo:${VERSION}"
                    }
                }
            }
        }
        stage ('Publish') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKER_REGISTRY_PASSWORD', usernameVariable: 'DOCKER_REGISTRY_USER')]) {
                        sh "docker login -u ${DOCKER_REGISTRY_USER} -p ${DOCKER_REGISTRY_PASSWORD}"
                        sh "docker push daryamorgen/demo:${VERSION}"
                    }
                }
            }
        }
        stage ('Deploy') {
            steps {
                container('kubectl') {
                    script {
                        sh "helmfile sync --set image.tag=${VERSION}"
                    }
                }
            }
        }   
    }
}
