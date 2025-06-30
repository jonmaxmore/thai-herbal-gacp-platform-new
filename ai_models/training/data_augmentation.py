import os
import shutil
import random
from PIL import Image
from torchvision import transforms

def augment_yolo_dataset(data_dir, output_dir=None, augment_count=2):
    """
    ทำ data augmentation สำหรับ YOLO dataset (image + label)
    - data_dir: path ที่มี images/ และ labels/
    - output_dir: path สำหรับเก็บไฟล์ที่ augment (default: data_dir/augmented)
    - augment_count: จำนวน augmentation ต่อภาพ
    """
    img_dir = os.path.join(data_dir, "images")
    label_dir = os.path.join(data_dir, "labels")
    output_img_dir = os.path.join(output_dir or os.path.join(data_dir, "augmented", "images"))
    output_label_dir = os.path.join(output_dir or os.path.join(data_dir, "augmented", "labels"))
    os.makedirs(output_img_dir, exist_ok=True)
    os.makedirs(output_label_dir, exist_ok=True)

    aug_transforms = [
        transforms.RandomHorizontalFlip(p=1.0),
        transforms.RandomVerticalFlip(p=1.0),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.3, hue=0.1),
        transforms.RandomRotation(10),
    ]

    img_files = [f for f in os.listdir(img_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    for img_file in img_files:
        img_path = os.path.join(img_dir, img_file)
        label_path = os.path.join(label_dir, os.path.splitext(img_file)[0] + ".txt")
        # Copy original
        shutil.copy2(img_path, os.path.join(output_img_dir, img_file))
        if os.path.exists(label_path):
            shutil.copy2(label_path, os.path.join(output_label_dir, os.path.splitext(img_file)[0] + ".txt"))
        # Augment
        image = Image.open(img_path).convert("RGB")
        for i in range(augment_count):
            t = random.choice(aug_transforms)
            aug_image = t(image)
            aug_img_name = f"{os.path.splitext(img_file)[0]}_aug{i}.jpg"
            aug_img_path = os.path.join(output_img_dir, aug_img_name)
            aug_image.save(aug_img_path)
            # YOLO label ไม่เปลี่ยนถ้าแค่ flip/rotate เล็กน้อย (ถ้า transform เปลี่ยน geometry มาก ต้องปรับ label ด้วย)
            if os.path.exists(label_path):
                shutil.copy2(label_path, os.path.join(output_label_dir, f"{os.path.splitext(img_file)[0]}_aug{i}.txt"))

def get_vit_transforms():
    train_transforms = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    val_transforms = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    return train_transforms, val_transforms