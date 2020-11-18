# Dropbox v2 API client for OCaml

## Coverage

The current implementation is partial. The completion of the full API is a work
in progress. Pull requests are welcome.

## Preprocessor extension for the Dropbox JSON serializer

The documentation
defines 3 kinds of types:

1. Union
2. Open unions
3. Datatype with subtypes

Unions uses the `".tag"` field to specify which field in the object is
available. Open unions are unions that can contain new information as the type
is extended. Example:
```json
{
  ".tag": "conflict",
  "conflict": { ".tag": "folder" }
}
```
Datatype with subtypes are usually `struct`-based types that can be structurally
extended within the same object. They use the `".tag"` field to specify which
type is encoded. Example:
```json
{
  ".tag": "file",
  "name": "...",
  ...
}
```
The serializer allows for more situations than the one presented above. However,
those seem to be enough to cover the use cases of the API. The full serializer
documentation can be found [here](https://github.com/dropbox/stone/blob/main/docs/json_serializer.rst). 
