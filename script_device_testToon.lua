-- LUA modules
json = require('dkjson')

local user = 'xxxxxxxxxx'
local pass = 'xxxxxxxxxx'

local debug = 1

-- UUID
function uuid()
   tmp = assert(io.popen('curl GET https://www.uuidgenerator.net/api/version4'))
   uuid4 = tostring(tmp:read('*all'))
   tmp:close()
   if debug == 1 then 
      print('uuid: '..uuid4)
   end
   return uuid4
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
   local tmp1 = uuid()
   if debug == 1 then print('login - uuid: '..tostring(uuid4)) end
   local d2 = '\"clientId='..clientId..'&clientIdChecksum='..clientIdChecksum..'&agreementId='..agreementId..'&agreementIdChecksum='..agreementIdChecksum..'&random='..uuid4..'\"'
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
   local tmp2 = uuid()
   if debug == 1 then print('logout - uuid: '..uuid4) end
   local d3 = '\"random='..uuid4..'&clientId='..clientId..'&clientIdChecksum='..clientIdChecksum..'\"' 
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
   local tmp3 = uuid()
   --if debug == 1 then print('getstate - uuid: '..uuid4) end
   local d4 = '\"random='..uuid4..'&clientId='..clientId..'&clientIdChecksum='..clientIdChecksum..'\"'  
   if debug == 1 then print('body getState: '..d4) end
   getState = assert(io.popen('curl -X GET -d '..d4..' https://toonopafstand.eneco.nl/toonMobileBackendWeb/client/auth/retrieveToonState'))
   local state = getState:read('*all')
   print('getstate: '..state)
      getState:close()
      jsonState, pos, err = json.decode(state, 1, nil)
	   if jsonState.success == false then print("Did not retreive Toon state") end
end

commandArray = {}
if devicechanged['testSwitch'] then
   local test1 = login()
   local test2 = getState()
   local test3 = logout()
   --local test = uuid()
end
return commandArray
