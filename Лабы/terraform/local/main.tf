provider "local" {
  version = "~> 2.2.3"
}
resource "local_file" "hello" {
  content = "Hello, Terraform"
  filename = "hello.txt"
}