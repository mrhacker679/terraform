resource "local_file" "myfile" {
  filename = var.filename
  content = var.content
}

variable "filename" {
  default = "myfile.txt"
}

variable "content" {
  default = "THIS IS THE MODULE"
}
