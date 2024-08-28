local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);
{
    new(namespace):: {
        nfs_namespace: k.core.v1.namespace.new(namespace),
        nfs: helm.template("nfs", "../charts/csi-driver-nfs", {
            namespace: namespace,
        })
    }
}