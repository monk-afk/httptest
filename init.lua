  --==[[  HTTPTest  0.0.1  ]]==--
  --==[[ MIT (c) 2024 monk ]]==--
local http = minetest.request_http_api()

if not http then
  return minetest.log("error", "[HTTPTest] HTTP api inaccessible. Please check your minetest.conf")
end

local apache2_url = minetest.settings:get("apache2_url") or "http://127.0.0.1:80/index.lua"

local function call_apache(name, param)
  local input = string.match(param, "^ *(.+)$")
  local form = "formspec_version[2]"
    .."size[15,11]".."no_prepend[]"
    .."bgcolor[#1F1F1FFF;both]"

  http.fetch({
    url = apache2_url,
    timeout = 5,
    method = "GET",
    data = "this is a data string",
    extra_headers = {
      "Content-Type: text/plain",
      "Name: "..name,
      "Userdata: "..input
    }
  }, function(response)
        local response_data = {}
        local deserialized_data_field = minetest.deserialize(response.data)
        if type(deserialized_data_field) == "table" then
          for userdata_header, userdata_field in pairs(deserialized_data_field) do
            response_data[#response_data+1] = "<style color=#f30023 font=mono size=12px>"..userdata_header.."</style>\n"
            response_data[#response_data+1] = "<style color=#0b9ad8 font=mono size=10px>"..tostring(userdata_field).."</style>\n"
          end
          response.data = nil
        end
        for header_field, field_content in pairs(response) do
          response_data[#response_data+1] = "<style color=#f30023 font=mono size=12px>"..header_field.."</style>\n"
          response_data[#response_data+1] = "<style color=#0b9ad8 font=mono size=10px>"..tostring(field_content).."</style>\n"
        end
        form = form.."hypertext[0,0;15,11;;<b><mono>"..table.concat(response_data).."</mono></b>" .. "]"
      return minetest.show_formspec(name, "httptest:response", form)
    end
  )
end

minetest.register_chatcommand("apache", {
  description = "Send and receive an HTTP request to apache",
  params = "<variable argument>",
  privs = {server = true},
  func = function(name, param)
    return call_apache(name, param)
  end
})
