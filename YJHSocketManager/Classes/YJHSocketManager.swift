//
//  YJHSocketManager.swift
//  YJHSocketManager
//
//  Created by 尹建华 on 2023/3/30.
//

import UIKit
import RxSwift
import RxCocoa
import SwifterSwift
import CommonCrypto

// event事件
public enum TZYKSocketTopicEvent: String, Decodable {
    case auth1 = "auth1"  // 消息推送
    case wd_chat = "wd_chat"
    case wd_heartbeat = "wd_heartbeat"
    case wd_room = "wd_room"
    case none = ""
}

public protocol TZYKSocketProtocol {
    var cmd: String? { get set}
}

public protocol Convertable: Codable {
    
}

// MQTT 基础model
public struct TZYKSocketEmptyResponseModel:Decodable{
    
}

public struct TZYKSocketMessageResponseModel:Decodable{
    public var message: TZYKSocketMsgTypeResponseModel?
}

public struct TZYKSocketMsgTypeResponseModel:Decodable{
    public var msgType: Int?
}

// MQTT 基础model
struct TZYKSocketInstitutionResponseModel<T: Decodable>: Decodable,TZYKSocketProtocol {
    public var msg_id: Int?
    public var cmd: String?
}

public struct TZYKSocketSeedModel: Convertable {
     public var seed: String?
}

public struct TZYKSocketIMResultModel: Convertable {
    public var message: TZYKSocketIMMessageModel?
    public var user: TZYKSocketIMUserModel?
    
    public init() {}
    
}

public struct TZYKSocketIMMessageModel: Convertable {
    public var isTeacher: Int?
    public var msgType: Int?
    public var teacherIdentity: Int?
    public var content: String?
    public var contents: String?
    public var nickname: String?
    public var id: Int?
    public var roomId: Int?
    public var stockIdentifyList: [TZYKSocketIMStockIdentifyList]?
    public var sendJdsUserId: String?
    public init() {}
}

public struct TZYKSocketIMStockIdentifyList: Convertable {
    public var stockCode: String?
    public var stockId: String?
    public var stockMarket: String?
    public var stockName: String?
}

public struct TZYKSocketIMUserModel: Convertable {
    public var uid: Int?
    public var icon: String?
    public var nickname: String?
    public var jdsUserId: String?
    public init() {}
}

public struct TZYKSocketAuthorityResModel: TZYKSocketProtocol, Convertable {
    public var msg_id: Int?
    public var cmd: String?
    public var userId: String?
    public var room_id: String?
    public var authCode: String?
}

// MQTT 全量model
public class TZYKSocketBaseResModel<T: Decodable>: Decodable {
    public var result: (Decodable)?
    public var cmd: String?
    
    enum Keys: String, CodingKey {
        case result
        case cmd
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        cmd = try container.decode(String.self, forKey: .cmd)
        let eventValue: TZYKSocketTopicEvent = TZYKSocketTopicEvent(rawValue: cmd ?? "") ?? .none
        switch eventValue {
        case .auth1:
            result = try? container.decode(TZYKSocketSeedModel.self, forKey: .result)
        case .wd_heartbeat:
            result = try? container.decode(TZYKSocketEmptyResponseModel.self, forKey: .result)
        case .wd_chat:
            result = try? container.decode(T.self, forKey: .result)
        default:
            result = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError("未实现")
    }
}


open class YJHSocketManager: NSObject {

    public static let shared = YJHSocketManager()
    public override init() {
        super.init()
        setupSocket()
    }
    private let bag = DisposeBag()
    private var auth = TZYKSocketAuthorityResModel()
    
    lazy var socket = YJHScoketTool.sharedInstance()

    public func setupSocket() {
        socket.beatData = ["cmd":"wd_heartbeat"].jsonData()!
    }

    public func connect() {
        let domain = ""
        var ifDebug = true
        let host = ifDebug ? "test-im.\(domain)" : "im.\(domain)"
        socket.connect(toHost: host, port: 9527, timeOut: 3)
    }

    public func isConnect() -> Bool {
        return socket.isDisConnect ?? false
    }
    
    public func disConnect() {
        socket.disconnect()
        postNotification(true)
    }

    public func sendBeat() {
        socket.heartBeatFlag = true
        socket.socketBeginSendBeat()
    }

    // 鉴权
    public func verifyAuthority(model:TZYKSocketAuthorityResModel?) {
        if let data = try? JSONEncoder().encode(model) {
            socket.socketWriteData(toServer: data)
        }
        postNotification(false)
    }

    public func subscirbeData<T: Decodable>(roomId: String) -> Observable<(T)> {
        
        if !isConnect() {
            connect()
        }
        
        return Observable.create { (ob) -> Disposable in
            self.socket.scoketGetDataBlock = { [weak self] (socket,data,type) in
                do {
                    let res = try JSONDecoder().decode(TZYKSocketBaseResModel<T>.self,from: data)
                    let eventValue: TZYKSocketTopicEvent = TZYKSocketTopicEvent(rawValue: res.cmd ?? "") ?? .none
                    switch eventValue {
                    case .auth1:
                        var oldModel = res.result as? TZYKSocketSeedModel
                        var model = TZYKSocketAuthorityResModel()
                        let token = "6PIRqVw3cRm84dKVgPlp"
                        let seed = oldModel?.seed ?? ""
                
                        let auth = "\(seed)\(token)".sm_MD5()
                        model.room_id = roomId
                        model.authCode = auth
                        model.cmd = "auth2"
                        model.msg_id = 1
                        model.userId = ""
                        self?.auth = model
                        self?.verifyAuthority(model: model)
                        self?.sendBeat()
                    case .wd_chat:
                        if let model = res.result as? T {
                          ob.onNext(model)
                        }
                    case .wd_heartbeat:
                        break
                    case .wd_room:
                        break
                    case .none:
                        break
                    }
                    
                } catch {
                    
                }
            }
            
            return Disposables.create()
        }
        
    }
    
    public func postNotification(_ isDisconnect: Bool) {
        var dict = [String:String]()
        dict["userId"] = auth.userId ?? ""
        dict["room_id"] = auth.room_id ?? ""
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: isDisconnect ? "kJCSocketBusinessDisconnectNotification" : "kJCSocketBusinessStartAuthNotification"), object: nil, userInfo: dict)
    }
    
}


fileprivate extension String {
    func sm_MD5() -> String {
        
        let str       = cString(using: String.Encoding.utf8)
        let strLen    = CUnsignedInt(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result    = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str ?? [], strLen, result)
        let hash      = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: count)
        
        return String(format: hash as String)
    }
}
