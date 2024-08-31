local k = import "k.libsonnet";
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local createHelm = function(file) tanka.helm.new(file);
local helm = createHelm(std.thisFile);
local storageclass = k.storage.v1.storageClass;
local ns = k.core.v1.namespace;
local utils = import "utils.libsonnet";
{
    new(namespace):: {

        nfs_ns: utils.privileged_namespace(namespace),
        nfs: helm.template("nfs", "../charts/csi-driver-nfs", {
            namespace: namespace
        })
    },
    create_storageclass(name, share_folder, ip):: {
        storageclass: storageclass.new(name) + {
            provisioner: "csi.nfs.csi.k8s.io",
            parameters: {
                server: "192.168.88.51",
                share: share_folder

            }
        }
    }
}