# mongodb-shard-cluster-generator

MongoDB Cluster Replica Sets with Shards needs 3 type of instances

- Configuration Server: Store MetaData
- MongoS: MongoDB Reverse Proxy Router
- Shards: MongoDB storage slave which each hold a piece of information; hence, shards

All 3 instances type need to setup with Replica Set, a redundant backup server of itself.

- A Replica Set is consisted of 3 minor instances.

In order to secure Replica Sets

- communication with outside client, it needs TLS certificates. When applied, `Auth` is assumed, and it can be set up with username and password

- communication internal within group of instance, it also needs TLS certicates X509 compatible, but this project use text file instead (because I cannot seem to make it work).

After set up Configuration Server, a primary need to be set using `initscript` which calls to the other member of the set.

In order to complete the installation of MongoS, it needs:

- identity of the Configuration Primary Server
- identity of 2 Shards Replica Set (initiated using the `initscript`)


## How to Run Development Testing

1. Create a `.env` file from `sample.env` or a `.var` file from `sample.var` file from all directories and fill out the need information; Example has been given
2. Run the `run-dev.sh` from this directory
3. Wait

## Abbreviation

This project uses alot of shorted word, see [Abbreviation](ABBR.md) in this file

## See Also

[Compose Configuration](servers/README.md)

[Data Migration](migration-script/README.md)

[TLS Certificate](keycert/README.md)