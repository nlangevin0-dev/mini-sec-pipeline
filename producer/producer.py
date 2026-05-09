"""Pulls records from a public API and writes them to Kafka."""

import json
from kafka import KafkaProducer
import requests


KAFKA_BOOTSTRAP = "3.237.183.25:9092"
TOPIC = "events-raw"

def make_producer():
    """Create a KafkaProducer that serializes Python dicts to JSON bytes."""
    return KafkaProducer(
        bootstrap_servers=KAFKA_BOOTSTRAP,
        value_serializer=lambda v: json.dumps(v).encode("utf-8")
    )

def main():
    producer = make_producer()
    print(f"Connected to Kafka at {KAFKA_BOOTSTRAP}")

    resp = requests.get("https://api.github.com/events")
    data = resp.json()
    print(f"Got {len(data)} events from GitHub")
    for event in data:
        producer.send(TOPIC, value=event)
        print(f"Sent event {event['id']} of type {event['type']}")

    producer.flush()
    producer.close()
    print("Done")


if __name__ == "__main__":
    main()