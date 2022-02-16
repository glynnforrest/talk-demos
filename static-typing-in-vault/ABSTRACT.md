# 'Static Typing' in Vault

Imagine you're deploying a new application to Nomad, and it needs an S3 bucket. You file a request to the infrastructure team, who create a new bucket and put the credentials in Vault. You run the Nomad job, which pulls the S3 credentials from Vault. The secret is there, but not in the format you expected, so your application breaks!

In this talk, I'll share what I've learned writing tools that add 'static typing' to Vault secrets, and how they can help teams work together with Vault in a more reliable way.
