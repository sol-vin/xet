struct ::XET::SessionID
  def self.from_json(pull : JSON::PullParser)
    session_id_string = pull.read_string
    session_id = 0
    if session_id_string.size == 10
      session_id = session_id_string[2..9].to_u32(16)
    else
      raise "Parsing error!"
    end
    ::XET::SessionID.new(session_id) 
  end

  def self.to_json(value : ::XET::SessionID, build : JSON::Builder)
    build.string("0x#{value.id.to_s(16).upcase.rjust(8, '0')}")
  end

  property id : UInt32 = 0_u32

  def initialize(pull : JSON::PullParser)
    session_id_string = pull.read_string
    @id = 0
    if session_id_string.size == 10
      @id = session_id_string[2..9].to_u32(16)
    else
      raise "Parsing error!"
    end
  end

  def initialize(@id : UInt32)
  end

  def to_json(build : JSON::Builder)
    ::XET::SessionID.to_json(self, build)
  end
end