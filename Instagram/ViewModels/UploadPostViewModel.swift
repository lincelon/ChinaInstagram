//
//  UploadPostViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 25.04.2021.
//

import UIKit
import Combine
import Firebase

final class UploadPostViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var caption: String = ""
    @Published var imagePickerPresented = false
    @Published var tabIndex: Int = 2
    
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []
    
    enum Action {
        case share
        case cancel
    }
    
    func send(action: Action) {
        switch action {
        case .share:
            guard let image = selectedImage else { return }
            
            webService
                .uploadPost(uiImage: image, caption: caption)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.selectedImage = nil
                    self?.caption = ""
                    self?.tabIndex = 0
                }
                .store(in: &cancellables)
        case .cancel:
            selectedImage = nil
            caption = ""
        }
    }
    
    init(webService: WebService = WebService()) {
        self.webService = webService
    }
}
