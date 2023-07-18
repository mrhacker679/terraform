resource "local_file" "testtf" {
  filename  = "test.tf"
  content = "This is not created from main.tf instead it is vreated from test.tf"
  }
