//
//  ContentView.swift
//  MLImageClassifierProject
//
//  Created by Tanish Solanki on 20/11/24.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct ContentView: View {
    @State private var selectedImage: UIImage? // Image selected by the user
    @State private var prediction: String = "No Prediction" // Prediction to display
    @State private var isImagePickerPresented: Bool = false // Controls image picker presentation

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("No Image Selected")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            }

            Text(prediction)
                .font(.headline)
                .padding()
            
            // User Feedback Section
                        if selectedImage != nil {
                            VStack {
                                Text("Was the prediction correct?")
                                    .font(.subheadline)
                                    .padding(.top)

                                HStack {
                                    Button(action: {
                                        saveImage(selectedImage!, withLabel: "Cat")
                                        print("Saved as Cat")
                                    }) {
                                        Text("Correct as Cat")
                                            .padding()
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }

                                    Button(action: {
                                        saveImage(selectedImage!, withLabel: "Dog")
                                        print("Saved as Dog")
                                    }) {
                                        Text("Correct as Dog")
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.top)
                        }

            Button("Pick an Image") {
                isImagePickerPresented = true // Show the image picker
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, onImageSelected: classifySelectedImage)
        }
        .padding()
    }
    
    // Function to Save Images Locally
        func saveImage(_ image: UIImage, withLabel label: String) {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentsDirectory = urls.first else { return }

            // Create a directory for labeled images
            let labelDirectory = documentsDirectory.appendingPathComponent(label)
            if !fileManager.fileExists(atPath: labelDirectory.path) {
                try? fileManager.createDirectory(at: labelDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            // Save the image with a unique name
            let imageName = UUID().uuidString + ".png"
            let imageURL = labelDirectory.appendingPathComponent(imageName)
            if let imageData = image.pngData() {
                try? imageData.write(to: imageURL)
                print("Saved image to: \(imageURL.path)")
            }
        }

    // Preprocess the image to match the Core ML model's expected input size and format
    func preprocessImage(_ image: UIImage) -> CVPixelBuffer? {
        UIGraphicsBeginImageContext(CGSize(width: 32, height: 32)) // Model's expected size
        image.draw(in: CGRect(x: 0, y: 0, width: 32, height: 32))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let resizedImage = resizedImage else {
            print("Error: Resizing image failed.")
            return nil
        }

        guard let cgImage = resizedImage.cgImage else {
            print("Error: Conversion to CGImage failed.")
            return nil
        }

        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            32, // Width
            32, // Height
            kCVPixelFormatType_32ARGB, // Pixel format
            attributes,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Error: Failed to create pixel buffer.")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: 32,
            height: 32,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let context = context else {
            print("Error: Failed to create CGContext.")
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 32, height: 32))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)

        return buffer
    }

    // Classify the selected image
    func classifySelectedImage() {
        guard let image = selectedImage else {
            prediction = "No Image to Classify"
            return
        }
        classifyImage(image)
    }

    // Process the image and classify using Vision/Core ML
    func classifyImage(_ image: UIImage) {
        // Preprocess the image
        guard let pixelBuffer = preprocessImage(image) else {
            prediction = "Error: Unable to preprocess image."
            print("Error: Unable to preprocess image.")
            return
        }

        // Load the Core ML model
        guard let model = try? cats_dogs_classifier(configuration: MLModelConfiguration()) else {
            prediction = "Error: Unable to load model."
            print("Error: Unable to load model.")
            return
        }

        // Make predictions using the Core ML model
        guard let output = try? model.prediction(conv2d_input: pixelBuffer) else {
            prediction = "Error: Model failed to make predictions."
            print("Error: Model failed to make predictions.")
            return
        }

        // Handle probabilities from the `Identity` layer
        if let probabilities = output.Identity as? MLMultiArray {
            // Convert MLMultiArray to a Swift array for easier handling
            let catProbability = probabilities[0].doubleValue // Probability for Cat
            let dogProbability = probabilities[1].doubleValue // Probability for Dog

            // Determine the class with the highest probability
            if catProbability > dogProbability {
                prediction = "Prediction: Cat with \(Int(catProbability * 100))% confidence."
            } else {
                prediction = "Prediction: Dog with \(Int(dogProbability * 100))% confidence."
            }

            print(prediction)  // Log the prediction for debugging
        } else {
            prediction = "Error: Unable to interpret model output."
            print("Error: Unable to interpret model output.")
        }
    }


    // Image picker for SwiftUI
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        var onImageSelected: () -> Void

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .photoLibrary
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                    parent.onImageSelected()
                }
                picker.dismiss(animated: true)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
