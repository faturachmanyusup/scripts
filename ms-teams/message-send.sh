# Uncomment line below and fill its value or pass it to terminal / cmd / bash
# export CHAT_ID=""

export username="Faturachman Yusup"
export message="
  <p>First line</p>
  <p>Second line</p>
  <p>Third line line</p>
"

curl -X POST \
  -H "authorization: $TEAMS_ACCESS_TOKEN" \
  -H "content-type: application/json" \
  --data-raw '{
    "type":"Message",
    "messagetype":"RichText/Html",
    "contenttype":"Text",
    "imdisplayname":"'"$username"'",
    "conversationid":"'"$CHAT_ID"'",
    "content":"'"$message"'"
  }' \
  "https://teams.microsoft.com/api/chatsvc/apac/v1/users/ME/conversations/$CHAT_ID/messages"