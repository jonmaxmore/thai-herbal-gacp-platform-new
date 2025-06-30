import os
import logging
import onnxruntime as ort
from PIL import Image
import numpy as np

class HerbClassifier:
    def __init__(self, model_path=None, class_names=None):
        self.model_path = model_path or os.getenv("HERB_MODEL_PATH", "./ai_models/models/herb_classifier_v1.onnx")
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"Herb classifier model not found: {self.model_path}")
        self.session = ort.InferenceSession(self.model_path, providers=["CPUExecutionProvider"])
        self.class_names = class_names or self._load_class_names()
        logging.info(f"HerbClassifier loaded model: {self.model_path}")

    def _load_class_names(self):
        class_file = self.model_path.replace(".onnx", "_classes.txt")
        if os.path.exists(class_file):
            with open(class_file, "r", encoding="utf-8") as f:
                return [line.strip() for line in f.readlines()]
        logging.warning(f"Class names file not found: {class_file}")
        return []

    def preprocess(self, image: Image.Image):
        image = image.convert("RGB").resize((224, 224))
        arr = np.array(image).astype(np.float32) / 255.0
        if arr.ndim == 2:
            arr = np.stack([arr]*3, axis=-1)
        arr = arr.transpose(2, 0, 1)
        arr = (arr - np.array([0.485, 0.456, 0.406]).reshape(3,1,1)) / np.array([0.229, 0.224, 0.225]).reshape(3,1,1)
        arr = np.expand_dims(arr, axis=0)
        return arr

    def predict(self, image: Image.Image):
        arr = self.preprocess(image)
        ort_inputs = {self.session.get_inputs()[0].name: arr}
        ort_outs = self.session.run(None, ort_inputs)
        logits = ort_outs[0][0]
        pred_idx = int(np.argmax(logits))
        pred_name = self.class_names[pred_idx] if self.class_names and pred_idx < len(self.class_names) else str(pred_idx)
        confidence = float(np.max(self._softmax(logits)))
        logging.info(f"Predicted class: {pred_name} (id={pred_idx}, confidence={confidence:.4f})")
        return {"class_id": pred_idx, "class_name": pred_name, "confidence": confidence}

    @staticmethod
    def _softmax(x):
        e_x = np.exp(x - np.max(x))
        return e_x / e_x.sum()