let main out =
  Eio.Flow.copy_string "Hello, world!\n" out

let _ = Eio_main.run @@ fun env ->
  main (Eio.Stdenv.stdout env)