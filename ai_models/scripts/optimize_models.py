import os
import logging
import onnx
from onnxsim import simplify

def optimize_onnx_model(input_path, output_path):
    try:
        model = onnx.load(input_path)
        model_simp, check = simplify(model)
        if not check:
            raise RuntimeError("Simplified ONNX model could not be validated")
        onnx.save(model_simp, output_path)
        logging.info(f"Optimized and saved ONNX model to {output_path}")
    except Exception as e:
        logging.error(f"Failed to optimize {input_path}: {e}")
        raise

def main():
    logging.basicConfig(level=logging.INFO)
    input_dir = os.getenv("ONNX_INPUT_DIR", "./mobile_models")
    output_dir = os.getenv("ONNX_OUTPUT_DIR", "./optimized_models")
    os.makedirs(output_dir, exist_ok=True)

    onnx_files = [f for f in os.listdir(input_dir) if f.endswith(".onnx")]
    if not onnx_files:
        logging.warning(f"No ONNX files found in {input_dir}")
        return

    for fname in onnx_files:
        input_path = os.path.join(input_dir, fname)
        output_path = os.path.join(output_dir, fname)
        try:
            optimize_onnx_model(input_path, output_path)
        except Exception:
            continue

if __name__ == "__main__":
    main()