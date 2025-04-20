import Foundation
import Firebase
import FirebaseFirestore

@MainActor
class SessionStore: ObservableObject {

    // MARK: - Error Enum
    enum SessionStoreError: Error {
        case userNotFound
        case signInFailed
        case signUpFailed
        case signOutFailed
        case fetchUserDataFailed

        var localizedDescription: String {
            switch self {
            case .userNotFound:
                return "User not found. Please check your email or sign up."
            case .signInFailed:
                return "Unable to sign in. Please check your email and password."
            case .signUpFailed:
                return "Unable to sign up. Please try again."
            case .signOutFailed:
                return "Unable to sign out. Please try again."
            case .fetchUserDataFailed:
                return "Unable to load user data. Please try again."
            }
        }
    }

    // MARK: - Properties
    @Published var session: User?
    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var profileImageURL: String = ""
    @Published var errorMessage: String?

    @Published var appearancePreference: AppearancePreference {
        didSet {
            print("Préférence changée en : \(appearancePreference)")
            UserDefaults.standard.set(appearancePreference.rawValue, forKey: "appearancePreference")
        }
    }

    var handle: AuthStateDidChangeListenerHandle?

    // MARK: - Constants
    private let data = Firestore.firestore()

    // MARK: - Init
    init() {
        if let savedPreference = UserDefaults.standard.string(forKey: "appearancePreference"),
           let preference = AppearancePreference(rawValue: savedPreference) {
            appearancePreference = preference
        } else {
            appearancePreference = .system
        }
        listen()
    }

    // MARK: - Functions
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
                self.errorMessage = nil
            }
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            self.session = User(id: user.uid, email: user.email ?? "", fullName: "", profileImageURL: "")
            let userData: [String: Any] = [
                "id": user.uid,
                "email": user.email ?? "",
                "full_name": "New User",
                "profile_image_url": ""
            ]
            try await self.data.collection("users").document(user.uid).setData(userData)
            await self.fetchUserData(userId: user.uid)
        } catch {
            self.errorMessage = SessionStoreError.signUpFailed.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = result.user
            self.session = User(id: user.uid, email: user.email ?? "", fullName: "", profileImageURL: "")
            await self.fetchUserData(userId: user.uid)
        } catch {
            self.errorMessage = SessionStoreError.signInFailed.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
            self.email = ""
            self.fullName = ""
            self.profileImageURL = ""
            self.errorMessage = nil
        } catch {
            self.errorMessage = SessionStoreError.signOutFailed.localizedDescription
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
                self.errorMessage = SessionStoreError.userNotFound.localizedDescription
            }
        } catch {
            self.errorMessage = SessionStoreError.fetchUserDataFailed.localizedDescription
        }
        print("Finished fetchUserData at \(Date())")
    }
}
