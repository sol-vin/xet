abstract class XET::Error < ::Exception
  abstract class Socket < XET::Error
    class ConnectionRefused < Socket
    end 

    class NoRoute < Socket
    end

    class BrokenPipe < Socket
    end
      
    class ConnectionReset < Socket
    end
  end

  abstract class Login < XET::Error
    class Timeout < Login
    end
  
    class EOF < Login
    end
  
    class Failure < Login
    end
  
    class ConnectionRefused < Login
    end

    class NoRoute < Login
    end
  
    class BrokenPipe < Login
    end
  
    class ConnectionReset < Login
    end
  
    class BadFileDescriptor < Login
    end
  end

  abstract class Send < XET::Error
    class Timeout < Send
    end
  
    class EOF < Send
    end
  
    class ConnectionRefused < Send
    end 
  
    class NoRoute < Send
    end
  
    class BrokenPipe < Send
    end
      
    class ConnectionReset < Send
    end
  
    class BadFileDescriptor < Send
    end
  end

  abstract class Receive < XET::Error
    class Timeout < Receive
    end

    class EOF < Receive
    end

    class ConnectionRefused < Receive
    end 

    class NoRoute < Receive
    end

    class BrokenPipe < Receive
    end

    class ConnectionReset < Receive
    end

    class BadFileDescriptor < Receive
    end
  end

  abstract class Command < XET::Error
    class CannotParse < Command
    end
  end
end