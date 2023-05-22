curl -XPOST \
    -H "Content-Type: application/json" \
    -H "x-npm-signature: sha256=7c0456720f3fdb9b94f5ad5e0c231a61e0fd972230d83eb8cb5062e1eed6ff5c" \
    -d '{"event":"package:publish","name":"@kafkajs/zstd","version":"1.0.0","hookOwner":{"username":"nevon"},"payload":{"name":"@kafkajs/zstd"},"change":{"version":"1.0.0"},"time":1603444214995}' \
    http://localhost:3000/hook