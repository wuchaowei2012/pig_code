pipeline {
  agent any
  stages {
    stage('检出') {
      steps {
        sh 'echo ${DOCKER_IMAGE_CONFIG_NAME}'
        checkout([$class: 'GitSCM', branches: [[name: env.GIT_BUILD_REF]],
        userRemoteConfigs: [[url: env.GIT_REPO_URL, credentialsId: env.CREDENTIALS_ID]]])
      }
    }
    stage('编译') {
      steps {
        sh 'mvn compile'
        echo '编译完成'
      }
    }
    stage('单元测试') {
      parallel {
        stage('并行进行 gateway 单元测试') {
          post {
            always {
              junit '**/target/surefire-reports/*.xml'
              echo '测试报告收集完成'

            }

          }
          steps {
            echo '开始单元测试................................................'
            sh 'cd ./gateway; mvn test'
            echo '单元测试完成'
          }
        }
        stage('并行进行 turbine-stream-service 单元测试') {
          post {
            always {
              junit '**/target/surefire-reports/*.xml'
              echo '测试报告收集完成'

            }

          }
          steps {
            echo '开始单元测试................................................'
            sh 'cd ./turbine-stream-service; mvn test'
            echo '单元测试完成'
          }
        }
      }
    }
    stage('打包成Fatjar') {
      steps {
        echo '执行应用打包成Fatjar'
        sh 'mvn clean package -DskipTests'
        echo '打包完成'
      }
    }
    stage('并行完镜像打包以及推送') {
      parallel {
        stage('构建并推送config镜像') {
          steps {
            sh "echo ${env.CODING_DOCKER_REG_HOST}"
            sh "cd ./config;docker build -t ${env.DOCKER_IMAGE_CONFIG_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_CONFIG_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送registry镜像') {
          steps {
            sh "cd ./registry;docker build -t ${env.DOCKER_IMAGE_REGISTRY_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_REGISTRY_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送account镜像') {
          steps {
            sh "cd ./account-service;docker build -t ${env.DOCKER_IMAGE_ACCOUNT_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_ACCOUNT_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送auth镜像') {
          steps {
            sh "cd ./auth-service;docker build -t ${env.DOCKER_IMAGE_AUTH_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_AUTH_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送gateway镜像') {
          steps {
            sh "cd ./gateway;docker build -t ${env.DOCKER_IMAGE_GATEWAY_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_GATEWAY_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送NOTIFICATION_NAME镜像') {
          steps {
            sh "cd ./notification-service;docker build -t ${env.DOCKER_IMAGE_NOTIFICATION_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_NOTIFICATION_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送 statistics镜像') {
          steps {
            sh "cd ./statistics-service;docker build -t ${env.DOCKER_IMAGE_STATIC_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_STATIC_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送 monitoring 镜像') {
          steps {
            sh "cd ./monitoring;docker build -t ${env.DOCKER_IMAGE_MONITOR_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_MONITOR_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
        stage('构建并推送 trubine 镜像') {
          steps {
            sh "cd ./turbine-stream-service;docker build -t ${env.DOCKER_IMAGE_TUIBINE_NAME}:${env.DOCKER_IMAGE_VERSION}  ."
            script {
              docker.withRegistry("https://${env.CODING_DOCKER_REG_HOST}", "${env.CODING_ARTIFACTS_CREDENTIALS_ID}") {
                docker.image("${env.DOCKER_IMAGE_TUIBINE_NAME}:${env.DOCKER_IMAGE_VERSION}").push()
              }
            }

          }
        }
      }
    }
    stage('部署') {
      steps {
        pwd()
        script {
          def remoteConfig = [:]
          remoteConfig.name = "my-remote-server"
          remoteConfig.host = "${env.REMOTE_HOST}"
          remoteConfig.allowAnyHosts = true

          withCredentials([usernamePassword(
            credentialsId: "${env.REMOTE_CRED}",
            passwordVariable: 'password',
            usernameVariable: 'userName'
          )]
        ) {
          // SSH 登陆用户名
          remoteConfig.user = userName
          // SSH 登陆密码
          remoteConfig.password = password

          //远程执行脚本，初始化环境
          sshScript (remote: remoteConfig, script: 'env-init.sh')

          //上传脚本docker-compose文件到远程目录
          sshPut (
            remote: remoteConfig,
            from: './docker-compose.yml',
            into: './docker-compose.yml'
          )
          //上传env文件远程目录
          sshPut (
            remote: remoteConfig,
            from: './.env',
            into: './.env'
          )

          //远程安装并启动程序
          sshCommand (
            remote: remoteConfig,
            command: 'docker-compose down;docker rmi $(docker images -q); docker-compose up -d',
            sudo: true,
          )

          echo "部署成功，请稍等几分钟后查看，请到 http://${env.REMOTE_HOST} 预览效果"
          echo "注册中访问地址： http://${env.REMOTE_HOST}:8761 预览效果"


        }
      }

    }
  }
}
environment {
  CODING_DOCKER_REG_HOST = "${env.CCI_CURRENT_TEAM}-docker.pkg.${env.CCI_CURRENT_DOMAIN}"
  DOCKER_IMAGE_VERSION = 'latest'
  DOCKER_IMAGE_CONFIG_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/config"
  DOCKER_IMAGE_REGISTRY_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/registry"
  DOCKER_IMAGE_ACCOUNT_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/account-service"
  DOCKER_IMAGE_AUTH_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/auth-service"
  DOCKER_IMAGE_GATEWAY_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/gateway"
  DOCKER_IMAGE_NOTIFICATION_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/notification-service"
  DOCKER_IMAGE_STATIC_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/statistics-service"
  DOCKER_IMAGE_MONITOR_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/monitoring"
  DOCKER_IMAGE_TUIBINE_NAME = "${env.PROJECT_NAME.toLowerCase()}/${env.DOCKER_REPO_NAME}/turbine-stream-service"
}
}