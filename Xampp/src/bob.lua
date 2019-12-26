--v0.1.0
tArgs = { ... }
globalData = {}
globalData.config = {}
globalData.config.downloadPath = "http://localhost/"
globalData.version = "???"

function cPrint (str)
  local sw, sh = term.getSize()
  local cstr = string.rep(" ", math.floor(sw/2 - str:len()/2)) .. str .. string.rep(" ", math.ceil(sw/2 - str:len()/2))
  term.write(cstr .. "\n")
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
  term.write(string.rep("=",sw))
  print(" HDD Space: " .. fs.getFreeSpace("/") .. " bytes free")
  print(" Fuel: " .. fuelFormat())
  term.write(string.rep("=",sw))
end

function getVersion (str)
  local nlPos = string.find(str, "\n")
  if nlPos ~= nil and nlPos ~= -1 then
    return nlPos:sub(3,nlPos-1)
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
    elseif input == "2" then
      globalData.config.downloadPath = "https://raw.githubusercontent.com/Pyutaro/CC/master/Xampp/src/"
    elseif input == "3" then
      globalData.config.downloadPath = "https://raw.githubusercontent.com/Pyutaro/CC/working/Xampp/src/"
    elseif input == "4" then
      print("Please input the path carefully!")
      term.write("Base URL: ")
      globalData.config.downloadPath = io.read()
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

  local myFilename = shell.getRunningProgram()
  local selfFileHandler = fs.open(myFilename, "rb")
  local selfData = selfFileHandler.readAll()
  selfFileHandler.close()

  globalData.version = getVersion(selfData)
  print("I found my version to be: " .. globalData.version)
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
          end
        end
      end
    end
  else
    print("Woah, hold up! We're not even connected to the internet!")
  end

  shell.run(shell.getRunningProgram(), "run")
end

function run ()
  print("Whoops! Not ready yet!")
end

if #tArgs == 0 then
  boot()
else
  if tArgs[1] == "run" then
    run()
  end
end
