(* let main out =
  Eio.Flow.copy_string "Hello, world!\n" out

let _ = Eio_main.run @@ fun env ->
  main (Eio.Stdenv.stdout env) *)

let handle_client flow _addr =
  Eio.traceln "Server: got connection from client";
  Eio.Flow.copy_string "Hello from server" flow

let run_server socket =
  Eio.Net.run_server socket handle_client
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn)

let main ~net ~addr =
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let server = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
  Eio.Fiber.fork_daemon ~sw (fun () -> run_server server);

let _ = Eio_main.run @@ fun env ->
  main ~net:"127.0.0.1" ~addr:(`Tcp (Eio.Net.Ipaddr.V4.loopback, 8080))