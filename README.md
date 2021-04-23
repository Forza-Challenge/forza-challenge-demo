# FCDemo

Forza Challenge API Demo

## API

1. Create user
```
POST  /api/v1/users


body parameters: {"device_id": "72fe37ee-62f5-444f-a237-dc00c195d1c5"}

responses: 200 {"user_id": "9bd44a8c-e130-4c1b-87d6-8f9d97c5f1e6"}

errors: 400 {"error": "invalid device_id"}
```

2. Get active challenges for user:
```
GET   /api/v1/users/:user_id/challenges 

path parameters: user_id

resposes:
    200 {"active_challenges": [ {"id": "95afe4d6-8290-48ed-becd-b61aa92b47d2", "matches": [match1, ..., match10]}, ...] }
        
        match: {
          "away_team_name": "Dortmund",
          "away_team_odds": 2.2,
          "draw_odds": 4.0,
          "home_team_name": "Wolfsburg",
          "home_team_odds": 3.0,
          "id": 2725236,
          "starts_at": "2021-04-24T13:30:00Z",
          "tournament_name": "Germany - Bundesliga|Germania - Bundesliga|Njemačka - 1.liga|Nemačka - Bundesliga|Niemcy - 1.liga"
        }

    200  {"active_challenges": null}

errors: 400 {"error": "invalid user_id"}
```