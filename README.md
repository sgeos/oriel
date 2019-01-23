# Oriel

...

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

