import SwiftUI
import Kingfisher

struct UserAccountView: View {
    // MARK: - Properties
    @EnvironmentObject var session: SessionStore
    @State private var showErrorAlert = false
    @State private var newName: String = ""
    @State private var showSuccess = false

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
                                .accessibilityHidden(true)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .accessibilityLabel("Photo de profil")
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color.text)
                        .accessibilityLabel("Photo de profil par défaut")
                }

                TextField("Entrez votre nom", text: $newName, prompt: Text(session.fullName).foregroundColor(.text))
                    .padding()
                    .font(Font.custom("Righteous", size: 25))
                    .cornerRadius(4)
                    .foregroundColor(.text)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.center)

                Text(session.email)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.text)
                    .cornerRadius(4)
                    .foregroundStyle(Color.background)
                    .font(Font.custom("Nunito-Regular", size: 16))
                    .accessibilityLabel("Email : \(session.email)")

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)

                    VStack(alignment: .leading) {
                        Text("Choose your color scheme")
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundStyle(Color.background)
                            .padding(.leading)
                            .accessibilityHidden(true)

                        Picker("Appearance", selection: $session.appearancePreference) {
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
                        .accessibilityLabel("Sélectionner le mode d’apparence")
                        .accessibilityValue(session.appearancePreference.rawValue)
                        .accessibilityHint("Choisissez entre Système, Clair ou Sombre")
                    }
                }
                Button(action: {
                    Task {
                        do {
                            try await session.updateUserName(newName: newName)
                            showSuccess = true
                        } catch {
                            session.errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }) {
                    Text("Update Name")
                        .foregroundColor(Color.text)
                        .font(Font.custom("Nunito-SemiBold", size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.action)
                .cornerRadius(4)
                .padding(.top, 10)
                .alert(isPresented: $showSuccess) {
                    Alert(title: Text("Success"), message: Text("Votre nom a bien été modifié"), dismissButton: .default(Text("OK")))
                }

                Button(action: {
                    do {
                        try session.signOut()
                    } catch {
                        session.errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
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
                .padding(.top, 5)
                .accessibilityLabel("Se déconnecter")
                .accessibilityHint("Appuyez pour vous déconnecter")

                Spacer()
            }
            .padding()
            .alert("Erreur", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
                    .accessibilityLabel("OK")
            } message: {
                Text(session.errorMessage ?? "Une erreur inconnue s’est produite.")
                    .accessibilityLabel("Erreur : \(session.errorMessage ?? "Une erreur inconnue s’est produite.")")
            }
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
