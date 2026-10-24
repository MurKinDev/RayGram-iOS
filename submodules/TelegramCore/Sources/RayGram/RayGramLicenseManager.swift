import Foundation

public final class RayGramLicenseManager {
    public static let shared = RayGramLicenseManager()
    
    public static var defaultApiUrl: String {
        if let custom = UserDefaults.standard.string(forKey: "RayGram_custom_api_url"), !custom.isEmpty {
            return custom
        }
        return "http://127.0.0.1:3000"
    }
    
    public static var deviceId: String {
        let key = "RayGram_persistent_device_id"
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
    
    private var timer: Timer?
    private var lastAccountIds: [Int64] = []
    
    private init() {}
    
    public func startPeriodicCheck(accountIds: [Int64]) {
        self.lastAccountIds = accountIds
        self.checkAccess(accountIds: accountIds) { _, _ in }
        
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1200.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.checkAccess(accountIds: self.lastAccountIds) { _, _ in }
            }
        }
    }
    
    public func updateActiveAccounts(_ accountIds: [Int64]) {
        self.lastAccountIds = accountIds
        self.checkAccess(accountIds: accountIds) { _, _ in }
    }
    
    public func checkAccess(accountIds: [Int64], completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(RayGramLicenseManager.defaultApiUrl)/api/check-access") else {
            completion(RayGramSettings.hasFullAccess, "Неверный URL сервера")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0
        
        let stringIds = accountIds.map { String($0) }
        let body: [String: Any] = [
            "device_id": RayGramLicenseManager.deviceId,
            "account_ids": stringIds,
            "app_version": "13.0 (35333)"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(RayGramSettings.hasFullAccess, "Ошибка формирования запроса")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                let currentAccess = RayGramSettings.hasFullAccess
                DispatchQueue.main.async {
                    completion(currentAccess, "Сервер временно недоступен. Проверьте интернет или напишите @murkindev.")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let currentAccess = RayGramSettings.hasFullAccess
                DispatchQueue.main.async {
                    completion(currentAccess, "Ошибка ответа сервера.")
                }
                return
            }
            
            if httpResponse.statusCode != 200 {
                let currentAccess = RayGramSettings.hasFullAccess
                DispatchQueue.main.async {
                    completion(currentAccess, "Сервер вернул статус \(httpResponse.statusCode). Попробуйте позже.")
                }
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let hasAccess = json["has_access"] as? Bool else {
                let currentAccess = RayGramSettings.hasFullAccess
                DispatchQueue.main.async {
                    completion(currentAccess, "Некорректный ответ от сервера.")
                }
                return
            }
            
            DispatchQueue.main.async {
                RayGramSettings.recordVerification(hasAccess: hasAccess)
                completion(hasAccess, nil)
            }
        }
        task.resume()
    }
}
