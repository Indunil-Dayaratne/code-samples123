locals {
    region = substr(replace(var.Location," ",""),0,3)
}
