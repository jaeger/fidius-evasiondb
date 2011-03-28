module FIDIUS::EvasionDB::Knowledge
  class Packet < FIDIUS::EvasionDB::Knowledge::Connection
    belongs_to :attack_module
    belongs_to :attack_payload

    def self.table_name
      "packets"
    end

    def payload
      return [] if self[:payload] == nil
      self[:payload]
    end

  end
end
