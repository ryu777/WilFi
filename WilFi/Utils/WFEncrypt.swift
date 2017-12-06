//
//  WFEncrypt.swift
//  WilFi
//
// 暗号化／複合化処理
//
//  Created by Tatsuya Uemura on 2017/10/13.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import Security
import CryptoSwift

enum WFEncryptError: Error {
    case EncryptError
    case DecryptError
}

extension String {
    func UTF8toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
//        return data?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) ?? ""
        return data?.base64EncodedString(options:[]) ?? ""
    }
    
    func Base64toUInt8Array() -> [UInt8] {
        let data = NSData.init(base64Encoded: self, options: []) ?? NSData()
        
        let count = data.length / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        print(array)
        return array;
//        return String(data: data as Data, encoding: String.Encoding.utf8) ?? ""
    }
}

class WFEncrypt {
    
    // 暗号化キー (32bytes)
//    private static let WF_ENCRYPT_KEY = "passwordpasswordpasswordpassword"
//    private static let WF_ENCRYPT_KEY = "w_yokoyamak_yagiuemura@fancs.com"
    private static let WF_ENCRYPT_KEY = "Ey4xW81KJQLPLwfNDK1h86MuLrU0zIBP"

    private static let ivt = AES.randomIV(AES.blockSize);
//    private static var ivtbase64: String?
    
    class func getIVbase64String() -> String {
        return NSData(bytes: ivt, length: ivt.count).base64EncodedString(options: [])
    }
    
