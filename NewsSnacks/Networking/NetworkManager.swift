import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private var imageCache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func fetchImage(from urlString: String) async -> UIImage? {
        // Check cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        // Try to create a URL
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        // Special handling for Hindustan Times
        if urlString.contains("hindustantimes.com") {
            return await fetchHindustanTimesImage(from: urlString)
        }
        
        // Create a URLSession with custom configuration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        
        do {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
            
            let session = URLSession.shared
            let (data, _) = try await session.data(for: request)
            if let image = UIImage(data: data) {
                // Cache the image
                imageCache.setObject(image, forKey: urlString as NSString)
                return image
            }
        } catch {
            print("Error loading image: \(error)")
            
            // Fallback for Times of India images
            if urlString.contains("static.toiimg.com") {
                // Try with a different approach
                do {
                    let modifiedURL = URL(string: urlString.replacingOccurrences(of: "http://", with: "https://"))!
                    var request = URLRequest(url: modifiedURL)
                    request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
                    
                    // Use a session with SSL handling for TOI too
                    let session = URLSession(configuration: URLSessionConfiguration.default, 
                                            delegate: ImprovedSSLDelegate(), 
                                            delegateQueue: nil)
                    
                    let (data, _) = try await session.data(for: request)
                    if let image = UIImage(data: data) {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        return image
                    }
                } catch {
                    print("Fallback also failed: \(error)")
                }
            }
        }
        
        return nil
    }
    
    // Special function for handling Hindustan Times images - equivalent to verify=False
    private func fetchHindustanTimesImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        // Configure session with SSL verification disabled
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        
        // Create a session with the custom delegate that bypasses SSL verification
        let session = URLSession(configuration: config, delegate: ImprovedSSLDelegate(), delegateQueue: nil)
        
        do {
            var request = URLRequest(url: url)
            
            // Set headers equivalent to the Python request
            request.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.setValue("keep-alive", forHTTPHeaderField: "Connection")
            request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
            
            // Set cookies
            let cookies = [
                "Meta-Geo": "IN--DL--NEWDELHI",
                "ht-location": "IN"
            ]
            
            // Add cookies to the request
            let cookieString = cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; ")
            request.setValue(cookieString, forHTTPHeaderField: "Cookie")
            
            let (data, _) = try await session.data(for: request)
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: urlString as NSString)
                return image
            }
        } catch {
            print("Error loading Hindustan Times image: \(error)")
        }
        
        return nil
    }
}

// Improved SSL delegate using Apple's recommended approach
class ImprovedSSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Check if this is a server trust challenge
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            
            let host = challenge.protectionSpace.host
            
            // Always trust specific domains
            if host.contains("hindustantimes.com") || host.contains("toiimg.com") || host.contains("indiatimes.com") {
                // Check if the certificate is self-signed
                let isSelfSigned = serverTrust.isSelfSigned
                print("Host: \(host), Self-signed certificate: \(isSelfSigned ?? false)")
                
                // Trust regardless of certificate status for these domains
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        // Default handling for other challenges
        completionHandler(.performDefaultHandling, nil)
    }
}

// Extensions for checking self-signed certificates (based on Apple's code)
extension SecTrust {
    var isSelfSigned: Bool? {
        guard SecTrustGetCertificateCount(self) == 1 else {
            return false
        }
        guard let cert = SecTrustGetCertificateAtIndex(self, 0) else {
            return nil
        }
        return cert.isSelfSigned
    }
}

extension SecCertificate {
    var isSelfSigned: Bool? {
        guard
            let subject = SecCertificateCopyNormalizedSubjectSequence(self),
            let issuer = SecCertificateCopyNormalizedIssuerSequence(self)
        else {
            return nil
        }
        return subject == issuer
    }
}