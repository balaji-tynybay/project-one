locals {
  common_tags = {
    company = var.company
    project = "${var.company}- project"
  }
}