    class func encrypt(value:String) throws -> String {
        do {

            // aes-256-cbc
            // blockMode: BlockMode = .CBC, padding: Padding = .pkcs7
            
            // Initialization Vector(16)
            // key 32
            
            // IV（初期化ベクトル）、ivの型は[UInt8]
//            let ivt = AES.randomIV(AES.blockSize)
//            let s = NSString(bytes: ivt, length: ivt.count, encoding: String.Encoding.ascii.rawValue)
            
//            let s = NSString(bytes: ivt, length: ivt.count, encoding: String.Encoding.ascii.rawValue)
//            try ivt.encode(to: Encoder.self as! Encoder);
            
//            ivt.encode(to: Encoder.self)
            
//            let s = NSString(bytes: ivt, length: ivt.count, encoding: String.Encoding.ascii.rawValue)
            
//            print(s?.length);
//            let s2 = s! as String
//            print(ivt.count);
//            print(s2.characters.count);
//            print(s2.unicodeScalars.count); // PHP側でおかしいのはここらだな。
//            // PHPで全角が3byteで計算されている？
//            // BOM
//
//            let data: Data = s2.data(using: .utf8)!
//
//            print(data.count)
            
//            NSData.Base64EncodingOptions.lineLength64Characters
            
            // バイト列（[UInt8]）をNSDataに変換し、Base64文字列にエンコード
//            let strIV = NSData(bytes: ivt, length: ivt.count).base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
//            ivtbase64 = NSData(bytes: ivt, length: ivt.count).base64EncodedString(options: [])

//            let strIV = NSData(bytes:ivt).base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//            print("IV: " + ivtbase64!)

//            let ssss = ivtbase64?.Base64toUInt8Array();
//            let string = "Test"
//            let string64 = string.UTF8toBase64() // => "VGVzdA=="
//            let string2 = string64.Base64toUTF8()
            
//            let iv1 = hexStringToUInt8(str: strIV, range: NSMakeRange(0, 16))

            
//            let ivdata: Data = strIV.data(using: .utf8)!
//            let dec = String(data: Data(base64Encoded: ivdata, options: [])!, encoding: .utf8)
//            let array: [UInt8] = Array(dec!.utf8)

            
//            let sendData = NSMutableData(bytes: ivt, length: ivt.count)
//            let sendDataBase64 = sendData.base64EncodedString(options: NSData.Base64EncodingOptions())
//            print(sendDataBase64)
//            print(sendDataBase64.characters.count);
//            print(sendDataBase64.unicodeScalars.count);

//            let ivdata: Data = sendDataBase64.data(using: .utf8)!
//            //        String.Encoding.iso2022JP
//            let dec = String(data: Data(base64Encoded: ivdata, options: [])!, encoding: .utf8)
//            let array: [UInt8] = Array(dec!.utf8)

            
//            let iv1 = hexStringToUInt8(str: sendDataBase64, range: NSMakeRange(0, 32))
            
//            ivtbase64 = data.base64EncodedString(options: [])
            
//            s2.encode(to: Encoder)
//            let data = s2.data(using: String.Encoding(rawValue: NSUTF8StringEncoding.rawValue))
//            let base64Str = data.base64EncodedStringWithOptions(NSData.Base64EncodingOptions.Encoding64CharacterLineLength)
            
//            print(base64Str)
            
//            print("randomIV:\(s!) lenght:\(s!.length) base64:\(ivtbase64!)", separator: " ", terminator: "\n")

            // php側
            // http://yut.hatenablog.com/entry/20120205/1328375985
            
            
            let key = [UInt8](WF_ENCRYPT_KEY.utf8)
//            let iv = [UInt8]("drowssapdrowssap".utf8)
//            let aes = try AES(key: key, iv: iv)
//            NSLog("ivt:\(ivt)")
//
//            NSLog(String(bytes: ivt, encoding: String.Encoding.ascii)!)
//
//            NSLog(NSString(bytes: ivt, length: ivt.count, encoding: String.Encoding.ascii.rawValue)! as String)
            
//            let ivdata: Data = ivt.data(using: .utf8)!
//            let data2 = Data(bytes: ivt)
            //            print(data2);
//            let ivtstr = String(data: data2, encoding: .utf8)
//            NSLog("ivtstr:\(String(describing: ivtstr))")

//            let directResultString = NSString(bytes: ivt, length:
//                ivt.count, encoding: String.Encoding.ascii.rawValue)! as String
//            print(directResultString)
            
//            let decData = NSData(bytes: ivt, length: Int(ivt.count))
//            let base64String = decData.base64EncodedString(options: .lineLength64Characters)
            
//            let aes = try AES(key: WF_ENCRYPT_KEY, iv: directResultString)
            let aes = try AES(key: key, iv: ivt)
//            let aes = try AES(key: key, iv: ssss)
            let ciphertext = try aes.encrypt(Array(value.utf8))
//            print(ciphertext);
//            print(ciphertext.toHexString());
//
//            print("===111===");
//            let r = ciphertext.toBase64(); // これ
//            
////            let base64Str = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!
//            
//            print (r!)
//            print("===222===");
//            
//            let d1 = Data(base64Encoded: r!, options: [])!
//            
//            let y = [UInt8](d1)
            
//            let data1 = NSData(bytes: &d1, length: d1.count)
//            if let decodedString = NSString(data: data1 as Data, encoding: String.Encoding.utf8.rawValue) {
//                print("===decode1 sucess===");
//                print(decodedString)
//                print("===cecode1===");
//            }else{
//                print("===decode1 error ===");
//            }
//
////            let dc = String(data: Data(base64Encoded: r!, options: [])!, encoding: .utf8)
////            print("--dc")
////            print(dc!)
//
//            let decodedData = NSData(base64Encoded: r!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
//            if let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue) {
//                print("===decode sucess===");
//                print(decodedString)
//                print("===cecode===");
//            }else{
//                print("===decode error ===");
//            }
//
//
//            print("111===");
//            let e = try ciphertext.toHexString().encryptToBase64(cipher: aes)
//            print (e!)
//            print("222===");
//
//            let d = try e?.decryptBase64ToString(cipher: aes);
//            print("333===");
//            print (d!)
//            print("444===");

//            print(ciphertext.toBase64());

//            let decrypted = try aes.decrypt(ciphertext)
//            let decrypted = try aes.decrypt(y)
//
//            let data2 = Data(bytes: decrypted)
//            print(data2);
//            let string = String(data: data2, encoding: .utf8)
//            print(string);

//            let aaa = NSData(bytes: ciphertext, length: ciphertext.count).base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
//            print(aaa)
            
            return ciphertext.toBase64()!;
//            XCTAssertEqual(ciphertext.toHexString(), "5105c187e62c6f2c07ce9c0d5966ae01d2221f8a736e89f52dcc7fbf6d32dfd1b5db8b0a4e468dea273678b4be255a50811bfe14b6cf3a3a9116baac77d3bcfc")
        } catch {
            throw WFEncryptError.EncryptError
        }
    }

