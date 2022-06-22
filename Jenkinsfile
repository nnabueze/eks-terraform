pipeline{
    agent{
        label "linux"
    }
    environment{
        CLUSTER_NAME = ""
        ACTION = "apply"
    }
    stages{
        stage('Validating terraform') {
            steps {
                sh '''
                terraform init
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
                        sh 'terraform init -reconfigure'
                        sh 'terraform apply --auto-approve'
                        CLUSTER_NAME = sh(returnStdout: true, script: "terraform output eks-cluster-name").trim()

                    }else{
                        echo 'destroying cluster'
                    }
                }
            }
        }
        stage('Configure KubeCTL'){
            when {
                branch 'dev'
            }
            steps {
                script{
                    if(ACTION == "apply"){
                        sh'aws eks update-kubeconfig --name ${CLUSTER_NAME}'
                        echo "Created eks cluster"
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
                        kubectl create namespace argocd
                        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                        '''
                    }else{
                        sh'''
                        kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                        kubectl delete namespace argocd
                        terraform destroy --auto-approve
                        '''
                    }
                }
            }
        }
    }
}