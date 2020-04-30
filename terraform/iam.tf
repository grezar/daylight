resource "aws_iam_role" "spot_fleet" {
  name               = "spot_fleet"
  assume_role_policy = data.aws_iam_policy_document.spot_fleet_assume_role.json
}

data "aws_iam_policy_document" "spot_fleet_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}
