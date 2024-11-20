# **MLImageClassifierProject**

A simple iOS application that uses **Core ML** and **SwiftUI** to classify images of cats and dogs. The project leverages a pre-trained machine learning model and enables users to provide feedback to improve the model in future iterations.

---

## **Features**

- Upload an image from your photo library.
- Classify the image as either a **Cat** or a **Dog** with confidence levels.
- Allows users to correct predictions and save images locally for future retraining.
- Built with:
  - **SwiftUI** for a declarative user interface.
  - **Core ML** for machine learning inference.
  - **Vision Framework** for image preprocessing and integration with Core ML.

---

## **Requirements**

| Requirement         | Version/Details                                                   |
|---------------------|-------------------------------------------------------------------|
| **Xcode**           | Version 14.0 or later                                            |
| **iOS Device**      | iOS 15.0 or later (supports Core ML `.mlpackage` format models)  |
| **Core ML Model**   | A trained model for classifying images of cats and dogs.         |

---

## **Getting Started**

### **1. Clone the Repository**

```bash
git clone https://github.com/Tanish57/DataScience.git
cd DataScience
```

### **2. Open in Xcode**

Open the MLImageClassifierProject.xcodeproj file in Xcode.
Make sure your .mlpackage file is added to the project (see Adding the Core ML Model).
### 3. Run on a Physical Device 

Connect your iOS device and select it as the target in Xcode.
Click the Run button to build and run the app.

## **Project Structure**
File	Description
ContentView.swift	Main SwiftUI view, handles image selection, classification, and user feedback.
cats_dogs_classifier.mlpackage	Core ML model for classifying cats and dogs.
ImagePicker.swift	Wrapper for UIImagePickerController to allow image selection in SwiftUI.

## **How to Use**
Launch the app on your iOS device.
Tap Pick an Image to upload an image from your photo library.
The app will:
Display the selected image.
Classify the image as either Cat or Dog, along with the confidence percentage.
If the prediction is incorrect:
Use the Correct as Cat or Correct as Dog buttons to save the image with the correct label.
Saved images are stored in the app's Documents Directory for future use.

## **Adding the Core ML Model**
Place your .mlpackage file (e.g., cats_dogs_classifier.mlpackage) in the Xcode project.
Ensure the file is included in the app’s target:
Select the .mlpackage file in the Xcode Project Navigator.
Check the Target Membership box for your app.

## **Future Enhancements**
Fine-Tuning the Model:
Export the saved images from the app to use them for retraining or fine-tuning the Core ML model.
Incorporate new data to improve accuracy over time.
Support for Real-Time Classification:
Enable classification using the camera feed.
Upload Images to a Server:
Add functionality to upload images and user feedback to a cloud server for centralized training.

## **Known Issues**
Occasionally, the confidence score may be 0%. This may happen due to insufficient training data or preprocessing inconsistencies.
Fine-tuning the model with saved data is not yet implemented.

## **Acknowledgments**
Core ML: For enabling on-device machine learning.
SwiftUI: For a simple and intuitive UI.
Kaggle Dogs vs. Cats Dataset: For training the initial model.

## **Contributing**
Contributions are welcome! Feel free to fork this repository and submit pull requests. For major changes, please open an issue first to discuss your ideas.

## **License**
This project is licensed under the MIT License.
