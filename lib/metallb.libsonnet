local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);

local ns = k.core.v1.namespace;
{
    new(namespace, ip_range):: {
        local metallb_namespace = ns.new(namespace) + {
            metadata: {
                name: namespace,
                labels: {
                    "pod-security.kubernetes.io/enforce": "privileged",
                    "pod-security.kubernetes.io/audit": "privileged",
                    "pod-security.kubernetes.io/warn": "privileged"
                },
            },
        },
        metallb_namespace: metallb_namespace,
        metallb: helm.template("metallb", "../charts/metallb", {
            namespace: namespace,
        }),
        metallb_config: {
            apiVersion: "metallb.io/v1beta1",
            kind: "IPAddressPool",
            metadata: {
                name: "default",
                namespace: namespace
            },
            spec: {
                addresses: ip_range
            }
        }
    }
}