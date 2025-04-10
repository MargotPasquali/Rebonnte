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
                        .foregroundColor(Color.text)
                }
                Text(session.fullName)
                    .font(Font.custom("Righteous", size: 25))
                    .foregroundStyle(Color.text)
                Text(session.email)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.text)
                    .cornerRadius(4)
                    .foregroundStyle(Color.background)
                    .font(Font.custom("Nunito-Regular", size: 16))

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    VStack {
                        Text("Choose your appearance preference:")
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundStyle(Color.background)
                            .multilineTextAlignment(.leading)
                        Picker("Apparence", selection: $session.appearancePreference) {
                            ForEach(AppearancePreference.allCases, id: \.self) { preference in
                                Text(preference.rawValue)
                                    .font(.custom("Nunito-Bold", size: 16))
                                    .foregroundStyle(Color.text)
                                    .padding(8)
                                    .tag(preference)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.background.opacity(0.5))

                        )
                        .padding(.horizontal)
                    }
                }
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
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    let sessionStore = SessionStore().withFakeUser()
    return UserAccountView()
        .environmentObject(sessionStore)
}

extension SessionStore {
    func withFakeUser() -> SessionStore {
        self.fullName = "Jean Dupont"
        self.profileImageURL = "https://www.photomaintenant.fr/_next/static/media/photo-professionnelle-ia-femme-fond-ville-costume-noir-01.7c88541c.webp"
        return self
    }
}
