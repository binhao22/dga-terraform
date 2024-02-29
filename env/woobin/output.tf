# 다른 워크스페이스에서 사용 가능하도록 output
output "dga-vpc-id" {
  value = module.dga-vpc.dga-vpc-id
}
output "dga-pub-1-id" {
  value = module.dga-vpc.dga-pub-1-id
}
output "dga-pub-2-id" {
  value = module.dga-vpc.dga-pub-2-id
}
output "dga-pri-1-id" {
  value = module.dga-vpc.dga-pri-1-id
}
output "dga-pri-2-id" {
  value = module.dga-vpc.dga-pri-2-id
}
output "dga-pub-sg-id" {
  value = module.dga-sg.dga-pub-sg-id
}
output "dga-pri-sg-id" {
  value = module.dga-sg.dga-pri-sg-id
}
output "dga-pri-db-sg-id" {
  value = module.dga-sg.dga-pri-db-sg-id
}