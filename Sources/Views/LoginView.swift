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
                Text("Email")
                    .font(Font.custom("Nunito-SemiBold", size: 20))
                    .foregroundStyle(Color("Text Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("", text: $email, prompt: Text("Entrez votre email").foregroundColor(.gray))
                    .padding()
                    .background(Color("Text Color"))
                    .foregroundStyle(Color("Text Color"))
                    .font(Font.custom("Nunito-Regular", size: 16))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                Text("Password")
                    .foregroundStyle(Color("Text Color"))
                    .font(Font.custom("Nunito-SemiBold", size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                SecureField("", text: $password, prompt: Text("Entrez votre mot de passe").foregroundColor(.gray))
                    .font(Font.custom("Nunito-Regular", size: 16))
                    .padding()
                    .background(Color("Text Color"))
                    .foregroundStyle(Color("Text Color"))
                    .cornerRadius(8)
                Button(action: {
                    session.signIn(email: email, password: password)
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
                Button(action: {
                    session.signUp(email: email, password: password)
                }) {
                    Text("Sign Up")
                        .font(Font.custom("Nunito-ExtraBold", size: 18))
                        .foregroundStyle(Color("Text Color"))


                }
            }
            .padding()
        }
    }
}


#Preview {
    LoginView().environmentObject(SessionStore())
}
