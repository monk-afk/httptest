  --==[[  HTTPTest  0.0.2  ]]==--
  --==[[ DialoGPT/hugfaces ]]==--
  --==[[ MIT (c) 2024 monk ]]==--
local http = minetest.request_http_api()
local api_key = "hf_your_private_key"
-- local inference_url = "https://api-inference.huggingface.co/models/microsoft/DialoGPT-large"
local inference_url = "https://api-inference.huggingface.co/models/distilbert/distilbert-base-uncased-finetuned-sst-2-english"
--[[ Neither of these are "free" as they claim, the endpoint answers always with overusage error even on new keys. ]]
--[[ https://api.openai.com/v1/chat/completions also not free, so I'm dumping this until I decide it's worth the money ]]
      -- https://platform.openai.com/docs/api-reference/moderations/create
if not http then
  return minetest.log("error", "[HTTPTest] HTTP api inaccessible. Please check your minetest.conf")
end

local function post_json(user_input)
  return minetest.write_json({
    data = {
      inputs = {
        text = user_input,
        -- generated_responses = {}, -- for DialoGTP
        -- past_user_inpputs = {}, -- also DialoGTP
      }
    }
  })
end

local function call_gpt(name, param)
  local user_input = string.match(param, "^ *(.+)$") or ""
  local form = "formspec_version[2]"
    .."size[15,11]".."no_prepend[]"
    .."bgcolor[#1F1F1FFF;both]"

  http.fetch({
    url = inference_url,
    type = "application/json",
    method = "POST",
    headers = {
        "Content-Type: application/json",
        "Authorization: Bearer "..api_key,
      },
    post_data = post_json(user_input),

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

minetest.register_chatcommand("gpt", {
  description = "GPTTest",
  params = "<variable argument>",
  privs = {server = true},
  func = function(name, param)
    return call_gpt(name, param)
  end
})


-- minetest.parse_json(string[, nullvalue]): returns something

-- Convert a string containing JSON data into the Lua equivalent
-- nullvalue: returned in place of the JSON null; defaults to nil
-- On success returns a table, a string, a number, a boolean or nullvalue
-- On failure outputs an error message and returns nil
-- Example: parse_json("[10, {\"a\":false}]"), returns {10, {a = false}}


-- minetest.write_json(data[, styled]): returns a string or nil and an error message.

-- Convert a Lua table into a JSON string
-- styled: Outputs in a human-readable format if this is set, defaults to false.
-- Unserializable things like functions and userdata will cause an error.
-- Warning: JSON is more strict than the Lua table format.
-- You can only use strings and positive integers of at least one as keys.
-- You cannot mix string and integer keys. This is due to the fact that JSON has two distinct array and object values.
-- Example: write_json({10, {a = false}}), returns '[10, {"a": false}]'


-- When sending your request, you should send a JSON encoded payload. Here are all the options

-- All parameters	
-- inputs (required)	
--   text (required)	The last input from the user in the conversation.
--   generated_responses()	A list of strings corresponding to the earlier replies from the model.
--   past_user_inputs()	A list of strings corresponding to the earlier replies from the user. Should be of the same length of generated_responses.
-- parameters()	a dict containing the following keys:
--   min_length	(Default: None). Integer to define the minimum length in tokens of the output summary.
--   max_length	(Default: None). Integer to define the maximum length in tokens of the output summary.
--   top_k	(Default: None). Integer to define the top tokens considered within the sample operation to create new text.
--   top_p	(Default: None). Float to define the tokens that are within the sample operation of text generation. Add tokens in the sample for more probable to least probable until the sum of the probabilities is greater than top_p.
--   temperature	(Default: 1.0). Float (0.0-100.0). The temperature of the sampling operation. 1 means regular sampling, 0 means always take the highest score, 100.0 is getting closer to uniform probability.
--   repetition_penalty	(Default: None). Float (0.0-100.0). The more a token is used within generation the more it is penalized to not be picked in successive generation passes.
--   max_time	(Default: None). Float (0-120.0). The amount of time in seconds that the query should take maximum. Network can cause some overhead so it will be a soft limit.
-- options	a dict containing the following keys:
--   use_cache	(Default: true). Boolean. There is a cache layer on the inference API to speedup requests we have already seen. Most models can use those results as is as models are deterministic (meaning the results will be the same anyway). However if you use a non deterministic model, you can set this parameter to prevent the caching mechanism from being used resulting in a real new query.
--   wait_for_model	(Default: false) Boolean. If the model is not ready, wait for it instead of receiving 503. It limits the number of requests required to get your inference done. It is advised to only set this flag to true after receiving a 503 error as it will limit hanging in your application to known places.
--   Return value is either a dict or a list of dicts if you sent a list of inputs

-- Returned values	
-- generated_text	The answer of the bot
-- conversation	A facility dictionnary to send back for the next input (with the new user input addition).
-- past_user_inputs	List of strings. The last inputs from the user in the conversation, after the model has run.
-- generated_responses	List of strings. The last outputs from the model in the conversation, after the model has run.
