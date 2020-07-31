# sk_mid_project

[사전 환경 설정]
- IAM 보안자격 증명 탭에서 Access Key 생성
$ export AWS_ACCESS_KEY_ID= [키 ID 입력]
$ export AWS_SECRET_ACCESS_KEY= [키 값 입력]

- terraform.io 에 접속하여 Linux 64-bit 다운로드 링크 복사 및 PATH 설정
$ wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
$ export PATH=$PATH:~/environment/

- 인스턴스 접속을 위한 공개키 생성
$ cd ~/.ssh
$ ssh-keygen
- 엔터 3번하여 key 생성

[적용 절차]

1. accepter

$ cd ~/environment/sk_mid_project/accepter
$ terraform init
$ terraform plan
$ terraform apply --auto-approve

실행하면 진행 중 아래 에러 발생(정상임)
============================================================================================================================================================
module.vpc.data.aws_availability_zones.available: Refreshing state...
aws_key_pair.public_key: Creating...
... 중략 ...
module.alb_auto_scaling.aws_autoscaling_policy.scaling_policy[0]: Creation complete after 1s [id=skuser04a-tracking-policy-80]

Error: Error creating route: InvalidParameterValue: route table rtb-0749ab966c4c93c0c and network gateway pcx-04e232c116185fa60 belong to different networks
        status code: 400, request id: ac5b1558-35b6-483f-a5d1-ddc6871ee794

  on modules/vpc/main.tf line 49, in resource "aws_route_table" "frontend":
  49: resource "aws_route_table" "frontend" {
============================================================================================================================================================
에러 확인 후, 2번 수행

2. requester

$ cd ~/environment/sk_mid_project/requester
$ terraform init
$ terraform plan
$ terraform apply --auto-approve

실행하여 아래 내용 확인
============================================================================================================================================================
module.vpc_peering_requester.data.aws_vpc.peer: Refreshing state...
module.vpc_peering_requester.data.aws_caller_identity.peer: Refreshing state...
...중략...
Apply complete! Resources: 26 added, 0 changed, 0 destroyed.

Outputs:

alb_domain_names = {
  "skuser04r-alb-80" = [
    "skuser04r-alb-80-939633542.us-west-1.elb.amazonaws.com",
  ]
}
peering_id = pcx-0c26b121458534238
============================================================================================================================================================

위 peering_id의 값을 accepter에 설정 값으로 입력
accepter의 main.tf 내 peering_id에 "pcx-0c26b121458534238" 입력(pcx-xxxxxxxxxx 값은 바뀔 수 있음)
============================================================================================================================================================
locals {
  peering_id = "pcx-0c26b121458534238"        # for vpc-peering accepter # 두번째
}
============================================================================================================================================================

3. accepter
초기에 생성된 accepter 인스턴스는 httpd 설치가 안되면 생성된 인스턴스 종료 (종료하면 Autoscaling으로 자동 생성됨)
AWS Management Console로 이동
EC2 -> 인스턴스 -> accepter 인스턴스 모두 선택 -> 작업 버튼 -> 인스턴스 상태 -> 종료

$ cd ~/environment/sk_mid_project/accepter
$ terraform plan
$ terraform apply --auto-approve

4. Peering 수행
AWS Management Console로 이동
VPC -> 피어링 연결 -> 수락대기 상태의 피어링 선택 -> 작업 버튼 -> 요청 수락 -> 상태 "활성" 확인

5. 테스트
- 3번에서 종료한 accepter 인스턴스는 잠시 기다리면 자동 생성

[문제점 및 개선 방향]
- VPC Peering 수동으로 설정해야 하므로 Peering 자동화
- accepter 최초 인스턴스는 서비스가 안되는 경우가 있으므로 최초 인스턴스 종료 안하고 바로 서비스 가능하게 하기
- peering id 자동 설정(과연 가능 할지...)