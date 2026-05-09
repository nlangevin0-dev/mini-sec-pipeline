output "kafka_broker_public_ip" {
  description = "Public IP of the Kafka broker EC2 instance"
  value       = aws_instance.kafka_broker.public_ip
}

output "kafka_broker_public_dns" {
  description = "Public DNS of the Kafka broker EC2 instance"
  value       = aws_instance.kafka_broker.public_dns
}

output "events_bucket" {
  description = "S3 bucket name for events archive"
  value       = aws_s3_bucket.events.bucket
}