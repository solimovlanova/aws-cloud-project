resource "aws_dynamodb_table" "restaurant" {
  name           = "Restaurant"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "ServiceName"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "ServiceName"
    type = "S"
  }

  attribute {
    name = "Date"
    type = "S"
  }

  global_secondary_index {
    name               = "ServiceIndex"
    hash_key           = "ServiceName"
    range_key          = "Date"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId", "ClientId", "ServiceType", "Service"]
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "dynamodb-table-restaurant"
    Environment = "production"
  }
}


resource "aws_dynamodb_table_item" "client1" {
  table_name = aws_dynamodb_table.restaurant.name
  hash_key   = "UserId"
  range_key  = "ServiceName"

  item = <<ITEM
{
  "UserId":       {"S": "client_001"},
  "ServiceName":  {"S": "DinnerReservation"},
  "ClientId":     {"S": "resto_567"},
  "ServiceType":  {"S": "Dine-In"},
  "Service":      {"S": "3-Course Meal"},
  "Date":         {"S": "2025-07-27"},
  "TimeToExist":  {"N": "1725100800"}
}
ITEM
}
