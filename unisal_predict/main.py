from numpy import array, save
from pathlib import Path
from PIL import Image
from torch import no_grad, cuda, from_numpy
from patched_unisal import UNISAL

DEVICE = 'cuda'

def predict(image_paths: list[Path], resolution: (int, int), output_name: str, finetuned: bool = False) -> None:
    """
    Predict the saliency map for a set of images using the UNISAL model. Rescales images to be the resolution
    provided, in the order of (width, height).
    """
    unisal = UNISAL(sources=("DHF1K", "Hollywood", "UCFSports", "SALICON"))
    if finetuned:
        unisal.load_weights(Path("unisal/training_runs/pretrained_unisal"), "ft_mit1003")
    else:
        unisal.load_best_weights(Path("unisal/training_runs/pretrained_unisal"))
    unisal.to(DEVICE)
    unisal.eval()
    cuda.empty_cache()
    with no_grad():
        for image_path in image_paths:
            output_path = Path(str(image_path).replace('images', output_name).replace('png', 'npy'))
            image = Image.open(image_path)
            image = image.resize(resolution, Image.Resampling.LANCZOS)
            image_data = array(image) / 255
            batch = from_numpy(image_data).permute(2, 0, 1).unsqueeze(0).unsqueeze(0).float().to(DEVICE)
            prediction = unisal(batch, source="SALICON") # The static image data UNISAL was trained on was from SALICON
            prediction = prediction.squeeze(0).squeeze(0).squeeze(0).cpu().detach().numpy()
            output_path.parent.mkdir(parents=True, exist_ok=True)
            save(output_path, prediction)

def predict_dataset(model_resolution: (int, int), output_name: str, finetuned: bool = False) -> None:
    """
    Predict the saliency map for all images in the dataset at `../data` using the UNISAL model. Rescales images to be the resolution
    provided, in the order of (width, height).
    """
    for directory in Path("../data").iterdir():
        image_paths = [ directory / "images" / f"{image_number}.png" for image_number in range(1, 101) ]
        predict(image_paths, model_resolution, output_name, finetuned)

def predict_predefined_resolutions() -> None:
    """
    Predict the saliency map for all images in the dataset at `../data` using the UNISAL model for predefined resolutions.
    """
    predict_dataset((384, 224), "unisal_384_224")
    predict_dataset((384, 288), "unisal_384_288")
    predict_dataset((384, 216), "unisal_384_216")
    predict_dataset((1920, 1080), "unisal_1920_1080")

predict_predefined_resolutions()