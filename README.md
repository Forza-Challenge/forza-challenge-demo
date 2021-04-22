# FCDemo

Forza Challenge API Demo

## API

1. Create user
```
POST  /api/v1/users


body parameters: {"device_id": "72fe37ee-62f5-444f-a237-dc00c195d1c5"}

response: 200  {"user_id": "9bd44a8c-e130-4c1b-87d6-8f9d97c5f1e6"}

errors: 400 {"error": "invalid device_id"}
```