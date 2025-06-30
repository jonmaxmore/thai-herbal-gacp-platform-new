import os
import logging
from ultralytics import YOLO

class YoloDetector:
    def __init__(self, model_path=None, device=None):
        self.model_path = model_path or os.getenv("YOLO_MODEL_PATH", "./ai_models/models/yolo_best.onnx")
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"YOLO model not found: {self.model_path}")
        self.device = device or ("cuda" if self._cuda_available() else "cpu")
        self.model = YOLO(self.model_path, task="detect")
        self.model.to(self.device)
        logging.info(f"YoloDetector loaded model: {self.model_path} on device: {self.device}")

    def _cuda_available(self):
        try:
            import torch
            return torch.cuda.is_available()
        except ImportError:
            return False

    def predict(self, image_path, conf=0.25, iou=0.45):
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found: {image_path}")
        results = self.model.predict(
            source=image_path,
            conf=conf,
            iou=iou,
            device=self.device,
            save=False,
            verbose=False
        )
        logging.info(f"YOLO prediction completed for {image_path}")
        return results[0].tojson()