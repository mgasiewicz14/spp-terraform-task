terraform {
  backend "s3" {
    bucket         = "terraform-bucket-spp" 
    key            = "global/spp_app/terraform.tfstate"    
    region         = "us-east-1"                           
    dynamodb_table = "terraform-table-spp"           
    encrypt        = true
  }
}