import Foundation
import Alamofire

class PostFileToServer {
    var app21: App21? = nil
    
    func execute(result: Result) -> Void {
        do {
            let decoder = JSONDecoder()
            let pinfo = try decoder.decode(PostInfo.self, from: result.params!.data(using: .utf8)!)
            
            let url = pinfo.server ?? "" /* your API url */
            
            let headers: HTTPHeaders = [
                /* "Authorization": "your_access_token",  in case you need authorization header */
                "Content-type": "multipart/form-data"
                //"Bearer": pinfo.token ?? ""
            ]
            
            print("GOGO")
            
            let down = DownloadFileTask()
            let fn = down.getName(path: pinfo.path!)
            let data = down.localToData(filePath: pinfo.path!)
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data,
                    withName: String(pinfo.path!.split(separator: ".").last ?? "file"),
                    fileName: fn,
                    mimeType: "file/*")
            }, to: url, headers: headers)
            .uploadProgress { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            }
            .responseString { response in
                switch response.result {
                case .success(let value):
                    print("SUCCESS")
                    result.success = true
                    result.data = JSON(value)
                    self.app21?.App21Result(result: result)
                    
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    result.success = false
                    result.error = error.localizedDescription
                    self.app21?.App21Result(result: result)
                }
            }
            
        } catch {
            print("Error decoding PostInfo: \(error)")
            result.success = false
            result.error = error.localizedDescription
            self.app21?.App21Result(result: result)
        }
    }
}

class PostInfo: Codable {
    var server: String?
    var path: String?
    var token: String?
}
