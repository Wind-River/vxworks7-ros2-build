#!/bin/python

import json
import jsonschema
from jsonschema import Draft7Validator, validators
import os
import argparse

# Function to extend the validator with default values
def extend_with_default(validator_class):
    validate_properties = validator_class.VALIDATORS["properties"]

    def set_defaults(validator, properties, instance, schema):
        for property, subschema in properties.items():
            if "default" in subschema:
                instance.setdefault(property, subschema["default"])

        for error in validate_properties(validator, properties, instance, schema):
            yield error

    return validators.extend(validator_class, {"properties": set_defaults})

# Load the JSON schema
def load_schema(schema_path):
    with open(schema_path) as schema_file:
        return json.load(schema_file)

# Load the JSON data
def load_data(data_path):
    with open(data_path) as data_file:
        return json.load(data_file)

# Validate JSON data and apply defaults
def validate_data(schema, data):
    DefaultValidatingDraft7Validator = extend_with_default(Draft7Validator)
    DefaultValidatingDraft7Validator(schema).validate(data)

# Function to get URI based on name and release
def get_uri(data, name, release):
    base_url = "https://d13321s3lxgewa.cloudfront.net"
    for vxworks_release in data["vxworks"]:
        if vxworks_release["release"] == release:
            for sdk in vxworks_release["sdk"]:
                if sdk["name"] == name:
                    sdk_version = sdk["sdk_version"]
                    return f"{base_url}/wrsdk-vxworks7-{name}-{sdk_version}.tar.bz2"
    return None

# Main function to load, validate, and get URI
def main(schema_path, data_path, name, release):
    schema = load_schema(schema_path)
    data = load_data(data_path)
    validate_data(schema, data)
    return get_uri(data, name, release)

# Example usage
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse wrsdks.json and return URI based on name and release.')
    parser.add_argument('data_path', type=str, help='Path to the wrsdks.json file')
    parser.add_argument('name', type=str, help='Name of the SDK')
    parser.add_argument('release', type=str, help='Release version')
    
    args = parser.parse_args()
    
    base_dir = os.path.dirname(os.path.abspath(__file__))
    schema_path = os.path.join(base_dir, "schemas/wrsdk-schema.json")
    
    uri = main(schema_path, args.data_path, args.name, args.release)
    print(uri)

