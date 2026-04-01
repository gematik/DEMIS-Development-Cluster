# Mapping Schema Description

This document describes the current YAML contract for Istio routing templates.
The source of truth is the JSON schema at `.scripts/traffic_routes_templates.schema.json`.
The YAML file is consumed by `.scripts/generate_istio_rules.py` to produce `traffic_routes` output for Terraform/Istio processing.

The current schema is based on:
- root key `traffic_routes_templates`
- service-level template defaults
- per-route entries in `http_route_configs`
- free-form `variables` maps used for placeholder substitution

## Input File Structure

The root object must contain exactly one required property:

| Field | Type | Required | Description |
|---|---|---|---|
| `traffic_routes_templates` | List<[TemplateObject](#template-object)> | Yes | List of service routing templates. |

### Root constraints

- Root type is `object`
- Additional root properties are **not allowed**
- `traffic_routes_templates` is required

## Output File Structure

The generator produces a document with root key `traffic_routes`.
Each entry contains the target service and the generated list of rules.

```yaml
traffic_routes:
- service: service-name
  rules:
  - match: ...
    rewrite: ...
    delegate: ...
    headers: ...
```

## Template Object

Each item in `traffic_routes_templates` describes one service plus optional service-level defaults.

| Field | Type | Required | Description |
|---|---|---|---|
| `service` | string | Yes | Service name written into the output entry. Must be non-empty. |
| `enabled` | boolean | Yes | If `false`, the service is skipped by the generator. |
| `variables` | Map<string,string> | No | Service-level placeholder values. |
| `delegate` | [DelegateObject](#delegate-object) | No | Default delegate for all route configs unless overridden. |
| `additional_headers` | Map<string,string> | No | Static headers to append to all routes for this service (e.g., `x-service-type`). |
| `matches` | List<[MatchObject](#match-object)> | No | Default match list for all route configs unless overridden. |
| `rewrite` | [RewriteObject](#rewrite-object) | No | Default rewrite for all route configs unless overridden. |
| `http_route_configs` | List<[HttpRouteConfigObject](#httprouteconfig-object)> | Yes | One or more concrete route configurations for this service. |

### Template constraints

- Additional properties are **not allowed**
- Required fields: `service`, `enabled`, `http_route_configs`
- `service` must have `minLength: 1`
- `http_route_configs` must contain at least one item

## HttpRouteConfig Object

Each `http_route_configs` item produces one generated rule object.
It may reuse service-level defaults or override them.

| Field | Type | Required | Description                                                                                                                |
|---|---|---|----------------------------------------------------------------------------------------------------------------------------|
| `variables` | Map<string,string> | No | Route-level placeholder values. These are merged over service-level `variables`.                                           |
| `matches` | List<[MatchObject](#match-object)> | No | Route-level match list. If present, it replaces service-level `matches` for this rule.                                     |
| `additional_headers` | Map<string,string> | No | Route-level static headers to append to routes for this `matches`. These are merged with service-level `additional_headers`. |
| `rewrite` | [RewriteObject](#rewrite-object) | No | Route-level rewrite. Overrides the service-level `rewrite`.                                                                |
| `delegate` | [DelegateObject](#delegate-object) | No | Route-level delegate. Overrides the service-level `delegate`.                                                              |

### HttpRouteConfig constraints

- Additional properties are **not allowed**
- At least one property must be present (`minProperties: 1`)
- If `matches` is present, it must contain at least one item

## Match Object

A `MatchObject` describes one entry inside the generated Istio `match` list.
Multiple items in `matches` become OR conditions within one HTTP route rule.

| Field | Type | Required | Description |
|---|---|---|---|
| `uri_template` | string | Yes | URI template to match after variable substitution. Must be non-empty. |
| `method` | object | No | Optional method matcher shape accepted by the schema. See [Method field shapes](#method-field-shapes). |
| `match_type` | string | No | URI matching strategy: `prefix` or `regex`. If omitted, the generator defaults to `prefix`. |
| `headers` | Map<string,string> | No | Required request headers for the match. Values must be non-empty strings. |
| `ignoreUriCase` | boolean | No | Passed through to the generated match block when `true`. |
| `without_headers` | List<string> \| Map<string,object> | No | Headers that must be absent. See [without_headers shapes](#without_headers-shapes). |

### Match constraints

- Additional properties are **not allowed**
- `uri_template` is required and must be non-empty
- `headers` values must be non-empty strings

### Method field shapes

The schema accepts exactly one of these object shapes for `method`:

| Shape | Example |
|---|---|
| exact HTTP method | `method: { exact: GET }` |
| prefix match | `method: { prefix: X- }` |
| regex match | `method: { regex: ^X-.* }` |

Notes:
- For `exact`, allowed values are: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`
- Each shape disallows additional properties
- This field is part of the input contract defined by the schema

### without_headers shapes

The schema supports two equivalent input forms:

```yaml
without_headers:
  - x-internal
  - x-debug
```

or

```yaml
without_headers:
  x-internal: {}
  x-debug: {}
```

Generator behavior:
- list form is expanded to the Istio-style object form
- object form is passed through as-is

## Rewrite Object

Controls URI rewriting before the request is forwarded.

| Field | Type | Required | Description |
|---|---|---|---|
| `target` | string | Yes | Rewrite target. Must be non-empty. |
| `method` | string | No | `simple` or `regex`. If omitted, the generator treats it as `simple`. |
| `match_template` | string | Conditional | Required when `method: regex`. Must be non-empty. |

### Rewrite constraints

- Additional properties are **not allowed**
- `target` is always required
- If `method` is `regex`, `match_template` is also required

## Delegate Object

Defines Istio VirtualService delegation.

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Delegate VirtualService name. Must be non-empty. |
| `namespace` | string | Yes | Delegate namespace. Must be non-empty. |

### Delegate constraints

- Additional properties are **not allowed**
- Both `name` and `namespace` are required

## Variables and Placeholders

Both template-level and route-level `variables` are string maps.
They are used for placeholder substitution in string fields such as:
- `uri_template`
- `headers` values
- `additional_headers` values
- rewrite `target`
- rewrite `match_template`
- delegate `name`
- delegate `namespace`

### Variable precedence

1. Service-level `variables` provide defaults
2. Route-level `variables` override service-level values with the same key

Unresolved placeholders are preserved literally by the generator.
That allows values like `${context_path}` or `${namespace}` to remain available for later Terraform interpolation.

## Precedence and Merge Rules

For each item in `http_route_configs`, the generator applies this behavior:

1. **Variables**: route-level values override service-level values
2. **Matches**: route-level `matches` replaces service-level `matches`
3. **Rewrite**: route-level `rewrite` overrides service-level `rewrite`
4. **Delegate**: route-level `delegate` overrides service-level `delegate`
5. **Additional headers**: route-level `additional_headers` are merged with service-level `additional_headers`

Notes:
- If both levels define the same additional header key, the route-level value wins
- If neither service nor route defines `matches`, the generated rule may have no `match` block
- A minimal valid rule can therefore be structurally empty except for values inherited from defaults

## Minimal Valid Example

```yaml
traffic_routes_templates:
  - service: svc-minimal
    enabled: true
    http_route_configs:
      - variables: {}
```

This is schema-valid because:
- `service`, `enabled`, and `http_route_configs` are present
- `http_route_configs` has one item
- that item has one property (`variables`), satisfying `minProperties: 1`

## Example: Service Defaults

```yaml
traffic_routes_templates:
  - service: svc-defaults
    enabled: true
    variables:
      version: v1
    delegate:
      name: delegate-${version}
      namespace: istio-${version}
    additional_headers:
      x-service-version: ${version}
      x-static: fixed
    matches:
      - uri_template: /${version}/patients
        headers:
          x-env: prod
        ignoreUriCase: true
        without_headers:
          - x-internal
    rewrite:
      target: /${version}/target
    http_route_configs:
      - variables: {}
```

Generated rule shape:

```yaml
traffic_routes:
  - service: svc-defaults
    rules:
      - match:
          - uri:
              prefix: /v1/patients
            headers:
              x-env:
                exact: prod
            ignoreUriCase: true
            withoutHeaders:
              x-internal: {}
        rewrite:
          uri: /v1/target
        delegate:
          name: delegate-v1
          namespace: istio-v1
        headers:
          request:
            set:
              x-service-version: v1
              x-static: fixed
```

## Example: Route-Level Overrides

```yaml
traffic_routes_templates:
  - service: svc-overrides
    enabled: true
    variables:
      prefix: api
      region: eu
    delegate:
      name: default-delegate
      namespace: mesh-system
    additional_headers:
      x-shared: ${region}
    rewrite:
      target: /fallback
    http_route_configs:
      - variables:
          region: us
          version: v2
        matches:
          - uri_template: /${prefix}/${version}/items
            match_type: regex
            headers:
              x-version: ${version}
            without_headers:
              x-remove: {}
        additional_headers:
          x-route: ${version}
        delegate:
          name: delegate-${version}
          namespace: ${region}-ns
        rewrite:
          method: regex
          match_template: /${prefix}/(.*)
          target: /rewritten/$1/${version}
```

Generated rule shape:

```yaml
traffic_routes:
  - service: svc-overrides
    rules:
      - match:
          - uri:
              regex: /api/v2/items
            headers:
              x-version:
                exact: v2
            withoutHeaders:
              x-remove: {}
        rewrite:
          uriRegexRewrite:
            match: /api/(.*)
            rewrite: /rewritten/$1/v2
        delegate:
          name: delegate-v2
          namespace: us-ns
        headers:
          request:
            set:
              x-route: v2
              x-shared: us
```

## Example: Accepted `method` Shapes

```yaml
traffic_routes_templates:
  - service: svc-methods
    enabled: true
    http_route_configs:
      - matches:
          - uri_template: /exact
            method:
              exact: GET
          - uri_template: /prefix
            method:
              prefix: X-
          - uri_template: /regex
            method:
              regex: ^X-.*
```

## Validation Summary

The JSON schema enforces these high-level rules:
- the root object only allows `traffic_routes_templates`
- every template requires `service`, `enabled`, and `http_route_configs`
- every `http_route_configs` list must contain at least one entry
- every route config must contain at least one property
- every match requires a non-empty `uri_template`
- every rewrite requires a non-empty `target`
- regex rewrites additionally require `match_template`
- delegate objects always require both `name` and `namespace`
- unknown properties are rejected throughout the schema

## Source of Truth

If this document and the implementation ever differ, treat these files as authoritative:
- `.scripts/traffic_routes_templates.schema.json` for structural validation
- `.scripts/generate_istio_rules.py` for generation semantics
- `unit-tests.tftest.hcl` and `testdata/` for working examples

