# Oriel

Oriel is a multinode Mnesia example project written in Elixir.

## Error Codes

| Error Code  | HTTP Status Code        | Devcors Usage           |
| ----------- | ----------------------- | ----------------------- |
| 4XX         | Client Errors           | Client Errors           |
| 5XX         | Server Errors           | Server Errors           |
| 500         | Internal Server Error   | Internal Server Error   |

## Docker

Build docker image.

```sh
cp tools/local_environment.sh.example tools/local_environment.sh
# configure the above file
. tools/local_environment.sh
make -f tools/docker/Makefile build
```

Run docker image.

```sh
cp tools/docker/docker.env.example tools/docker/docker.env
# configure the above file
make -f tools/docker/Makefile run
```

See `tools/docker/Makefile` and `tools/docker/docker.env.example` for details.

Note that values for the `NODE_COOKIE` and `SECRET_KEY_BASE` can be generated with the following command.

```sh
mix phx.gen.secret
```

`TTL` is measured in seconds and`TTL_HEARTBEAT` is measured in milliseconds.
`bc` can be used to calculate values, if necessary.

```sh
# 1 day in seconds
echo '1*24*60*60' | bc

# 1 day in milliseconds
echo '1*24*60*60*1000' | bc
```

Publish the docker image.

```sh
docker login --username="${DOCKERHUB_USERNAME}"
docker push "${DOCKER_IMAGE}"
docker push "${DOCKER_IMAGE_LATEST}"
```

## curl

GraphQL Query Examples

```sh
QUERY='query Ping { ping { date datetime pong success time } }'
QUERY_VARIABLES='{}'

QUERY='query Info { info { node nodeList nodeVisible date time datetime ttl ttlHeartbeat remoteIp version } }'
QUERY_VARIABLES='{}'

QUERY='mutation CreateItem($item: CreateItemInput!) { createItem(item: $item) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "item": { "itemId": "itemId1", "ownerId": "ownerId1", "position": "position1", "type": "type1" } }'

QUERY='mutation CreateItems($items: [CreateItemInput]!) { createItems(items: $items) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "items": [ { "itemId": "itemId2", "ownerId": "ownerId2", "position": "position2", "type": "type2" }, { "itemId": "itemId3", "ownerId": "ownerId3", "position": "position3", "type": "type3" } ] }'

QUERY='query ReadItem($item: ReadItemInput!) { item(item: $item) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "item": { "itemId": "itemId1", "ownerId": "ownerId1" } }'

QUERY='query ReadItems($items: [ReadItemInput]!) { items(items: $items) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "items": [ { "itemId": "itemId2", "ownerId": "ownerId2" }, { "itemId": "itemId3", "ownerId": "ownerId3" } ] }'

QUERY='mutation UpdateItem($item: UpdateItemInput!) { updateItem(item: $item) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "item": { "itemId": "itemId1", "ownerId": "ownerId1", "position": "updated_position1" } }'

QUERY='mutation UpdateItems($items: [UpdateItemInput]!) { updateItems(items: $items) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "items": [ { "itemId": "itemId2", "ownerId": "ownerId2", "type": "updated_type2" }, { "itemId": "itemId3", "ownerId": "ownerId3", "position": "updated_position3", "type": "updated_type3" } ] }'

QUERY='mutation DeleteItem($item: DeleteItemInput!) { deleteItem(item: $item) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "item": { "itemId": "itemId1", "ownerId": "ownerId1" } }'

QUERY='mutation DeleteItems($items: [DeleteItemInput]!) { deleteItems(items: $items) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "items": [ { "itemId": "itemId2", "ownerId": "ownerId2" }, { "itemId": "itemId3", "ownerId": "ownerId3" } ] }'

QUERY='query ReadById($itemId: String!) { getItemsById(itemId: $itemId) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "itemId": "itemId1" }'

QUERY='query ReadByIds($itemIds: [String]!) { getItemsByIds(itemIds: $itemIds) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "itemIds": [ "itemId2", "itemId3" ] }'

QUERY='query Search($item: SearchItemInput!) { search(item: $item) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "item": { "itemId": "itemId1", "ownerId": "ownerId1", "type": "type1", "position": "position1", "remoteIp": "127.0.0.1", "createdAt": "2019-01-22 14:14:29Z", "updatedAt": "2019-01-22 14:14:29Z" } }'

QUERY='query SearchUnion($items: [SearchItemInput]!) { searchUnion(items: $items) { itemId ownerId type position remoteIp createdAt updatedAt } }'
QUERY_VARIABLES='{ "items": [ { "createdAt": "2019-01-22 14:14:29Z" }, { "updatedAt": "2019-01-22 14:14:29Z" } ] }'

HOST='http://127.0.0.1:8080'
ENDPOINT='/graphql'
CONTENT_TYPE='Content-Type: application/json'
VERB='POST'
curl -X "${VERB}" -s -H "${CONTENT_TYPE}" -d "{\"query\": \"${QUERY}\", \"variables\": ${QUERY_VARIABLES}}" "${HOST}${ENDPOINT}" && echo
```

