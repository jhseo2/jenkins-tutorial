REGION = 'ap-northeast-2'
EKS_API = 'https://3C6DF10E20DE0C5DCB6321846473AD40.sk1.ap-northeast-2.eks.amazonaws.com'
EKS_CLUSTER_NAME='Jenkins-EKS-Cluster'
EKS_NAMESPACE='default'
EKS_JENKINS_CREDENTIAL_ID='jenkins-aws-credentials'
ECR_PATH = '159611220708.dkr.ecr.ap-northeast-2.amazonaws.com'
ECR_IMAGE = 'jenkins-test'
AWS_CREDENTIAL_ID = 'jenkins-aws-credentials'


node {
    stage('Clone Repository'){
        checkout scm
    }
    stage('Docker Build'){
        // Docker Build
        docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
            image = docker.build("${ECR_PATH}/${ECR_IMAGE}", "--network=host --no-cache .")
        }
    }
    stage('Push to ECR'){
        docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
            image.push("v${env.BUILD_NUMBER}")
        }
    }
    stage('CleanUp Images'){
        sh"""
        docker rmi ${ECR_PATH}/${ECR_IMAGE}:v$BUILD_NUMBER
        docker rmi ${ECR_PATH}/${ECR_IMAGE}:latest
        """
    }
    stage('Deploy to K8S'){
        withKubeConfig([credentialsId: "kubectl-deploy-credentials",
                        serverUrl: "${EKS_API}",
                        clusterName: "${EKS_CLUSTER_NAME}"]){
            sh "sed 's/IMAGE_VERSION/${env.BUILD_ID}/g' service.yaml > output.yaml"
            sh "aws eks --region ${REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}"
            sh "kubectl apply -f output.yaml"
            sh "rm output.yaml"
        }
    }
}
