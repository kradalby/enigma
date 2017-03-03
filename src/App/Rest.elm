module App.Rest exposing (base_url, createApiUrl)


base_url : String
base_url =
    ""


base_api_url : String
base_api_url =
    "/api"


createApiUrl : String -> String
createApiUrl endpoint =
    base_url ++ base_api_url ++ endpoint ++ "/?format=json"
