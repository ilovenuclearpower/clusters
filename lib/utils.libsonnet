local k = import "k.libsonnet";

{
    privileged_namespace(namespace):: k.core.v1.namespace.new(namespace) + {
            metadata+: {
                name: namespace,
                labels+: {
                    "pod-security.kubernetes.io/enforce": "privileged",
                    "pod-security.kubernetes.io/audit": "privileged",
                    "pod-security.kubernetes.io/warn": "privileged"
                },
            },
        },
}
