import yaml
import argparse
import sys
import copy
from string import Template
import json
import os

class SafeTemplate(Template):
    # This pattern matches standard shell variable syntax:
    # $var, ${var}, or ${var:default}.
    # We want to use this for substitution but be permissive.
    pass

def _emit_result(valid, result, error) -> None:
    # Terraform external data source expects: JSON object with string keys and string values.
    print(json.dumps({"valid": str(valid).lower(), "result": json.dumps(result) , "error": error}))
    sys.exit(0)

def load_yaml(file_path):
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)


def load_yaml_stream(stream):
    return yaml.safe_load(stream)

def substitute_variables(text, variables):
    if not isinstance(text, str):
        return text
    # We use safe_substitute to preserve placeholders that are not in the variables map
    # (like ${context_path} or ${namespace})
    return SafeTemplate(text).safe_substitute(variables)

def process_rewrite(rewrite_config, variables):
    if not rewrite_config:
        return None

    result = {}
    method = rewrite_config.get('method', 'simple')

    if method == 'simple':
        target = rewrite_config.get('target')
        if target:
            result['uri'] = substitute_variables(target, variables)

    elif method == 'regex':
        match_template = rewrite_config.get('match_template')
        target = rewrite_config.get('target')
        if match_template and target:
            result['uriRegexRewrite'] = {
                'match': substitute_variables(match_template, variables),
                'rewrite': substitute_variables(target, variables)
            }

    return result

def process_delegate(delegate_config, variables):
    if not delegate_config:
        return None

    result = {
        'name': substitute_variables(delegate_config.get('name'), variables),
        'namespace': substitute_variables(delegate_config.get('namespace'), variables)
    }
    return result

def generate_match_block(match_config, default_match_type, variables):
    match_block = {}

    uri_template = match_config.get('uri_template')
    ignore_case = match_config.get('ignoreUriCase', False)
    match_type = match_config.get('match_type', default_match_type)
    method = match_config.get('method', {})

    if ignore_case:
        match_block['ignoreUriCase'] = ignore_case
    if method:
        match_block['method'] = method

    # Process URI Match
    if uri_template:

        val = substitute_variables(uri_template, variables)
        if match_type == 'regex':
            match_block['uri'] = {'regex': val}
        else: # default to prefix
            match_block['uri'] = {'prefix': val}

    # Process Headers
    headers = match_config.get('headers')
    if headers:
        header_matches = {}
        for key, value in headers.items():
            # If value converts to string properly
            header_matches[key] = {'exact': substitute_variables(str(value), variables)}
        match_block['headers'] = header_matches

    # Process Without Headers
    without_headers = match_config.get('without_headers')
    if without_headers:
        without_header_matches = {}
        if isinstance(without_headers, list):
            for header in without_headers:
                 without_header_matches[header] = {}
        elif isinstance(without_headers, dict):
             # Pass through simple map, no variable substitution assumed for keys,
             # maybe for values if needed, but usually empty {}
             without_header_matches = without_headers

        match_block['withoutHeaders'] = without_header_matches

    return match_block

def dump_data(data, stream, format):
    if format == 'yaml':
        yaml.dump(data, stream, sort_keys=False, indent=2)
    elif format == 'tfjson':
        _emit_result(True, data, '')
    elif format == 'json':
        json.dump(data, stream,sort_keys=False, indent=2)
    else:
        raise ValueError(f"Unsupported format: {format}")


def main():
    parser = argparse.ArgumentParser(description='Generate Istio VirtualService rules from mapping YAML.')
    parser.add_argument('--input', '-i', help='Input YAML mapping file. Use "-" to read from stdin.')
    parser.add_argument('--output', '-o', help='Output YAML file (default stdout)')
    parser.add_argument('--format', choices=['yaml', 'json', 'tfjson'], default='yaml', help='Output format')

    args = parser.parse_args()

    try:
        if args.input == '-':
            query = json.load(sys.stdin)
            data = yaml.safe_load(query.get('content', ''))
        else:
            data = load_yaml(args.input)
    except Exception as e:
        if args.format == 'tfjson':
            _emit_result(False, '', f"Error loading input: {e}")
        else:
            print(f"Error loading input: {e}", file=sys.stderr)
            sys.exit(1)
    try:
        traffic_routes = data.get('traffic_routes_templates', [])
        output_rules = []

        for service_def in traffic_routes:
            if not service_def.get('enabled', True):
                continue

            service_name = service_def.get('service')
            if not service_name:
                continue

            service_rules = []

            # Service Level Defaults
            service_rewrite = service_def.get('rewrite')
            service_delegate = service_def.get('delegate')
            additional_headers = service_def.get('additional_headers', {})
            service_vars = service_def.get('variables', {})

            service_matches_template = service_def.get('matches') # List of match templates

