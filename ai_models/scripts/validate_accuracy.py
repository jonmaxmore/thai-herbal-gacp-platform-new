import os
import logging
import torch
import onnxruntime as ort
from torch.utils.data import DataLoader
from custom_dataset import CustomImageDataset

def evaluate_onnx_accuracy(onnx_path, data_dir, batch_size=32):
    dataset = CustomImageDataset(data_dir)
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=False)
    session = ort.InferenceSession(onnx_path, providers=["CPUExecutionProvider"])
    correct, total = 0, 0
    for images, labels in dataloader:
        if hasattr(images, "numpy"):
            np_images = images.numpy()
        else:
            np_images = images.detach().cpu().numpy()
        ort_inputs = {session.get_inputs()[0].name: np_images}
        ort_outs = session.run(None, ort_inputs)
        preds = torch.tensor(ort_outs[0]).argmax(dim=1)
        correct += (preds == labels).sum().item()
        total += labels.size(0)
    acc = correct / total if total > 0 else 0
    logging.info(f"Accuracy for {onnx_path}: {acc:.4f}")
    return acc

def main():
    logging.basicConfig(level=logging.INFO)
    onnx_dir = os.getenv("ONNX_DIR", "./optimized_models")
    data_dir = os.getenv("VAL_DATA_DIR", "./dataset/val")
    batch_size = int(os.getenv("BATCH_SIZE", 32))
    if not os.path.isdir(onnx_dir):
        logging.error(f"ONNX directory not found: {onnx_dir}")
        return
    if not os.path.isdir(data_dir):
        logging.error(f"Validation data directory not found: {data_dir}")
        return
    onnx_files = [f for f in os.listdir(onnx_dir) if f.endswith(".onnx")]
    if not onnx_files:
        logging.warning(f"No ONNX files found in {onnx_dir}")
        return
    for fname in onnx_files:
        onnx_path = os.path.join(onnx_dir, fname)
        try:
            evaluate_onnx_accuracy(onnx_path, data_dir, batch_size)
        except Exception as e:
            logging.error(f"Failed to evaluate {onnx_path}: {e}")

if __name__ == "__main__":
    main()