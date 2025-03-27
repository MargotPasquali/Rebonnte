//
//  UserAccountView.swift
//  MediStock
//
//  Created by Margot Pasquali on 24/03/2025.
//

import SwiftUI
import Kingfisher

struct UserAccountView: View {
    
    @EnvironmentObject var session: SessionStore
    @Binding var darkMode: Bool
    
    var body: some View {
        ZStack {
            Color("Background Color")
                .ignoresSafeArea()
            VStack {
                if let url = URL(string: session.profileImageURL) {
                    KFImage(url)
                        .placeholder {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .foregroundColor(Color.black)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color.gray)
                }
                Text(session.fullName)
                    .font(Font.custom("Righteous", size: 25))
                    .foregroundStyle(Color("Text Color"))
                Text(session.email)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.action)
                    .cornerRadius(4)
                    .foregroundStyle(Color.white)
                    .font(Font.custom("Nunito-Regular", size: 16))
                Toggle("Dark Mode", isOn: $darkMode)
                    .tint(Color.action)
                    .foregroundStyle(Color.text)
                    .font(Font.custom("Nunito-Regular", size: 16))
                
                Button(action: {
                    session.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(Color.text)
                        .font(Font.custom("Nunito-ExtraBold", size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.background)
                .border(Color.text, width: 2)
                .cornerRadius(8)
                .padding(.top, 20)

            }.padding()
        }
    }
}

#Preview {
    // Créer un SessionStore avec un utilisateur fictif
    let sessionStore = SessionStore().withFakeUser()
    
    // Utiliser @State pour darkMode dans la preview
    @State var previewDarkMode = false
    
    return UserAccountView(darkMode: $previewDarkMode)
        .environmentObject(sessionStore)
}

// Extension pour simplifier la création d'un SessionStore avec un utilisateur fictif
extension SessionStore {
    func withFakeUser() -> SessionStore {
        self.fullName = "Jean Dupont"
        self.profileImageURL = "https://www.photomaintenant.fr/_next/static/media/photo-professionnelle-ia-femme-fond-ville-costume-noir-01.7c88541c.webp"
        return self
    }
}
