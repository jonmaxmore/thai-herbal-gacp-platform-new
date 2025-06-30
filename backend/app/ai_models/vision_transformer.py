import os
import logging
import torch
from torchvision import transforms
from vit_pytorch import ViT
from PIL import Image

class VisionTransformerClassifier:
    def __init__(self, model_path=None, num_classes=10, device=None):
        self.model_path = model_path or os.getenv("VIT_MODEL_PATH", "./ai_models/models/vit_best.pth")
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"ViT model not found: {self.model_path}")
        self.device = device or ("cuda" if torch.cuda.is_available() else "cpu")
        self.model = ViT(
            image_size=224,
            patch_size=16,
            num_classes=num_classes,
            dim=768,
            depth=12,
            heads=12,
            mlp_dim=3072,
            dropout=0.1,
            emb_dropout=0.1
        )
        state_dict = torch.load(self.model_path, map_location=self.device)
        self.model.load_state_dict(state_dict)
        self.model.eval()
        self.model.to(self.device)
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        logging.info(f"VisionTransformerClassifier loaded model: {self.model_path}")

    def predict(self, image: Image.Image):
        image = self.transform(image).unsqueeze(0).to(self.device)
        with torch.no_grad():
            logits = self.model(image)
            pred = torch.argmax(logits, dim=1).item()
            confidence = torch.softmax(logits, dim=1).max().item()
        logging.info(f"Predicted class: {pred} (confidence={confidence:.4f})")
        return {"class_id": pred, "confidence": confidence}