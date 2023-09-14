# Servers

There are 3 type of Servers here,
    1. Config Server
    2. MongoS Router
    3. Shards Server


## How to

- When trying to start it up, do not forget to get the `cert` directory for each instance from the `keycert` directory to use in the startup

- Run the Config Server first, then the Shards, and then the Router last

- Config and Shards Server is made with _Replica Set_, which means that the _Slave_ Node has to be run first, then the _Master_ Node can be run afterward.

- Master Node can be identified with the presence of these files: `cluster-compose.yaml` + `init-compose.yaml` + `initscript`. Run the `initscript` to start it up

- After run the Master Node, you need to setup cluster with the Nodes by Log in to the Master Node and copy-run the `clusterscript` from the root directory of the Node. Example of Sample has been given

- Router Node can be run normally with `docker compose up`. It will uses the Authentication information from the `Config Server`