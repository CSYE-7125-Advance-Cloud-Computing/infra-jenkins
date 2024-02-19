pipelineJob('webapp_docker_build') {
    description('webapp docker and semantic release job')
  
    logRotator {
      daysToKeep(30)
      numToKeep(20)
    }
      definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/webapp')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }
    triggers {
        githubPush()
    } 
}

pipelineJob('webapp_db_docker_build') {
    description('webapp_db repo docker build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/webapp-db')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('helm_chart_semantic_release') {
    description('Helm chart semantic release build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/webapp-helm-chart')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('kafka_producer') {
    description('Kafka producer build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/Perform-Health-Check')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('kafka_consumer') {
    description('Kafka consumer build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/Process-Health-Check')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}

pipelineJob('kube_operator') {
    description('Kube operator build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/health-check-operator')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}


pipelineJob('kafka_helm_chart') {
    description('Kafka helm chart build job')

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }
    
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/CSYE-7125-Advance-Cloud-Computing/kafka-helm-chart')
                    }
                    branches('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }

    triggers {
        githubPush()
    }
}