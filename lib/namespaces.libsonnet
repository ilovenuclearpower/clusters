local k = import "k.libsonnet";
{
    local namespace_util = k.core.v1.namespace,
    local desired_names = ['content', 'system', 'http', 'storage'],
    new():: [
        namespace_util.new(name) for name in desired_names
    ],
}