import json
import sys
import argparse
import yaml
from jsonschema import validate




def _emit_result(valid, error) -> None:
    # Terraform external data source expects: JSON object with string keys and string values.
    print(json.dumps({"valid": str(valid).lower(), "error": error}))
    sys.exit(0)

def main():
    global data, schema
    parser = argparse.ArgumentParser(description='Generate Istio VirtualService rules from mapping YAML.')
    parser.add_argument('--input', '-i', help='Input YAML mapping file. Use "-" to read from stdin.')
    parser.add_argument('--schema', '-s', help='Schema file to validate against.')
    parser.add_argument('--terraform', '-t', action='store_true', help='Flag to indicate running in Terraform context. If set, output will be formatted for Terraform external data source.')
    args = parser.parse_args()

    try:
        with open(args.schema, 'r') as s:
            schema = json.load(s)
    except Exception as e:
        if args.terraform:
            _emit_result(False, f"Error loading schema: {e}")
        else:
            print(f"Error loading schema: {e}", file=sys.stderr)
            sys.exit(1)

    try:
        if args.input == '-':
            query = json.load(sys.stdin)
            data = yaml.safe_load(query.get('content', ''))
        else:
            with open(args.input, 'r') as f:
                data = yaml.safe_load(f)
    except Exception as e:
        if args.terraform:
            _emit_result(False, f"Error loading input: {e}")
        else:
            print(f"Error loading input: {e}", file=sys.stderr)
            sys.exit(1)

    try:
        validate(instance=data, schema=schema)
    except Exception as e:
        # Keep stdout clean; Terraform will surface stderr when exit code != 0.
        if args.terraform:
            _emit_result(False, f"Error loading input: {e}")
        else:
            print(f"Schema validation failed: {e}", file=sys.stderr)
            sys.exit(1)
    if args.terraform:
        _emit_result(True,'')
    else:
        print("Schema validation successful.")
        sys.exit(0)

if __name__ == "__main__":
    main()
