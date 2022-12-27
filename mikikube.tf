resource "aws_instance" "minikube" {
  ami = "ami-0a6b2839d44d781b2"
  instance_type = "t2.medium"
  region = "us-east-1"
  key_name = "servers"
  user_data = file("minikube.sh")
  
  tags = {
    Name = "Mikikube"
  }
}
