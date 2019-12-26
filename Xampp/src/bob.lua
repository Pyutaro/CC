--v0.1.12
tArgs = { ... }
globalData = {}
globalData.config = {}
globalData.config.downloadPath = "http://localhost/"
globalData.version = ""
globalData.status = "Hmm..."
globalData.requireRefresh = false
globalData.running = true

function cPrint (str)
  local sw, sh = term.getSize()
  local cstr = string.rep(" ", math.floor(sw/2 - str:len()/2)) .. str .. string.rep(" ", math.ceil(sw/2 - str:len()/2))
  print(cstr)
end

function fuelFormat ()
  if turtle.getFuelLimit() == 0 then
    return tostring(turtle.getFuelLevel())
  else
    return tostring(math.floor(turtle.getFuelLevel() / turtle.getFuelLimit() * 10000)/100) .. "%"
  end
end

function displayStatus ()
  local sw, sh = term.getSize()
  term.clear()
  term.setCursorPos(1,1)
  term.setCursorBlink(false)
  cPrint("Bob " .. globalData.version)
  print(string.rep("=",sw))
  print(" HDD Space: " .. fs.getFreeSpace("/") .. " bytes free")
  print(" Fuel: " .. fuelFormat())
  print(string.rep("=",sw))
  print(" " .. globalData.status)
end

function getVersion (str)
  local nlPos = string.find(str, "\n")
  if nlPos ~= nil and nlPos ~= -1 then
    return string.sub(str,3,nlPos-1)
  else
    return "0"
  end
end

function download (file)
  local http_handler = http.get(file)
  local http_data = http_handler.readAll()
  http_handler.close()
  return http_data
end

function what ()
  local whats = {
    "What?",
    "Nani?",
    "What was that?",
    "Whaaaat?",
    "Eh?",
    "What's that?",
    "Sorry... what?"
  }
  local x = math.random(#whats)
  print(whats[x])
end

function createConfigFile ()
  print("Did you want to download updates from...")
  print("[1] - Localhost")
  print("[2] - Github (master)")
  print("[3] - Github (working)")
  print("[4] - Another source...")
  while true do
    local input = io.read()
    if input == "1" then
      globalData.config.downloadPath = "http://localhost/"
      break
    elseif input == "2" then
      globalData.config.downloadPath = "https://raw.githubusercontent.com/Pyutaro/CC/master/Xampp/src/"
      break
    elseif input == "3" then
      globalData.config.downloadPath = "https://raw.githubusercontent.com/Pyutaro/CC/working/Xampp/src/"
      break
    elseif input == "4" then
      print("Please input the path carefully!")
      term.write("Base URL: ")
      globalData.config.downloadPath = io.read()
      break
    else
      what()
    end
  end

  print("All set with config!")
  term.write("Saving... ")
  local configFileHandler2 = fs.open("config", "wb")
  configFileHandler2.write(textutils.serialize(globalData.config))
  configFileHandler2.close()
  term.write("OK!\n")
end

function boot ()
  os.setComputerLabel("Bob the " .. os.getComputerID())

  term.clear()
  term.setCursorPos(1,1)
  term.write("Bob is booting")
  for i=1, 3 do
    sleep(0.2)
    term.write(".")
  end
  print("")

  local myFilename = shell.getRunningProgram()
  local selfFileHandler = fs.open(myFilename, "rb")
  local selfData = selfFileHandler.readAll()
  selfFileHandler.close()

  globalData.version = getVersion(selfData)
  print("I found my version to be: " .. globalData.version)
  sleep(0.1)
  print("Time to read my config file...")

  if fs.exists("config") then
    local configFileHandler = fs.open("config", "rb")
    local configData = configFileHandler.readAll()
    configFileHandler.close()

    globalData.config = textutils.unserialize(configData)
    if globalData.config == nil then
      print("I don't think it read correctly... oh well")
      print("Let's make another!")
      createConfigFile()
    else
      print("I read " .. #configData .. " bytes successfully!")
      print("Are you proud?")
    end
  else
    print("No config file? That's odd. Let's make one!")
    createConfigFile()
  end

  print("I'm checking online to see what its version is...")
  if http then
    local urlRes, urlResErr = http.checkURL(globalData.config.downloadPath .. "bob.lua")
    if urlRes == false then
      print("Looks like downloading isn't available...")
      print("Check: " .. tostring(urlResErr))
    else
      local onlineHandler = http.get(globalData.config.downloadPath .. "bob.lua")
      if onlineHandler == nil then
        print("I couldn't connect or I 404'd or something... skipping.")
      else
        local onlineData = onlineHandler.readAll()
        local onlineVersion = getVersion(onlineData)
        if onlineVersion == "0" then
          print("I don't think I found the right file. I couldn't find its version.")
        else
          if onlineVersion ~= globalData.version then
            print("Looks like I have an update! " .. globalData.version .. " -> " .. onlineVersion)
            local newHandler = fs.open(shell.getRunningProgram(), "wb")
            newHandler.write(onlineData)
            newHandler.close()
          else
            print("And we're up to date!")
          end
        end
      end
    end
  else
    print("Woah, hold up! We're not even connected to the internet!")
  end

  shell.run(shell.getRunningProgram(), "run")
end

function split(pString, pPattern)
  local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
     if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
     end
     last_end = e+1
     s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
     cap = pString:sub(last_end)
     table.insert(Table, cap)
  end
  return Table
end

function processInput (str)
  local c = split(str, " ")
  if #c > 0 then
    local cmd = c[1]
    if cmd == "tr" then
      turtle.turnRight()
    elseif cmd == "tl" then
      turtle.turnLeft()
    elseif cmd == "exit" then
      term.clear()
      term.setCursorPos(1,1)
      print("Bye!")
      globalData.running = false
      error()
    else
      globalData.status = "No idea what you want."
      globalData.requireRefresh = true
    end
  end
end

function run ()
  local myFilename = shell.getRunningProgram()
  local selfFileHandler = fs.open(myFilename, "rb")
  local selfData = selfFileHandler.readAll()
  selfFileHandler.close()
  globalData.version = getVersion(selfData)

  local sw, sh = term.getSize()
  local input = ""
  displayStatus()
  term.setCursorPos(1,sh)
  term.write("> ")
  
  while globalData.running do
    term.setCursorBlink(true)
    local event, char = os.pullEvent()
    if event == "char" then
      input = input .. char
      
    elseif event == "key" then
      if char == keys.enter then
        processInput(input)
        if globalData.requireRefresh then
          displayStatus()
          globalData.requireRefresh = false
        end
        input = ""
      elseif char == keys.backspace then
        input = string.sub(input, 1, #input - 1)
      end
    end
    term.setCursorPos(1,sh)
    local sstr = "> " .. input:sub(0-sw+3)
    sstr = sstr .. string.rep(" ",sw-sstr:len())
    term.write(sstr)
  end
end

if #tArgs == 0 then
  boot()
else
  if tArgs[1] == "run" then
    run()
  end
end
