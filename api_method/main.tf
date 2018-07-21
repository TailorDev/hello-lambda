variable "rest_api_id" {
  description = "The ID of the associated REST API"
}

variable "resource_id" {
  description = "The API resource ID"
}

variable "method" {
  description = "The HTTP method"
  default     = "GET"
}

variable "path" {
  description = "The API resource path"
}

variable "lambda" {
  description = "The lambda name to invoke"
}

variable "region" {
  description = "The AWS region, e.g., eu-west-1"
}

variable "lambda_arn" {
  description = "The lambda arn to integrate"
}

variable "source_arn" {
  description = "The gateway api execution arn to be passed to permission"
}

# Example: request for GET /hello
resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "${var.method}"
  authorization = "NONE"
}

# Example: GET /hello => POST lambda
resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.request_method.http_method}"
  type        = "AWS"
  uri         = "${var.lambda_arn}"

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

# lambda => GET response
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Response for: GET /hello
resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method_response.response_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method.status_code}"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = "${var.lambda}"
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.source_arn}/*/${var.method}${var.path}"
}

output "http_method" {
  value = "${aws_api_gateway_integration_response.response_method_integration.http_method}"
}