#             version_maps = service_def.get('version_maps', [])
            http_route_configs = service_def.get('http_route_configs', [])

            for route_configs in http_route_configs:
                # Prepare Variables
                vars = route_configs.get('variables',{})
                # Determine Match Configuration
                # Order of precedence:
                # 1. vmap 'matches' list
                # 2. service 'matches' list

                if vars:
                    # Merge service level variables with route level variables, route level takes precedence
                    merged_vars = copy.deepcopy(service_vars)
                    merged_vars.update(vars)
                    vars = merged_vars
                else:
                    vars = service_vars

                matches_to_process = route_configs.get('matches', service_matches_template)
                if matches_to_process is None:
                    matches_to_process = []


                # Rewrite Configuration
                # Precedence: vmap rewrite > service rewrite
                rewrite_config = route_configs.get('rewrite', service_rewrite)

                # Delegate Configuration
                # Precedence: vmap delegate > service delegate
                delegate_config = route_configs.get('delegate', service_delegate)

                # Generate Rules for this Version Map
                # If we have multiple matches, we might generate multiple rules or one rule with multiple matches?
                # Istio HTTPRoute has 'match' which is a list of match conditions.
                # AND logic applies within a list item (uri AND headers).
                # OR logic applies across list items in 'match'.
                # Usually we want ONE HTTPRoute block per "logical" version mapping, which might have multiple match clauses.

                # However, in the user example:
                #   - match:
                #     - headers: ...
                #       uri: ...
                #     - headers: ...
                #       uri: ...
                #     rewrite: ...
                #     delegate: ...

                # So we create ONE rule object for this vmap entry

                rule_object = {}

                # build the 'match' list
                match_list = []
                for m in matches_to_process:
                    mb = generate_match_block(m, 'prefix', vars)
                    if mb:
                        match_list.append(mb)

                if match_list:
                    rule_object['match'] = match_list

                # Rewrite
                if rewrite_config:
                    rw = process_rewrite(rewrite_config, vars)
                    if rw:
                        rule_object['rewrite'] = rw

                # Delegate
                if delegate_config:
                    dl = process_delegate(delegate_config, vars)
                    if dl:
                        rule_object['delegate'] = dl

                # Simple Headers (additional_headers) - usually apply to the response or request?
                # Istio supports 'headers' field in HTTPRoute for manipulation (request/response sets).
                # The input schema has 'additional_headers'. The user didn't specify distinct request/response.
                # Assuming request headers for now or purely descriptive if handled elsewhere?
                # Reviewing Istio: HTTPRoute > headers > request > set/add.
                # But the user example calls it "additional_headers".
                # Let's map it to headers: request: set used in Istio.

                # Also user mentioned "profile_headers"
                # "x-fhir-api-version auf die $version gesetzt ... ich möchte in diese Mapping Struktur auch definieren können was für zusätzliche statische request Header gesetzt werden sollen."

                request_headers_set = route_configs.get('additional_headers', {})

                if additional_headers:
                     request_headers_set.update(additional_headers)

                for key, value in request_headers_set.items():
                    request_headers_set[key] = substitute_variables(str(value), vars)

                # Note: User's complex example shows headers INSIDE match blocks too.
                # Those are MATCH conditions.
                # Here we are talking about headers to SET/ADD.

                if request_headers_set:
                    if 'headers' not in rule_object:
                        rule_object['headers'] = {}
                    if 'request' not in rule_object['headers']:
                        rule_object['headers']['request'] = {}
                    rule_object['headers']['request']['set'] = request_headers_set

                service_rules.append(rule_object)

            output_rules.append({
                'service': service_name,
                'rules': service_rules
            })

        # Output
        final_output = {'traffic_routes': output_rules}

        if args.output:
            with open(args.output, 'w') as f:
                dump_data(final_output, f, args.format)
        else:
            dump_data(final_output, sys.stdout, args.format)
    except Exception as e:
        if args.format == 'tfjson':
            _emit_result(False, '', f"Error processing data: {e}")
        else:
            print(f"Error processing data: {e}", file=sys.stderr)
            sys.exit(1)

if __name__ == "__main__":
    main()
