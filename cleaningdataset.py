import os
from PIL import Image
valid_extensions = [".jpg", ".jpeg", ".png"]

def clean_dataset(folder_path):
    for category in ["Cat", "Dog"]:
        category_path = os.path.join(folder_path, category)
        for file_name in os.listdir(category_path):
            file_path = os.path.join(category_path, file_name)
            if not file_name.lower().endswith(tuple(valid_extensions)):
                print(f"Removing non-image file: {file_path}")
                os.remove(file_path)
                continue
            try:
                with Image.open(file_path) as img:
                    img.verify()
            except (IOError, SyntaxError):
                print(f"Removing invalid file: {file_path}")
                os.remove(file_path)

# Clean both train and validation directories
clean_dataset("dataset/train")
clean_dataset("dataset/validation")
