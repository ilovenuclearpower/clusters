local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);

local ns = k.core.v1.namespace;
{
    new(namespace, ip_range, peer_ASN, target_ASN):: {
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
            addresspool: {
            apiVersion: "metallb.io/v1beta1",
            kind: "IPAddressPool",
            metadata: {
                name: "k8s",
                namespace: namespace
            },
            spec: {
                addresses: ip_range,
                avoidBuggyIPs: true
            }
            },
            l2_peering: {
                apiVersion: "metallb.io/v1beta1",
                kind: "L2Advertisement",
                metadata: {
                    name: "local-network",
                    namespace: namespace
                },
                spec: {
                    ipAddressPools: ["k8s"],
                }
            },
        },  

    }
}