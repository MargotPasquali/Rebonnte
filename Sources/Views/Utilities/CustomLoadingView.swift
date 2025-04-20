import SwiftUI

struct CustomLoadingView: View {
    // MARK: - Variables
    @State private var isLoading = false

    // MARK: - View
    var body: some View {
        ZStack {
            Color.background
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            isLoading = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CustomLoadingView()
}
