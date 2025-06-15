resource "aws_iam_user" "dda" {
    name = "dda"
}

resource "aws_iam_access_key" "dda" {
    user = aws_iam_user.dda.name
}

data "aws_iam_policy_document" "policy" {
   statement{
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
   } 
}

resource "aws_iam_policy" "policy" {
    name = "dda-policy"
    policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_user_policy_attachment" "policy" {
    user = aws_iam_user.dda.name
    policy_arn = aws_iam_policy.policy.arn
}