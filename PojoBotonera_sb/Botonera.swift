//
//  Botonera.swift
//  PojoBotonera_sb
//
//  Created by Alan Milke on 26/06/22.
//

import Foundation
import Network

class Botonera {
    
    private let socket: NWConnection
    private let queue = DispatchQueue.global(qos: .userInitiated)
    
    init(){
        
        let options = NWProtocolTCP.Options()
        options.enableFastOpen = true
        options.enableKeepalive = true
        options.connectionTimeout = 5
        options.noDelay = true
        
        let parames = NWParameters(tls: nil, tcp: options)
        if let isOption = parames.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
            isOption.version = .v4
        }
        parames.preferNoProxies = true
        parames.expiredDNSBehavior = .allow
        parames.multipathServiceType = .interactive
        parames.serviceClass = .responsiveData
        
        socket = NWConnection(host: NWEndpoint.Host("192.168.1.151"), port: NWEndpoint.Port(5656), using: parames)
        socket.start(queue: queue)
        
        socket.stateUpdateHandler = { connectionState in
            print(connectionState)
            switch connectionState {
            case .setup:
                break
            case .waiting(let s):
                print("waiting: \(s)")
                break
            case .preparing:
                break
            case .ready:
                print("ready")
            case .failed(_):
                break
            case .cancelled:
                break
            @unknown default:
                break
            }
            
        }
        
    }
    
    public func sendMessage(message: String) {
        let data = "\(message)\r\n".data(using: .utf8)
        
        print("enviando: \(message)")
        
        let context = NWConnection.ContentContext (
            identifier: Date.now.ISO8601Format(),
            expiration: 1,
            priority: 1.0,
            isFinal: false,
            antecedent: nil,
            metadata: nil
        )
        
        socket.send(content: data, contentContext: context, isComplete: false, completion: .contentProcessed({ error in
            
            if error == nil {
                print("enviado.")
            } else {
                print("error: \(error)")
            }
            
        }))
        
        return
    }
    
    private func ready(message: String) {
        
       
    }
}