## Queries

Diagnostic Queries
```graphql
query Diagnostic {
  ping {
    date
    datetime
    pong
    success
    time
  }
  info {
    node
    nodeList
    nodeVisible
    date
    time
    datetime
    ttl
    ttlHeartbeat
    remoteIp
    version
  }
}
```

Diagnostic Query Variables
```javascript
{}
```

Read Queries
```graphql
query Read($item: ReadItemInput!, $items: [ReadItemInput]!) {
  item(item: $item) {
    ...AllItemFields
  }
  items(items: $items) {
    ...AllItemFields
  }
}

fragment AllItemFields on Item {
  itemId
  ownerId
  type
  position
  remoteIp
  createdAt
  updatedAt
}
```

Read Query Variables
```javascript
{
  "item": {
    "itemId": "itemId1",
    "ownerId": "ownerId1"
  },
  "items": [
    {
      "itemId": "itemId2",
      "ownerId": "ownerId2"
    },
    {
      "itemId": "itemId3",
      "ownerId": "ownerId3"
    }
  ]
}
```

Read by ID Queries
```graphql
query ReadById($itemId: String!, $itemIds: [String]!) {
  getItemsById(itemId: $itemId) {
    ...AllItemFields
  }
  getItemsByIds(itemIds: $itemIds) {
    ...AllItemFields
  }
}

fragment AllItemFields on Item {
  itemId
  ownerId
  type
  position
  remoteIp
  createdAt
  updatedAt
}
```

Read by ID Query Variables
```javascript
{
  "itemId": "itemId1",
  "itemIds": [
    "itemId2",
    "itemId3"
  ]
}
```

Search Queries
```graphql
query Search($item: SearchItemInput!, $items: [SearchItemInput]!) {
  search(item: $item) {
    ...AllItemFields
  }
  searchUnion(items: $items) {
    ...AllItemFields
  }
}

fragment AllItemFields on Item {
  itemId
  ownerId
  type
  position
  remoteIp
  createdAt
  updatedAt
}
```

Search Query Variables
```javascript
{
  "item": {
    "itemId": "itemId1",
    "ownerId": "ownerId1",
    "type": "type1",
    "position": "position1",
    "remoteIp": "127.0.0.1",
    "createdAt": "2019-01-22 14:14:29Z",
    "updatedAt": "2019-01-22 14:14:29Z"
  },
  "items": [
    {
      "createdAt": "2019-01-22 14:14:29Z"
    },
    {
      "updatedAt": "2019-01-22 14:14:29Z"
    }
  ]
}
```

## Mutations

Create Queries
```graphql
mutation Create($item: CreateItemInput!, $items: [CreateItemInput]!) {
  createItem(item: $item) {
    ...AllItemFields
  }
  createItems(items: $items) {
    ...AllItemFields
  }
}

fragment AllItemFields on Item {
  itemId
  ownerId
  type
  position
  remoteIp
  createdAt
  updatedAt
}
```

Create Query Variables
```javascript
{
  "item": {
    "itemId": "itemId1",
    "ownerId": "ownerId1",
    "position": "position1",
    "type": "type1"
  },
  "items": [
    {
      "itemId": "itemId2",
      "ownerId": "ownerId2",
      "position": "position2",
      "type": "type2"
    },
    {
      "itemId": "itemId3",
      "ownerId": "ownerId3",
      "position": "position3",
      "type": "type3"
    }
  ]
}
```

Update Queries
```graphql
mutation Update($item: UpdateItemInput!, $items: [UpdateItemInput]!) {
  updateItem(item: $item) {
    ...AllItemFields
  }
  updateItems(items: $items) {
    ...AllItemFields
  }
}

fragment AllItemFields on Item {
  itemId
  ownerId
  type
  position
  remoteIp
  createdAt
  updatedAt
}
```

Update Query Variables
```javascript
{
  "item": {
    "itemId": "itemId1",
    "ownerId": "ownerId1",
    "position": "updated_position1"
  },
  "items": [
    {
      "itemId": "itemId2",
      "ownerId": "ownerId2",
      "type": "updated_type2"
    },
    {
      "itemId": "itemId3",
      "ownerId": "ownerId3",
      "position": "updated_position3",
      "type": "updated_type3"
    }
  ]
}
```

Delete Queries
```graphql
mutation Delete($item: DeleteItemInput!, $items: [DeleteItemInput]!) {
  deleteItem(item: $item) {
    ...AllItemFields
  }
  deleteItems(items: $items) {
    ...AllItemFields
  }
}

fragment AllItemFields on Item {
  itemId
  ownerId
  type
  position
  remoteIp
  createdAt
  updatedAt
}
```

Delete Query Variables
```javascript
{
  "item": {
    "itemId": "itemId1",
    "ownerId": "ownerId1"
  },
  "items": [
    {
      "itemId": "itemId2",
      "ownerId": "ownerId2"
    },
    {
      "itemId": "itemId3",
      "ownerId": "ownerId3"
    }
  ]
}
```

