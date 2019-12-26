
function cPrint (str)
  local sw, sh = term.getSize()
  local cstr = string.rep(" ", math.floor(sw/2 - str:len()/2)) .. str .. string.rep(" ", math.ceil(sw/2 - str:len()/2))
  term.write(cstr .. "\n")
end

function fuelFormat ()
  if turtle.getFuelLimit() == 0 then
    return tostring(turtle.getFuelLimit())
  else
    return tostring(math.floor(turtle.getFuelLevel() / turtle.getFuelLimit() * 10000)/100) .. "%"
  end
end

function displayStatus ()
  local sw, sh = term.getSize()
  term.clear()
  term.setCursorPos(1,1)
  term.setCursorBlink(false)
  cPrint("Bob")
  cPrint("Version 0.1")
  term.write(string.rep("=",sw))
  print(" HDD Space: " .. fs.getFreeSpace("/") .. " bytes free")
  print(" Fuel: " .. fuelFormat())
  term.write(string.rep("=",sw))
  print(" [E] - Exit")
end

function exit ()
  term.clear()
  term.setCursorPos(1,1)
  print("Bye!")
end

os.setComputerLabel("Bob the " .. os.getComputerID())
displayStatus()

while true do
  local event, key = os.pullEvent("key")
  if key == keys.e then
    exit()
    break
  end
end