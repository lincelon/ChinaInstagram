//
//  MainView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct MainView: View {
    @State private var selectedIndex = 0
    var body: some View {
        
        MainTabView(selectedIndex: $selectedIndex)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
