class XET::Message
  include JSON::Serializable
  
  @[JSON::Field(ignore: true)]
  property type : UInt8
  @[JSON::Field(ignore: true)]
  property version : UInt8
  @[JSON::Field(ignore: true)]
  property reserved1 : UInt8
  @[JSON::Field(ignore: true)]
  property reserved2 : UInt8
  @[JSON::Field(ignore: true)]
  property session_id : UInt32
  @[JSON::Field(ignore: true)]
  property sequence : UInt32
  @[JSON::Field(ignore: true)]
  property total_packets : UInt8
  @[JSON::Field(ignore: true)]
  property current_packet : UInt8
  @[JSON::Field(ignore: true)]
  property id : UInt16
  @[JSON::Field(ignore: true)]
  property size : UInt32
  @[JSON::Field(ignore: true)]
  property message : String
  
  @[JSON::Field(ignore: true)]
  property? use_custom_size : Bool = false


  def self.from_s(string) : XET::Message
    io = IO::Memory.new string
    m = XET::Message.new
    m.type = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.version = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.reserved1 = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.reserved2 = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.session_id = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.sequence = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.total_packets = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.current_packet = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.id = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    m.size = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.message = io.gets("\n", 32600).to_s
    if m.size != m.actual_size
      m.use_custom_size = true
    end
    m
  end

  def initialize(@type = 0xff_u8, @version = 0x01_u8, @reserved1 = 0x00_u8, @reserved2 = 0x00_u8, @session_id = 0_u32, @sequence = 0_u32, @total_packets = 0_u8, @current_packet = 0_u8, @id = 0_u16, @size = 0_u32, @message = "")
  end
  
  # The message should have a \x00 byte at the end, so size counts will be off by one
  def actual_size
    message.size + 1
  end

  def id1 : UInt8
    (id & 0xFF).to_u8
  end

  def id2 : UInt8
    (id >> 8).to_u8
  end

  def header
    header_io = IO::Memory.new
    header_io.write_bytes(type, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(version, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(reserved1, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(reserved2, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(session_id, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(sequence, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(total_packets, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(current_packet, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(id, IO::ByteFormat::LittleEndian)
    if use_custom_size?
      header_io.write_bytes(size, IO::ByteFormat::LittleEndian)
    else
      header_io.write_bytes(message.size, IO::ByteFormat::LittleEndian)
    end

    header_io.to_s
  end

  def to_s(io)
    io << header
    io << self.message
  end

  def to_msg : XET::Message
    x = XET::Message.new
    x.type = type
    x.version = version
    x.reserved1 = reserved1
    x.reserved2 = reserved2
    x.session_id = session_id
    x.sequence = sequence
    x.total_packets = total_packets
    x.current_packet = current_packet
    x.id = id
    x.size = size
    x.message = message

    x.use_custom_size = use_custom_size?
    x
  end
end