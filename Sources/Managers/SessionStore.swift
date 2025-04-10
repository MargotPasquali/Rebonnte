import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var profileImageURL: String = ""

    @Published var appearancePreference: AppearancePreference {
            didSet {
                print("Préférence changée en : \(appearancePreference)")
                UserDefaults.standard.set(appearancePreference.rawValue, forKey: "appearancePreference")
            }
        }

    var handle: AuthStateDidChangeListenerHandle?
    private let data = Firestore.firestore()

    init() {
            if let savedPreference = UserDefaults.standard.string(forKey: "appearancePreference"),
               let preference = AppearancePreference(rawValue: savedPreference) {
                appearancePreference = preference
            } else {
                appearancePreference = .system
            }
            listen()
        }

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                self.session = User(id: user.uid, email: user.email ?? "", fullName: "", profileImageURL: "")
                Task {
                    await self.fetchUserData(userId: user.uid)
                }
            } else {
                self.session = nil
                self.email = ""
                self.fullName = ""
                self.profileImageURL = ""
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error creating user: \(error.localizedDescription) \(error)")
            } else if let user = result?.user {
                self.session = User(id: user.uid, email: user.email ?? "", fullName: "", profileImageURL: "")
                let userData: [String: Any] = [
                    "id": user.uid,
                    "email": user.email ?? "",
                    "full_name": "New User",
                    "profile_image_url": ""
                ]
                self.data.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        print("Error writing user to Firestore: \(error)")
                    } else {
                        Task {
                            await self.fetchUserData(userId: user.uid)
                        }
                    }
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else if let user = result?.user {
                self.session = User(id: user.uid, email: user.email ?? "", fullName: "", profileImageURL: "")
                Task {
                    await self.fetchUserData(userId: user.uid)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
            self.email = ""
            self.fullName = ""
            self.profileImageURL = ""
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func fetchUserData(userId: String) async {
        print("Starting fetchUserData for userId: \(userId) at \(Date())")
        do {
            let document = try await data.collection("users").document(userId).getDocument()
            if document.exists, let data = document.data() {
                print("Firestore raw data: \(data)")
                let user = try document.data(as: User.self)
                print("Successfully decoded user: id=\(user.id), email=\(user.email), fullName=\(user.fullName), profileImageURL=\(user.profileImageURL)")
                self.session = user
                self.email = user.email
                self.fullName = user.fullName
                self.profileImageURL = user.profileImageURL
            } else {
                print("User document does not exist")
            }
        } catch {
            print("Error fetching or decoding user data: \(error.localizedDescription)")
        }
        print("Finished fetchUserData at \(Date())")
    }
}
