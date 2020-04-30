data "aws_ami" "amazon_linux2_latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_instance" "daylight" {
  filter {
    name   = "tag:Name"
    values = ["daylight"]
  }

  depends_on = [aws_spot_fleet_request.daylight_instance]
}

resource "aws_spot_fleet_request" "daylight_instance" {
  iam_fleet_role                      = aws_iam_role.spot_fleet.arn
  target_capacity                     = 1
  wait_for_fulfillment               = true
  terminate_instances_with_expiration = true

  dynamic "launch_specification" {
    for_each = aws_subnet.daylight_public.*.id
    content {
      ami                         = data.aws_ami.amazon_linux2_latest.id
      instance_type               = "t2.nano"
      vpc_security_group_ids      = [aws_security_group.daylight.id]
      subnet_id                   = launch_specification.value
      associate_public_ip_address = true

      root_block_device {
        volume_size = 30
        volume_type = "gp2"
      }

      tags = {
        Name = "daylight"
      }
    }
  }
}
