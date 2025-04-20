import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ZStack {
            Color("Background Color")
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(Font.custom("Righteous-Regular", size: 40))
                    .foregroundStyle(Color("Text Color"))
                    .accessibilityLabel("Welcome")

                Text("Email")
                    .font(Font.custom("Nunito-SemiBold", size: 20))
                    .foregroundStyle(Color("Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)

                TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.gray))
                    .padding()
                    .background(Color("Text Color"))
                    .foregroundStyle(Color.background)
                    .font(Font.custom("Nunito-Regular", size: 16))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .accessibilityLabel("Email")
                    .accessibilityValue(email)
                    .accessibilityHint("Enter your email address")

                Text("Password")
                    .foregroundStyle(Color("Text Color"))
                    .font(Font.custom("Nunito-SemiBold", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)

                SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.gray))
                    .font(Font.custom("Nunito-Regular", size: 16))
                    .padding()
                    .background(Color("Text Color"))
                    .foregroundStyle(Color.background)
                    .cornerRadius(8)
                    .accessibilityLabel("Password")
                    .accessibilityValue(password.isEmpty ? "Empty" : "Filled")
                    .accessibilityHint("Enter your password")

                if let errorMessage = session.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(Font.custom("Nunito-Regular", size: 12))
                        .accessibilityLabel("Error: \(errorMessage)")
                }

                Button(action: {
                    Task {
                        await session.signIn(email: email, password: password)
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Action Color"))
                        .font(Font.custom("Nunito-ExtraBold", size: 20))
                        .foregroundStyle(Color.white)
                        .cornerRadius(8)
                        .padding(.top, 20)
                }
                .accessibilityLabel("Sign in")
                .accessibilityHint("Tap to sign in with your email and password")

                Button(action: {
                    Task {
                        await session.signUp(email: email, password: password)
                    }
                }) {
                    Text("Sign Up")
                        .font(Font.custom("Nunito-ExtraBold", size: 18))
                        .foregroundStyle(Color("Text Color"))
                }
                .accessibilityLabel("Sign up")
                .accessibilityHint("Tap to create a new account")
            }
            .padding()
        }
    }
}

#Preview {
    LoginView().environmentObject(SessionStore())
}
