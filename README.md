# sk_mid_project

[사전 환경 설정]
- IAM 보안자격 증명 탭에서 Access Key 생성
$ export AWS_ACCESS_KEY_ID= [키 ID 입력]
$ export AWS_SECRET_ACCESS_KEY= [키 값 입력]

- terraform.io 에 접속하여 Linux 64-bit 다운로드 링크 복사 및 PATH 설정
$ wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
$ unzip terraform_0.12.29_linux_amd64.zip 
$ export PATH=$PATH:~/environment/

- 인스턴스 접속을 위한 공개키 생성
$ cd ~/.ssh
$ ssh-keygen
- 엔터 3번하여 key 생성

[적용 절차]

$ cd ~/environment/sk_mid_project
$ terraform init
$ terraform plan
$ terraform apply --auto-approve

[테스트]
- Windows Powershell Script
for($i=0;$i -lt 3600;$i++){wget user55r-alb-80-1168350943.us-west-1.elb.amazonaws.com;start-sleep -Seconds 1}


[문제점]
