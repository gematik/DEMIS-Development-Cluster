locals {
  stage = var.cluster == "local" ? "local" : "${var.cluster}-${var.region}"
}