//
//  Aespa.swift
//  
//
//  Created by 이영빈 on 2023/06/02.
//

/// Top-level class that serves as the main access point for video recording sessions.
open class Aespa {
    /// The core `AespaSession` that manages the actual video recording session.
    private static var core: AespaSession?
    
    private static var option: AespaOption?

    /// Creates a new `AespaSession` with the given options.
    ///
    /// - Parameters:
    ///   - option: The `AespaOption` to configure the session.
    /// - Returns: The newly created `AespaSession`.
    public static func session(
        with _option: AespaOption,
        onComplete: @escaping CompletionHandler = { _ in }
    ) -> AespaSession {
        if let core { return core }
        
        // Configure session now
        let newCore = AespaSession(option: _option)

        // Check logging option
        Logger.enableLogging = _option.log.loggingEnabled
        
        Task {
            guard
                case .permitted = await AuthorizationChecker.checkCaptureAuthorizationStatus()
            else {
                throw AespaError.permission(reason: .denied)
            }
            
            newCore.startSession(onComplete)
        }
        
        option = _option
        core = newCore
        return newCore
    }
    
    public static func start(_ onComplete: @escaping CompletionHandler = { _ in }) throws {
        if  self.core == nil {
            self.core = AespaSession(option: self.option ?? AespaOption(albumName: "test"))
        }
        
        
    }
    
    /// Terminates the current `AespaSession`.
    ///
    /// If a session has been started, it stops the session and releases resources.
    /// After termination, a new session needs to be configured to start recording again.
    public static func terminate(_ onComplete: @escaping CompletionHandler = { _ in }) throws {
        guard let core = core else {
            return
        }
        Task {
            core.terminateSession { result in
                self.core = nil
                onComplete(result)
            }
        }
        
    }
}
