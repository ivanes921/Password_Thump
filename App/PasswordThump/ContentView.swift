import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selection: Int?
    @State private var photoItem: PhotosPickerItem?
    @State private var backgroundImage: UIImage?

    var body: some View {
        VStack(spacing: 24) {
            Text("Password Thump")
                .font(.largeTitle.bold())

            PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                VStack {
                    if let backgroundImage {
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(alignment: .bottom) {
                                Text("Выбранные обои")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(.thinMaterial)
                            }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.fill")
                                .font(.largeTitle)
                            Text("Загрузите фото для обоев экрана блокировки")
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .buttonStyle(.plain)
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            backgroundImage = uiImage
                        }
                    }
                }
            }

            VStack(spacing: 12) {
                Text("Выберите длину пароля")
                    .font(.headline)
                HStack(spacing: 16) {
                    passcodeButton(label: "4 цифры", length: 4)
                    passcodeButton(label: "6 цифр", length: 6)
                }
            }

            Spacer()
            NavigationLink(destination: LockScreenView(passcodeLength: selection ?? 0, backgroundImage: backgroundImage), tag: 4, selection: $selection) { EmptyView() }
            NavigationLink(destination: LockScreenView(passcodeLength: selection ?? 0, backgroundImage: backgroundImage), tag: 6, selection: $selection) { EmptyView() }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func passcodeButton(label: String, length: Int) -> some View {
        Button {
            selection = length
        } label: {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
