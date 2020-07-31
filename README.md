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


[문제점 및 개선 방향]
- VPC Peering 수동으로 활성화해야 하므로 Peering 자동 활성화 필요
- 모든 resourse에 vpc.peer 설정해야 한다고 함