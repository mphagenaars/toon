-- LUA modules
json = require('dkjson')

local user = 'xxxxxxxxxx'
local pass = 'xxxxxxxxxx'

local debug = 1

-- UUID
random = math.random
function uuid()
   local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
   return string.gsub(template, '[xy]', function (c)
      local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
      return string.format('%x', v)
   end)
end

-- LOGIN
function login()
   -- step 1: get agreement-details from Toon api
   local d1 = '\"username=' .. user .. '&password=' .. pass .. '\"'
   login = assert(io.popen('curl -X POST -d ' .. d1 .. ' https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/login'))
      local token = login:read('*all')
      login:close()
      jsonLogin, pos, err = json.decode(token, 1, nil)
      if debug == 1 then
         if err then print('err: '..err)
         else print('contents: '..token)
         end
      end
   clientId = tostring(jsonLogin.clientId)
   clientIdChecksum = tostring(jsonLogin.clientIdChecksum)
   agreementId = tostring(jsonLogin.agreements[1].agreementId)
   agreementIdChecksum = tostring(jsonLogin.agreements[1].agreementIdChecksum)
   if debug == 1 and jsonLogin.success == true then print('Eneco Toon - sleutel opgehaald') end
   -- step 2: log on to Toon api
   local uuId = uuid()
   local d2 = '\"clientId='..clientId..'&clientIdChecksum='..clientIdChecksum..'&agreementId='..agreementId..'&agreementIdChecksum='..agreementIdChecksum..'&random='..uuId..'\"'
   if debug == 1 then print('body login: '..d2) end
   auth = assert(io.popen('curl -X POST -d ' .. d2 .. ' https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/auth/start'))
      local check = auth:read('*all')
      auth:close()
      jsonAuth, pos, err = json.decode(check, 1, nil)
      if debug == 1 then
         if err then print('err: '..err)
         else print('auth: '..check)
         end
      end
   --uuId = tostring(jsonAuth.displayUuidKpi.uuid)
   --if debug == 1 then print('uuId: '..uuId) end
   if debug == 1 and jsonAuth.success == true then print('Eneco Toon - ingelogd') end
   return clientId, clientIdChecksum
end

-- LOGOUT
function logout()
   local uuId = uuid()
   local d3 = '\"random='..uuId..'&clientId='..clientId..'&clientIdChecksum='..clientIdChecksum..'\"' 
   if debug == 1 then print('body logout: '..d3) end
   logout = assert(io.popen('curl -X POST -d ' .. d3 .. ' https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/auth/logout'))
      local check = logout:read('*all')
      logout:close()
      jsonLogout, pos, err = json.decode(check, 1, nil)
      if debug == 1 then
         if err then print('err: '..err)
         else print('logout: '..check)
         end
         if jsonLogout.success == true then print('Eneco Toon - uitgelogd') end
      end
end

-- GETSTATE
function getState()
   if debug == 1 then print('start getState') end
   local uuId = uuid()
   local d4 = '\"random='..uuId..'&clientId='..clientId..'&clientIdChecksum='..clientIdChecksum..'&agreementId='..agreementId..'&agreementIdChecksum='..agreementIdChecksum..'\"'  
   local H = '\"Content-Type: application/x-www-form-urlencoded\"' 
   if debug == 1 then print('body getState: '..d4) end
   getState = assert(io.popen('curl -X GET -H '..H..' -d '..d4..' https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/auth/retrieveToonState'))
   local state = getState:read('*all')
   print('getstate: '..state)
      getState:close()
end

commandArray = {}
if devicechanged['testSwitch'] then
   local test1 = login()
   local test2 = getState()
   local test3 = logout()
end
return commandArray
