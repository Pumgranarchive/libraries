let datetime () =
  let open Unix in
  let tm = localtime (time ()) in
  (string_of_int tm.tm_mday) ^ "/" ^
  (string_of_int (tm.tm_mon + 1)) ^ "/" ^
  (string_of_int (tm.tm_year + 1900)) ^ " " ^
  (string_of_int tm.tm_hour) ^ ":" ^
  (string_of_int tm.tm_min) ^ ":" ^
  (string_of_int tm.tm_sec)
