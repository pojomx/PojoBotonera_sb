//
//  Chat.swift
//  PojoBotonera_sb
//
//  Created by Alan Milke on 25/06/22.
//

import Foundation

struct Message {
    let message, username: String
    let mesasgeSender: MessageSender
}

enum MessageSender {
    case ourself
    case someoneElse
    case system
}

protocol ChatRoomDelegate: AnyObject {
  func received(message: Message)
}

class ChatRoom: NSObject {
  //1
  var inputStream: InputStream!
  var outputStream: OutputStream!

  //2
  var username = ""

  //3
  let maxReadLength = 4096
    
    weak var delegate: ChatRoomDelegate?

    func setupNetworkCommunication(host: String, port: UInt32) {
        // 1
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        delegate?.received(message: Message(message: "Configurando", username: "SYS", mesasgeSender: .system))
        
        // 2
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                         host as CFString,
                                         port,
                                         &readStream,
                                         &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)

        delegate?.received(message: Message(message: "Conectando", username: "SYS", mesasgeSender: .system))

        inputStream.open()
        outputStream.open()

    }
}

extension ChatRoom: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        delegate?.received(message: Message(message: "Evento \(eventCode)", username: "SYS", mesasgeSender: .system))

        
        switch eventCode {
        case .hasBytesAvailable:
          print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
          print("new message received")
        case .errorOccurred:
          print("error occurred")
        case .hasSpaceAvailable:
          print("has space available")
        default:
          print("some other event...")
        }
    }

    private func readAvailableBytes(stream: InputStream) {
      //1
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

      //2
      while stream.hasBytesAvailable {
        //3
        let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

        //4
        if numberOfBytesRead < 0, let error = stream.streamError {
          print(error)
          break
        }

        // Construct the Message object
          if let message =
              processedMessageString(buffer: buffer, length: numberOfBytesRead) {
            // Notify interested parties
              delegate?.received(message: message)
          }

      }
    }
    
    
    private func writeWhateverWeHave(stream: OutputStream) {
        
    }
    
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Message? {
      //1
      guard
        let stringArray = String(
          bytesNoCopy: buffer,
          length: length,
          encoding: .utf8,
          freeWhenDone: true)?.components(separatedBy: ":"),
        let name = stringArray.first,
        let message = stringArray.last
        else {
          return nil
      }
      //2
      let messageSender: MessageSender =
        (name == self.username) ? .ourself : .someoneElse
      //3
        return Message(message: message, username: name, mesasgeSender: messageSender)
    }
    
    func send(message: String) {
        let data = "\(message)\r\n".data(using: .utf8)!
        let space = "\0".data(using: .utf8)!
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
              print("Error joining chat")
              return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
        
        space.withUnsafeBytes {
            guard let pinter = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return
            }
            outputStream.write(pinter, maxLength: space.count)
        }
    }
    
    func stopChatSession() {
      inputStream.close()
      outputStream.close()
    }

}
