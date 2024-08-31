local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);
local storageclass = k.storage.v1.storageClass;
local ns = k.core.v1.namespace;


{
    new(namespace):: {
        local monitoring_ns = ns.new(namespace) + {
            metadata: {
                name: namespace,
                labels: {
                    "pod-security.kubernetes.io/enforce": "privileged",
                    "pod-security.kubernetes.io/audit": "privileged",
                    "pod-security.kubernetes.io/warn": "privileged"
                },
            },
        },
        prom_ns: monitoring_ns,
        prometheus: helm.template("prometheus", "../charts/kube-prometheus-stack", {
            namespace: namespace,
            values: {
                server: {
                    retention: "1d"
                },
                installCRDs: true
            }
        }),
        
    }
}