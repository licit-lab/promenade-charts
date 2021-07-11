
# Neo4j for Promenade

1. From `neo4j/helm-neo4j` folder launch following command to instantiate neo4j:

        helm install <neo4j-deployment-name> .

    Before using helm you need to export openshift project name to your console environment variable with: `export TILLER_NAMESPACE=<oc-project-name>`
    
2. After initialization copy network topology file in neo4j-core Leader instance at path `<NEO4J_HOME>/import/`:
    * Leader can be found by performing the following DB-query:
    
            call dbms.cluster.overview() yield addresses, role
            
        + You can use OpenShift `oc` terminal client as follows:
      
                oc exec <neo4j-core-pod> -- cypher-shell -u <neo4j-username> -p <neo4j-password> --format verbose "<leader-query>"
        
        + Or you can connect to _Neo4jBrowser_ http client and after inserting appropriate `username`, `password`, and `neo4j-bolt-address` it will open _Neo4jBrowser_ web console, 
        then perform the leader query
    
    * You can copy network topology file to neo4j leader pod using `oc` client via:
        
            oc rsync <local-folder> <neo4j-leader-pod-name>:<NEO4J_HOME>/import/
            
        in our case `<NEO4J_HOME>` is `/var/lib/neo4j`
        
3. To instantiate a graph perform via `oc` or _Neo4jBrowser_ following queries:
        
    + Instantiate nodes (with initial random Betwenness Centrality value)
        
            USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///<nodes_file.csv>' AS line CREATE (i:Intersection {longitude: toFloat(line.longitude), latitude: toFloat(line.latitude), osmid: toInteger(line.osmid), betweenness: 0})

    + Create constraint on node _osmid_
    
            CREATE CONSTRAINT ON (node:Intersection) ASSERT node.osmid IS UNIQUE
            
    + Instantiate edges
    
            USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM 'file:///<links_file.csv>' AS line MATCH(src:Intersection{osmid:toInteger(line.from)}) WITH src,line MATCH (dst:Intersection {osmid:toInteger(line.to)}) CREATE (src)-[r:STREET]->(dst) WITH r,line SET r.id = coalesce(toInteger(r.id), -1),r.coordinates = line.coordinates,r.from = toInteger(line.from),r.to = toInteger(line.to),r.length = toFloat(line.length),r.speedlimit =  coalesce(toInteger(line.speedlimit), -1),r.name = coalesce(line.name, ' '),r.areaname = coalesce(line.areaname, ' '),r.weight = toFloat(line.length),r.ffs = toFloat(line.ffr)           
   

