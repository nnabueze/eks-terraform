pipeline{
    agent{
        label "linux"
    }
    environment{
        ACTION = "apply"
    }
    stages{
        stage('Validating terraform') {
            steps {
                sh '''
                terraform init -reconfigure
                terraform validate
                terraform plan
                '''
            }
        }
        stage('Terraform Action') {
            when {
                branch 'dev'
            }
            steps {
                script{
                    if(ACTION == "apply"){
                        sh 'terraform apply --auto-approve'
                        sh(script: "terraform output eks-cluster-name > output.txt", returnStdout: true)
                        def CLUSTER_NAME = readFile(file: 'output.txt').trim()
                        echo "Name: ${CLUSTER_NAME}"
                        sh "aws eks update-kubeconfig --name ${CLUSTER_NAME}"
                        echo "Created eks cluster"

                    }else{
                        echo 'destroying cluster'
                    }
                }
            }
        }

        stage('ArgoCD Handling') {
            when {
                branch 'dev'
            }
            steps {
                script{
                    if(ACTION == "apply"){
                        sh'''

                        kubectl create namespace argo-rollouts
                        kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

                        '''
                    }else{
                        sh'''
                        kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                        kubectl delete namespace argocd
                        kubectl delete -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
                        kubectl delete namespace argo-rollouts

                        terraform destroy --auto-approve
                        '''
                    }
                }
            }
        }
    }
}