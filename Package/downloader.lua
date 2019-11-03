--[[
  Module: CONFIG
  Used to hold configuration values.
]]
local CONFIG = {}
CONFIG.GIT_BASE_URL = "https://raw.githubusercontent.com"
CONFIG.GIT_USERNAME = "Pyutaro"
CONFIG.GIT_REPO = "CC"
CONFIG.GIT_BRANCH = "master"
CONFIG.GIT_FORMAT = "%s/%s/%s/%s/%s" -- Base/User/Repo/Branch/File

--[[
  Method: CONFIG.GetGitURL
  Constructs a URL based on the configuration.
    
  Arguments:
    (string) file

  Returns: (URL) url
]]
function CONFIG.GetGitURL (file)
  return CONFIG.GIT_FORMAT:format(
    CONFIG.GIT_BASE_URL,
    CONFIG.GIT_USERNAME,
    CONFIG.GIT_REPO,
    CONFIG.GIT_BRANCH,
    file
  )
end

--[[
  Module: CONST
  Used for constants.  
]]
local CONST = {}
-- ConfigExceptions
CONST.ERR_CONF = "ConfigException: %s"
CONST.ERR_CONF_HTTP_LIB = CONST.ERR_CONF:format("Could not access the HTTP library.")
CONST.ERR_CONF_HTTP_WHITELIST = CONST.ERR_CONF:format("URL is not in the whitelist.")
-- HTTPExceptions
CONST.ERR_HTTP = "HTTPException: %s"
CONST.ERR_HTTP_NO_RESP = CONST.ERR_HTTP:format("Could not connect to the remote host.")
-- IOExceptions
CONST.ERR_IO = "IOException: %s"
CONST.ERR_IO_FAIL = CONST.ERR_IO:format("Could not open the specified path: %s")

--[[
  Class: Downloader
  Handles downloading packages made by Pyutaro 
]]
local Downloader = {}

--[[
  Method: Downloader.DownloadFile
  Downloads a file and saves it to a path.
    
  Arguments:
    (URL) url
    (string) path

  Throws: 
    ConfigException - HTTP is disabled.
    ConfigException - URL is not within the whitelist.
    BadURLException - http or https was missing from the URL.
    BadURLException - URL was malformed.
    HTTPException - Error reaching host. DNS resolve failed or connection timeout.
    IOException - Could not open path specified.
]]
function Downloader.DownloadFile (url, path)
  -- Make sure CC is configured for HTTP.
  if (http == nil) then
    error(CONST.ERR_CONF_HTTP_LIB)
  end

  -- Make sure the URL isn't going to fail because of whitelist issues.
  local httpAllowed = http.checkUrl(url)
  if (httpAllowed == false) then
    error(CONST.ERR_CONF_HTTP_WHITELIST)
  end

  -- Get the file.
  local httpResp = http.get(url)
  if (httpResp == nil) then
    error(CONST.)
  end

  local respData = httpResp.readAll()
  -- <- was working here: to-do write to file.
end