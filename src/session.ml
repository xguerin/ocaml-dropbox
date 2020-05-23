type t = {token : string}

let make token = {token}

let headers {token} =
  let value = "Bearer " ^ token in
  Cohttp.Header.init_with "Authorization" value