    class func decrypt(value:String) throws -> String? {
//        print(value)
//        print(value.removingPercentEncoding)
//        print("== decrypt start")
//        let dataLength = value.characters.count
//        let dataRange = NSMakeRange(0, dataLength)
//        let data = hexStringToUInt8(str: value, range: dataRange)
//        print("--");
//        print(data);
//        print("--");
        
        let data = [UInt8](Data(base64Encoded: value, options: [])!)

//        let iv = ivtbase64!.Base64toUInt8Array();
        
//        let ivdata: Data = ivtbase64!.data(using: .utf8)!
////        String.Encoding.iso2022JP
//        let dec = String(data: Data(base64Encoded: ivdata, options: [])!, encoding: .iso2022JP)
//        let array: [UInt8] = Array(dec!.utf8)
//        let byteArray = [UInt8](dec!.utf8)
////        print("base64:\(dec!)", separator: " ", terminator: "\n")
//        print("base64:\(ivtbase64!)", separator: " ", terminator: "\n")
//        print(dec?.characters.count);
//        print(dec?.unicodeScalars.count); // PHP側でおかしいのはここらだな。
//        print(array.count);
        
        do {
            let key = [UInt8](WF_ENCRYPT_KEY.utf8)

//            let aes = try AES(key: "passwordpasswordpasswordpassword", iv: "drowssapdrowssap")
//            let aes = try AES(key: WF_ENCRYPT_KEY, iv: String(bytes: ivt, encoding: .utf8)!)
//            let aes = try AES(key: WF_ENCRYPT_KEY, iv: NSString(bytes: ivt, length: ivt.count, encoding: String.Encoding.ascii.rawValue)! as String)

            let aes = try AES(key: key, iv: ivt)
            let decrypted = try aes.decrypt(data)
            
            let data2 = Data(bytes: decrypted)
//            print(data2);
            let string = String(data: data2, encoding: .utf8)
//            print(string);
            return string;
//
//            let result = convertUInt8ToUTF(bytes: decrypted)
//            return result
        } catch let error as NSError {
            debugPrint(error)
            throw WFEncryptError.DecryptError
//            return ""
        }
        
//        let aes = try AES(key: "passwordpasswordpasswordpassword", iv: "drowssapdrowssap")
//        try aes.decrypt(<#T##bytes: ArraySlice<UInt8>##ArraySlice<UInt8>#>)
//        return "";
    }
    
//    private class func convertUInt8ToUTF(bytes:[UInt8]) -> String {
//        var ret = ""
//        var decoder = UTF8()
//        var generator = bytes.makeIterator()
//        var finished = false
//
//        repeat {
//            let decodingResult = decoder.decode(&generator)
//            switch decodingResult {
//            case .scalarValue(let char):
////            case .Result(let char):
////                ret.appendingFormat("%c", char.value);
//                ret.append(char.escaped(asASCII: true))
//            default:
//                finished = true
//            }
//        } while (!finished)
//
//        return ret
//    }
//
//    private class func hexStringToUInt8(str:String, range:NSRange) -> [UInt8]{
//        let nsstr:NSString = (str as NSString).substring(with: range) as NSString
//        let strLength = String(nsstr).characters.count
//        var result:[UInt8] = []
//
//        stride(from: 0, to: strLength, by: 2).forEach {
////        for var i=0; i<strLength; i += 2 {
//            let r = NSMakeRange($0, 2)
//            let substr = nsstr.substring(with: r)
//            result.append(UInt8(strtoul(substr, nil, 16)))
//        }
//
//        return result
//    }
    
}


