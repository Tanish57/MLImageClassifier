import os
import shutil
from sklearn.model_selection import train_test_split

# Paths
original_dataset_dir = "KaggleCatandDogs/PetImages"  # Replace with the path to PetImages
base_dir = "dataset"
os.makedirs(base_dir, exist_ok=True)

# Create train and validation directories
train_dir = os.path.join(base_dir, "train")
validation_dir = os.path.join(base_dir, "validation")
os.makedirs(train_dir, exist_ok=True)
os.makedirs(validation_dir, exist_ok=True)

for category in ["Cat", "Dog"]:
    os.makedirs(os.path.join(train_dir, category), exist_ok=True)
    os.makedirs(os.path.join(validation_dir, category), exist_ok=True)

    # Get list of all images
    category_path = os.path.join(original_dataset_dir, category)
    images = [f for f in os.listdir(category_path) if f.endswith(('.jpg', '.png'))]

    # Split images into train and validation sets
    train_images, val_images = train_test_split(images, test_size=0.2, random_state=42)

    # Move images to respective directories
    for img in train_images:
        shutil.copy(os.path.join(category_path, img), os.path.join(train_dir, category, img))
    for img in val_images:
        shutil.copy(os.path.join(category_path, img), os.path.join(validation_dir, category, img))
