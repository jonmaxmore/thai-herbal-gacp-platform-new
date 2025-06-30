import os
import logging
import onnxruntime as ort
from PIL import Image
import numpy as np

class QualityAssessor:
    def __init__(self, model_path=None):
        self.model_path = model_path or os.getenv("QUALITY_MODEL_PATH", "./ai_models/models/quality_detector_v1.onnx")
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"Quality model not found: {self.model_path}")
        self.session = ort.InferenceSession(self.model_path, providers=["CPUExecutionProvider"])
        logging.info(f"QualityAssessor loaded model: {self.model_path}")

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
        score = float(ort_outs[0][0][0])
        logging.info(f"Predicted quality score: {score:.4f}")
        return score