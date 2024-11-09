let run_client ~net ~addr =
  Eio.Switch.run ~name:"client" @@ fun sw ->
  Eio.traceln "Client: connecting to server";
  let flow = Eio.Net.connect ~sw net addr in
  (* Read all data until end-of-stream (shutdown): *)
  Eio.traceln "Client: received %S" (Eio.Flow.read_all flow)

let handle_client flow _addr =
  Eio.traceln "Server: got connection from client";
  Eio.Flow.copy_string "Hello from server" flow;;

let run_server socket dom_mgr =
  Eio.Net.run_server 
    ~additional_domains:(dom_mgr, Domain.recommended_domain_count ())
    socket 
    handle_client
    ~on_error:(Eio.traceln "Error handling connection: %a" Fmt.exn);;

let main ~net ~domain ~addr =
  Eio.Switch.run ~name:"main" @@ fun sw ->
    let server = Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 addr in
    Eio.Fiber.fork_daemon ~sw (fun () -> run_server server domain);
    run_client ~net ~addr;;

let _ = 
  Eio_main.run @@ fun env -> 
    main 
      ~net:(Eio.Stdenv.net env) 
      ~domain:(Eio.Stdenv.domain_mgr env)
      ~addr:(`Tcp (Eio.Net.Ipaddr.V4.loopback, 8080));;

(* let tcp_conn_handler flow _addr =
  Eio.traceln "Server: got connection from client";
  Eio.Flow.copy_string "Hello from server" flow;;

let listen sw dom_mgr net addr =
  let module Net = Eio.Net in
  let listening_socket =
    Net.listen
      ~reuse_addr:true
      ~reuse_port:true
      ~backlog:1024
      ~sw net addr in
  Net.run_server
    ~additional_domains:(
      dom_mgr, Domain.recommended_domain_count ())
    ~on_error:(fun exn ->
      prerr_endline @@ Printexc.to_string exn;
      Printexc.print_backtrace stderr;
      flush stderr)
    listening_socket
    tcp_conn_handler

let main env addr =
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let dom_mgr = env #domain_mgr in
  let net = env #net in
  listen sw dom_mgr net addr;;

let _ = 
  Eio_main.run @@ fun env -> 
    main 
      (Eio.Stdenv.net env) 
      (`Tcp (Eio.Net.Ipaddr.V4.loopback, 8080)) *)
