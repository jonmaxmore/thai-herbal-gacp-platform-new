import os
import torch
import logging
from torch.utils.data import DataLoader
from data_augmentation import get_vit_transforms
from model_evaluation import evaluate_model
from vit_pytorch import ViT
from custom_dataset import CustomImageDataset

def main():
    logging.basicConfig(level=logging.INFO)
    data_dir = os.getenv('VIT_DATASET_DIR', './dataset')
    model_dir = os.getenv('VIT_MODEL_DIR', './models')
    epochs = int(os.getenv('VIT_EPOCHS', 50))
    batch_size = int(os.getenv('VIT_BATCH_SIZE', 32))
    num_classes = int(os.getenv('VIT_NUM_CLASSES', 10))
    lr = float(os.getenv('VIT_LR', 3e-4))
    best_f1 = 0.0

    train_transforms, val_transforms = get_vit_transforms()
    train_dataset = CustomImageDataset(os.path.join(data_dir, 'train'), transform=train_transforms)
    val_dataset = CustomImageDataset(os.path.join(data_dir, 'val'), transform=val_transforms)

    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=4)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False, num_workers=4)

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = ViT(
        image_size=224,
        patch_size=16,
        num_classes=num_classes,
        dim=768,
        depth=12,
        heads=12,
        mlp_dim=3072,
        dropout=0.1,
        emb_dropout=0.1
    ).to(device)

    criterion = torch.nn.CrossEntropyLoss()
    optimizer = torch.optim.AdamW(model.parameters(), lr=lr)

    os.makedirs(model_dir, exist_ok=True)
    best_model_path = os.path.join(model_dir, 'vit_best.pth')

    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item() * images.size(0)
        avg_train_loss = running_loss / len(train_loader.dataset)

        metrics = evaluate_model(model, val_loader, criterion, device)
        logging.info(
            f"Epoch {epoch+1}/{epochs} | "
            f"Train Loss: {avg_train_loss:.4f} | "
            f"Val Loss: {metrics['avg_loss']:.4f} | "
            f"Acc: {metrics['accuracy']:.4f} | "
            f"F1: {metrics['f1']:.4f} | "
            f"Precision: {metrics['precision']:.4f} | "
            f"Recall: {metrics['recall']:.4f}"
        )

        # Save best model by F1 score
        if metrics['f1'] > best_f1:
            best_f1 = metrics['f1']
            torch.save(model.state_dict(), best_model_path)
            logging.info(f"Saved best model to {best_model_path} (F1: {best_f1:.4f})")

if __name__ == "__main__":
    main()