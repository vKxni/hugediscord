require "yaml"

module Gembot
  class Config
    # The Discord API token
    @token = ""
    property token
    # and the Client ID
    @client_id = 0_u64
    property client_id

    # Map in properties from config.yml
    YAML.mapping(
      prefix: String,
      debug: Bool,
    )
  end
end
