# Jenkins IAM policy - attach AWS managed policies
resource "aws_iam_role_policy_attachment" "jenkins_ec2_describe" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_cluster" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
