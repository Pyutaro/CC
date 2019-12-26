targs = { ... }
if #targs == 0 then
  print("dl <file>")
  error("no file specified")
end

local http_handler = http.get("http://localhost/" .. targs[1] .. ".lua")
local http_data = http_handler.readAll()
http_handler.close()

local file_handler = fs.open(targs[1], "wb")
file_handler.write(http_data)
file_handler.close()

print("Saved.")