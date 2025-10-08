# IAM Role for Service Account (IRSA) to access Secrets Manager
data "aws_iam_policy_document" "secrets_access_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:fast-food-api:fast-food-api-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# OIDC Provider for EKS
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.fast_food_cluster.identity[0].oidc[0].issuer

  tags = var.tags
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.fast_food_cluster.identity[0].oidc[0].issuer
}

# IAM Role for accessing Secrets Manager
resource "aws_iam_role" "secrets_access_role" {
  name               = "${var.cluster_name}-secrets-access-role"
  assume_role_policy = data.aws_iam_policy_document.secrets_access_assume_role.json

  tags = var.tags
}

# Policy to allow reading secrets
data "aws_iam_policy_document" "secrets_read_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.secrets_arns
  }
}

resource "aws_iam_policy" "secrets_read_policy" {
  name        = "${var.cluster_name}-secrets-read-policy"
  description = "Allow reading secrets from Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets_read_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_policy_attach" {
  role       = aws_iam_role.secrets_access_role.name
  policy_arn = aws_iam_policy.secrets_read_policy.arn
}


