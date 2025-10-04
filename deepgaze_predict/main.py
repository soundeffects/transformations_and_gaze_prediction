from deepgaze_pytorch import DeepGazeIIE
from numpy import exp, load, array, save
from pathlib import Path
from PIL import Image
from scipy.ndimage import zoom
from scipy.special import logsumexp
from torch import tensor, FloatTensor, cuda, no_grad

DEVICE = 'cuda'

def predict(image_paths: list[Path], centerbias_path: Path, resolution: (int, int), output_name: str) -> None:
    """
    Predict the saliency map for a set of images using the DeepGazeIIE model. Rescales images to be the resolution
    provided, in the order of (width, height).
    """
    numpy_resolution = (resolution[1], resolution[0])
    with no_grad():
        model = DeepGazeIIE(pretrained=True)
        model.to(DEVICE)
        model.eval()
        cuda.empty_cache()
        centerbias = load(centerbias_path)
        shape_scaling = (numpy_resolution[0] / centerbias.shape[0], numpy_resolution[1] / centerbias.shape[1])
        centerbias = zoom(centerbias, shape_scaling)
        centerbias -= logsumexp(centerbias)
        centerbias_tensor = tensor(centerbias).unsqueeze(0).type(FloatTensor).to(DEVICE)
        for image_path in image_paths:
            output_path = Path(str(image_path).replace('images', output_name).replace('png', 'npy'))
            image = Image.open(image_path)
            image = image.resize(resolution, Image.Resampling.LANCZOS)
            image_data = array(image) / 255
            image_tensor = tensor(image_data.transpose(2, 0, 1)).unsqueeze(0).type(FloatTensor)
            image_tensor = image_tensor.to(DEVICE)
            prediction = model(image_tensor, centerbias_tensor)
            detached_prediction = prediction.detach().cpu().squeeze().numpy()
            output_path.parent.mkdir(parents=True, exist_ok=True)
            save(output_path, detached_prediction)

def predict_dataset(resolution: (int, int), output_name: str) -> None:
    """
    Predict the saliency map for all images in the dataset at `../data` using the DeepGazeIIE model. Rescales images to be the resolution
    provided, in the order of (width, height).
    """
    for directory in Path("../data").iterdir():
        image_paths = [ directory / "images" / f"{image_number}.png" for image_number in range(1, 101) ]
        centerbias_path = directory / "centerbias_57.npy"
        predict(image_paths, centerbias_path, resolution, output_name)

def predict_predefined_resolutions() -> None:
    """
    Predict the saliency map for all images in the dataset at `../data` using the DeepGazeIIE model for predefined resolutions.
    """
    predict_dataset((1024, 576), "deepgaze_1024_576")

if __name__ == "__main__":
    predict_predefined_resolutions()