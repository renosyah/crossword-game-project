extends Node
# uncomment one line code below if you want to use it
# and copy and change file name from credentials_example.gd -> credentials.gd
# class_name Credentials

# dont change this
const PORT := 31419
const LOCAL_BINDING :String = "127.0.0.1"
const AUTH_SERVER :String = "https://accounts.google.com/o/oauth2/v2/auth"
const TOKEN_REQ_SERVER :String = "https://oauth2.googleapis.com/token"
const TOKEN_REVOKE_SERVER :String = "https://accounts.google.com/o/oauth2/revoke"

# change the value!
const WEB_REDIRECT_URL :String = "YOUR_LOCAL_OR_PROD_WEB_REDIRECT_URL" # for web only
const WEB_CLIENT_SECRET :String = "YOUR_WEB_CLIENT_SECRET"
const CLIENT_ID :String = "YOUR_CLIENT_ID"
const FILE_PASSWORD :String = "YOUR_FILE_PASSWORD"

