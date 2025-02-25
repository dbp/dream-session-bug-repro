let restrict handler request =
  match Dream.session_field request "user" with
  | None ->
    let%lwt () = Dream.set_session_field request "redirect" (Dream.target request) in
    Dream.redirect request "/login"
  | Some _ -> handler request

let () =
  Dream.run
  @@ Dream.logger
  @@ Dream.cookie_sessions
  @@ Dream.router [
    Dream.get "/"
      (fun request ->
         match Dream.session_field request "user" with
         | None ->
           Dream.html "Not Logged in"
         | Some username ->
           Printf.ksprintf
             Dream.html "Welcome back, %s!" (Dream.html_escape username));
    Dream.scope "/restricted" [restrict] [
      Dream.get "/**"
        (fun request ->
           match Dream.session_field request "user" with
             | None ->
               Dream.html "ERROR"
             | Some username ->
               Printf.ksprintf
               Dream.html "Welcome to the secure area, %s!" (Dream.html_escape username))
    ];
    Dream.get "/login"
      (fun request ->
         match Dream.session_field request "user" with
         | None ->
           let%lwt () = Dream.set_session_field request "user" "alice" in
           begin match Dream.session_field request "redirect" with
             | None -> Dream.redirect request "/"
             | Some redir -> Dream.redirect request redir
           end  
         | Some username ->
           Printf.ksprintf
             Dream.html "Welcome back, %s!" (Dream.html_escape username))
  ]
