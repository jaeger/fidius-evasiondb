class Payload < EvasionDbConnection
  belongs_to :exploit
  has_many :packets
  has_many :idmef_events

  def self.table_name
    "payloads"
  end
end
