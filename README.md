# sk_mid_project

[생성 순서]

1. accepter

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

$ terraform plan
$ terraform apply --auto-approve

4. Peering 수행
AWS Management Console로 이동
VPC -> 피어링 연결 -> 수락대기 상태의 피어링 선택 -> 작업 버튼 -> 요청 수락 -> 상태 "활성" 확인

5. 테스트