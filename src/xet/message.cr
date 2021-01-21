require "json"

class XET::Message
  module Defaults
    TYPE          = 0xff_u8
    VERSION       = 0x00_u8
    RESERVED1     = 0x00_u8
    RESERVED2     = 0x00_u8
    SESSION_ID    =   0_u32
    SEQUENCE      =   0_u32
    TOTAL_PACKETS =    0_u8
    CURRENT_PACKET = 0_u8
    ID = 0_u16
    SIZE = 0_u32
  end

  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  # The type byte of the message, usually `0xFF`
  property type : UInt8

  @[JSON::Field(ignore: true)]
  # The version byte of the message, usually `0x01`
  property version : UInt8

  @[JSON::Field(ignore: true)]
  # A unused/unknown field
  property reserved1 : UInt8

  @[JSON::Field(ignore: true)]
  # A unused/unknown field
  property reserved2 : UInt8

  @[JSON::Field(ignore: true)]
  # The session id of the message. Not sure if this actually does anything
  property session_id : UInt32

  @[JSON::Field(ignore: true)]
  # The number the packet is in line
  property sequence : UInt32

  @[JSON::Field(ignore: true)]
  # How many packets total are being sent
  property total_packets : UInt8

  @[JSON::Field(ignore: true)]
  # What packet in line we are
  property current_packet : UInt8

  @[JSON::Field(ignore: true)]
  # The command id which controls which actions are run
  property id : UInt16

  @[JSON::Field(ignore: true)]
  # The size of the message. WARNING: SETTING THIS TO 0x80000000 CAUSES CRASHES
  property size : UInt32

  @[JSON::Field(ignore: true)]
  # The message
  property message : String

  @[JSON::Field(ignore: true)]
  # If we should computer size automatically, or if we should set the variable manually.
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

  def initialize(@type = Defaults::TYPE,
                 @version = Defaults::VERSION,
                 @reserved1 = Defaults::RESERVED1,
                 @reserved2 = Defaults::RESERVED2,
                 @session_id = Defaults::SESSION_ID,
                 @sequence = Defaults::SEQUENCE,
                 @total_packets = Defaults::TOTAL_PACKETS,
                 @current_packet = Defaults::CURRENT_PACKET,
                 @id = Defaults::ID,
                 @size = Defaults::SIZE,
                 @message = "")
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
