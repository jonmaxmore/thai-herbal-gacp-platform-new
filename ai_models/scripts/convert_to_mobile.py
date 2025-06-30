import os
import torch
import onnx
from pathlib import Path
import logging

def convert_pytorch_to_onnx(
    model,
    dummy_input,
    output_path,
    input_names=None,
    output_names=None,
    opset_version=17,
    dynamic_axes=None
):
    torch.onnx.export(
        model,
        dummy_input,
        output_path,
        export_params=True,
        opset_version=opset_version,
        do_constant_folding=True,
        input_names=input_names or ["input"],
        output_names=output_names or ["output"],
        dynamic_axes=dynamic_axes or {"input": {0: "batch_size"}, "output": {0: "batch_size"}},
    )
    logging.info(f"Exported ONNX model to {output_path}")

def validate_onnx_model(onnx_path):
    model = onnx.load(onnx_path)
    onnx.checker.check_model(model)
    logging.info(f"ONNX model at {onnx_path} is valid.")

def main():
    logging.basicConfig(level=logging.INFO)
    model_dir = os.getenv("MODEL_DIR", "./models")
    output_dir = os.getenv("OUTPUT_DIR", "./mobile_models")
    os.makedirs(output_dir, exist_ok=True)

    # Load model config from environment or config file
    model_name = os.getenv("MODEL_NAME", "vit_best.pth")
    num_classes = int(os.getenv("NUM_CLASSES", 10))
    onnx_filename = os.getenv("ONNX_FILENAME", "vit_mobile.onnx")

    # Import model class dynamically if needed
    from vit_pytorch import ViT
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
    )
    model_path = os.path.join(model_dir, model_name)
    if not os.path.exists(model_path):
        logging.error(f"Model file not found: {model_path}")
        raise FileNotFoundError(f"Model file not found: {model_path}")

    state_dict = torch.load(model_path, map_location="cpu")
    model.load_state_dict(state_dict)
    model.eval()

    dummy_input = torch.randn(1, 3, 224, 224)
    output_path = os.path.join(output_dir, onnx_filename)
    convert_pytorch_to_onnx(
        model,
        dummy_input,
        output_path,
        input_names=["input"],
        output_names=["output"],
        opset_version=17,
        dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
    )
    validate_onnx_model(output_path)

if __name__ == "__main__":
    main()