# defmodule TwitchEx.EventSub.Transports.WebHook.Router do
#   use Plug.Router

#   alias TwitchEx.EventSub.Transports.WebHook.VerifyEventPlug

#   plug(:match)
#   plug(:dispatch)
#   plug(VerifyEventPlug)

#   get "/" do
#   end

#   match _ do
#     send_resp(conn, 404, "Oops!")
#   end
# end
