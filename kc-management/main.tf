locals {
  # define the path to the source of the Helm charts values for the stage
  environment_data_path = "${path.module}/../environments/stage-${var.stage_name}/${var.target_namespace}"
}