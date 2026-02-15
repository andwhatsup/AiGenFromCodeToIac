locals {
  lambda_dummy_zip = "${path.module}/.dummy/lambda.zip"
}

data "archive_file" "lambda_dummy" {
  type        = "zip"
  output_path = local.lambda_dummy_zip

  source {
    filename = "index.js"
    content  = <<-EOF
      exports.handler = async (event) => {
        console.log("Dummy lambda invoked");
        return { statusCode: 200, body: "dummy" };
      };
    EOF
  }
}
