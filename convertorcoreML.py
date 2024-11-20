import coremltools as ct

# Load the TensorFlow model
import tensorflow as tf
tf_model = tf.keras.models.load_model("image_classifier_model")

# Convert the model to Core ML
mlmodel = ct.convert(
    tf_model,
    inputs=[ct.ImageType(shape=(1, 32, 32, 3), scale=1/255.0, bias=(0, 0, 0))]
)

# Save the Core ML model
mlmodel.save("cats_dogs_classifier.mlpackage")
