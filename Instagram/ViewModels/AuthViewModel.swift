//
//  AuthViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 16.04.2021.
//

import UIKit
import Combine

struct FormValidation {
    var isSucceed: Bool = false
    var message: String = ""
}

final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = "Maxim40a"
    @Published var username: String = ""
    @Published var fullName: String = ""
    @Published var selectedImage: UIImage?
    
    @Published var currentUser: User?
    
    @Published var emailValidation: FormValidation = FormValidation()
    @Published var passwordValidation: FormValidation = FormValidation()
    @Published var usernameValidation: FormValidation = FormValidation()
    @Published var fullNameValidation: FormValidation = FormValidation()
    
    @Published var canLogin: Bool = false
    @Published var canSignup: Bool = false
    
    struct Config {
        static let recommendedLength = 6
        static let specialCharacters = "!@#$%^&*()?/|\\:;"
        static let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        static let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$")
        static let fullNamePredicate = NSPredicate(format:"SELF MATCHES %@", "^[a-zA-Z]{4,}(?: [a-zA-Z]+){0,2}$")
    }
    
    enum Action {
        case signup
        case login
        case logout
    }
    
    private let userService: UserService
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []
    
    init(userService: UserService = UserService(),
         webService: WebService = WebService()) {
        self.userService = userService
        self.webService = webService
        
        userService
            .observeAuthChanges()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if let documentID = userService.currentUser?.uid {
                    webService
                        .fetchUser(documentID: documentID)
                        .sink { competion in
                            switch competion {
                            case .finished:
                                break
                            case let .failure(error):
                                print(error.localizedDescription)
                            }
                        } receiveValue: { [weak self] in self?.currentUser = $0 }
                        .store(in: &self.cancellables)
                }
            }
            .store(in: &cancellables)
        
        emailPublisher
            .assign(to: \.emailValidation, on: self)
            .store(in: &cancellables)
        
        passwordPublisher
            .assign(to: \.passwordValidation, on: self)
            .store(in: &cancellables)
        
        fullNamePublisher
            .assign(to: \.fullNameValidation, on: self)
            .store(in: &cancellables)
        
        usernamePublisher
            .assign(to: \.usernameValidation, on: self)
            .store(in: &cancellables)
        
        
        Publishers.CombineLatest(emailPublisher, passwordPublisher)
            .map { emailValidation, passwordValidation  in
                emailValidation.isSucceed && passwordValidation.isSucceed
            }
            .assign(to: \.canLogin, on: self)
            .store(in: &cancellables)
        
        
        Publishers.CombineLatest4(emailPublisher, passwordPublisher, usernamePublisher, fullNamePublisher)
            .map { emailValidation, passwordValidation, usernameValidation, fullNameValidation  in
                emailValidation.isSucceed && passwordValidation.isSucceed && usernameValidation.isSucceed && fullNameValidation.isSucceed
            }
            .assign(to: \.canSignup, on: self)
            .store(in: &cancellables)
    }
    
    func send(action: Action) {
        switch action {
        case .signup:
            guard let image = selectedImage else { return }
            
            userService
                .signup(email: email, password: password,
                        username: username, fullname: fullName, image: image)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Successfully created a user")
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: {  _ in
                    
                }
                .store(in: &cancellables)
            
        case .login:
            
            userService
                .login(email: email, password: password)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Successfully logged in")
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: {  _ in
                }
                .store(in: &cancellables)
            
            
        case .logout:
            userService
                .logout()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Successfully logged out")
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
            
            email = ""
            username = ""
            fullName = ""
        }
    }
    
    private var emailPublisher: AnyPublisher<FormValidation, Never> {
        $email
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { email in
                if email.isEmpty {
                    return FormValidation(isSucceed: false, message: "")
                }
                
                if !Config.emailPredicate.evaluate(with: email) {
                    return FormValidation(isSucceed: false, message: "Invalid email address")
                }
                
                return FormValidation(isSucceed: true, message: "")
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordPublisher: AnyPublisher<FormValidation, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                if password.isEmpty {
                    return FormValidation(isSucceed: false, message: "")
                }
                
                if password.count < Config.recommendedLength {
                    return FormValidation(isSucceed: false, message: "The password length must be greater than \(Config.recommendedLength)")
                }
                
                if !Config.passwordPredicate.evaluate(with: password) {
                    return FormValidation(isSucceed: false, message: "The password is must contain numbers, uppercase and special characters")
                }
                
                return FormValidation(isSucceed: true, message: "")
            }
            .eraseToAnyPublisher()
    }
    
    private var usernamePublisher: AnyPublisher<FormValidation, Never> {
        $username
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { username in
                if username.isEmpty {
                    return FormValidation(isSucceed: false, message: "")
                }
                
                return FormValidation(isSucceed: true, message: "")
            }
            .eraseToAnyPublisher()
    }
    
    private var fullNamePublisher: AnyPublisher<FormValidation, Never> {
        $fullName
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { fullName in
                if fullName.isEmpty {
                    return FormValidation(isSucceed: false, message: "")
                }
                
                if !Config.fullNamePredicate.evaluate(with: fullName) {
                    return FormValidation(isSucceed: false, message: "Full name must contains only letters")
                }
                
                return FormValidation(isSucceed: true, message: "")
            }
            .eraseToAnyPublisher()
    }
}
