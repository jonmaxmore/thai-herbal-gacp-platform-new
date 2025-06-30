import os
import torch
import logging
from ultralytics import YOLO
from data_augmentation import augment_yolo_dataset

def main():
    logging.basicConfig(level=logging.INFO)
    data_dir = os.getenv('YOLO_DATASET_DIR', './dataset')
    model_dir = os.getenv('YOLO_MODEL_DIR', './models')
    epochs = int(os.getenv('YOLO_EPOCHS', 100))
    batch_size = int(os.getenv('YOLO_BATCH_SIZE', 16))
    pretrained = os.getenv('YOLO_PRETRAINED', 'yolov8n.pt')
    imgsz = int(os.getenv('YOLO_IMAGE_SIZE', 640))
    project_name = os.getenv('YOLO_PROJECT_NAME', 'yolo_trained')
    device = 0 if torch.cuda.is_available() else 'cpu'

    # Data augmentation
    logging.info("Starting data augmentation...")
    augment_yolo_dataset(data_dir)
    logging.info("Data augmentation completed.")

    # Training
    logging.info("Starting YOLO training...")
    model = YOLO(pretrained)
    results = model.train(
        data=os.path.join(data_dir, 'data.yaml'),
        epochs=epochs,
        batch=batch_size,
        imgsz=imgsz,
        project=model_dir,
        name=project_name,
        exist_ok=True,
        device=device
    )
    logging.info("YOLO training completed.")

    # Export best model to ONNX
    best_weights_dir = os.path.join(model_dir, project_name, 'weights')
    best_pt_path = os.path.join(best_weights_dir, 'best.pt')
    best_onnx_path = os.path.join(best_weights_dir, 'best.onnx')
    if os.path.exists(best_pt_path):
        logging.info(f"Exporting best model to ONNX: {best_onnx_path}")
        model = YOLO(best_pt_path)
        model.export(format='onnx', dynamic=True, simplify=True, imgsz=imgsz, half=False, device=device)
        logging.info(f"Exported ONNX model to {best_onnx_path}")
    else:
        logging.error(f"Best model not found at {best_pt_path}")

if __name__ == "__main__":
    main()