module "table_design" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "design"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]

 
}



