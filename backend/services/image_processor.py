from PIL import Image, ImageOps, ImageEnhance
import numpy as np
import io
from typing import Tuple, Optional, Dict

class ImageProcessor:
    """
    Production-ready image processing utility for AI pipeline.
    """

    @staticmethod
    def load_image(image_bytes: bytes) -> Image.Image:
        """Load image from bytes and convert to RGB."""
        return Image.open(io.BytesIO(image_bytes)).convert("RGB")

    @staticmethod
    def resize(image: Image.Image, size: Tuple[int, int] = (224, 224)) -> Image.Image:
        """Resize image to target size."""
        return image.resize(size)

    @staticmethod
    def normalize(image: Image.Image) -> np.ndarray:
        """Normalize image to [0, 1] and apply ImageNet mean/std."""
        arr = np.array(image).astype(np.float32) / 255.0
        if arr.ndim == 2:
            arr = np.stack([arr] * 3, axis=-1)
        arr = arr.transpose(2, 0, 1)
        mean = np.array([0.485, 0.456, 0.406]).reshape(3, 1, 1)
        std = np.array([0.229, 0.224, 0.225]).reshape(3, 1, 1)
        arr = (arr - mean) / std
        return arr

    @staticmethod
    def augment(image: Image.Image, mode: Optional[str] = None) -> Image.Image:
        """Apply augmentation (flip, rotate, color jitter) if mode specified."""
        if mode == "flip":
            return ImageOps.mirror(image)
        elif mode == "rotate":
            return image.rotate(15)
        elif mode == "enhance":
            enhancer = ImageEnhance.Contrast(image)
            return enhancer.enhance(1.2)
        return image

    @staticmethod
    def preprocess(
        image_bytes: bytes,
        size: Tuple[int, int] = (224, 224),
        augment_mode: Optional[str] = None
    ) -> np.ndarray:
        """
        Full pipeline: load, resize, augment, normalize, and add batch dimension.
        """
        image = ImageProcessor.load_image(image_bytes)
        image = ImageProcessor.resize(image, size)
        image = ImageProcessor.augment(image, augment_mode)
        arr = ImageProcessor.normalize(image)
        arr = np.expand_dims(arr, axis=0)
        return arr

    @staticmethod
    def get_image_info(image: Image.Image) -> Dict:
        """Return basic info about the image."""
        return {
            "size": image.size,
            "mode": image.mode,
            "format": image.format,
        }

    @staticmethod
    def save_image(image: Image.Image, path: str, format: str = "JPEG", quality: int = 90) -> None:
        """Save image to disk with specified format and quality."""
        image.save(path, format=format, quality=quality, optimize=True)

    @staticmethod
    def to_bytes(image: Image.Image, format: str = "JPEG", quality: int = 90) -> bytes:
        """Convert PIL Image to bytes."""
        buf = io.BytesIO()
        image.save(buf, format=format, quality=quality, optimize=True)
        return buf.getvalue()