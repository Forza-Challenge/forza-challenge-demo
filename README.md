# FCDemo

Forza Challenge API Demo

## API Host

`https://demo.forza-challenge.com`

```Bash
curl https://demo.forza-challenge.com/status/health

{"status":"ok"}
```

## API Description

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

3. Make challenge predictions for user:
```
POST  /api/v1/users/:user_id/challenges/:challenge_id

path parameters: user_id, challenge_id

body parameters: { "predictions" => [prediction1, ..., prediction10] }

  prediction: %{match_id: 3255586, prediction: "home" | "draw" | "away"}

response: 204

errors: 
  400 {"error": "invalid user_id or challenge_id"}
  422 {"error": `invalid prediction error message`}
  404 {"error": `challenge not found error message`}
```

## API Calls Examples
```Bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"device_id":"72fe37ee-62f5-444f-a237-dc00c195d1c5"}' \
  https://demo.forza-challenge.com/api/v1/users

{"user_id":"713386df-6315-483c-b06a-c39b5776c961"}
```

```Bash
curl --header "Content-Type: application/json" \
  --request GET \
  https://demo.forza-challenge.com/api/v1/users/713386df-6315-483c-b06a-c39b5776c961/challenges

{
    "active_challenges": [
        {
            "id": "6bf76dcd-a431-4426-98ee-2d73d5c78d7a",
            "matches": [
                {
                    "away_team_name": "Liverpool",
                    "away_team_odds": 2.6,
                    "draw_odds": 3.55,
                    "home_team_name": "Manchester Utd",
                    "home_team_odds": 2.75,
                    "id": 2737856,
                    "starts_at": "2021-05-02T15:30:00Z",
                    "tournament_name": "England - Premier League|Anglia - Premier League|Engleska - 1.liga|Engleska - Premijer Liga|Anglia - 1.liga"
                },
                ...
                {
                    "away_team_name": "Ethiopia Bunna",
                    "away_team_odds": 1.38,
                    "draw_odds": 4.1,
                    "home_team_name": "Jimma Aba J.",
                    "home_team_odds": 7.0,
                    "id": 3297266,
                    "starts_at": "2021-04-28T16:00:00Z",
                    "tournament_name": "Premier League|Etiopia - Premier League|Premier League||Etiopia - 1.liga"
                }
            ]
        }
    ]
}
```