-- /var/www/html/

require "string"
function handle(r)
  r.content_type = "text/plain"
  if r.method == 'GET' then
    r:puts('return{',
      'Date = "'..os.date("%x %X",r:clock())..'",',
      'Host = "'..r.server_name..' '..r.banner..'",',
      'Received = "'..r.protocol..' '..r.content_type..'",',
      'ReplyTo = "'..r:headers_in_table().Name..'@'..r.useragent_ip..':'..r.port..'",',
      'UserAgent = "'..r:headers_in_table()["User-Agent"]..'",',
      'UserData = "'..r:headers_in_table().Userdata:gsub("\"","\\\"")..'"}'
    )
    return apache2.OK
  end
end

   -- Browser and Minetest compatible, data field unformatted.
--[[
  function handle(r)
    r.content_type = "text/html"
    if r.method == 'GET' then
      for i, n in pairs(r:headers_in_table()) do
        r:puts(i.."-> ".. n.."\n")
      end
    end
    r:puts("Hi Minetest, from Apache2")
    return apache2.OK
  end
]]