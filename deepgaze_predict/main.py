from deepgaze_pytorch import DeepGazeIIE
from numpy import load, array, save
from pathlib import Path
from PIL import Image
from scipy.ndimage import zoom
from torch import tensor, FloatTensor, cuda, no_grad

DEVICE = 'cuda'

def predict(image_paths: list[Path], centerbias_path: Path) -> None:
    """
    Predict the saliency map for a set of images using the DeepGazeIIE model.
    """
    with no_grad():
        model = DeepGazeIIE(pretrained=True)
        model.to(DEVICE)
        model.eval()
        centerbias_template = load(centerbias_path)
        centerbias_x, centerbias_y = centerbias_template.shape
        cuda.empty_cache()
        for image_path in image_paths:
            output_path = Path(str(image_path).replace('images', 'deepgaze').replace('png', 'npy'))
            if output_path.exists():
                continue
            try:
                image_data = array(Image.open(image_path))
            except:
                print("failed", str(image_path))
                continue
            image_x, image_y, _ = image_data.shape
            image_tensor = tensor(image_data.transpose(2, 0, 1) / 255).unsqueeze(0).type(FloatTensor)
            image_tensor.to(DEVICE)
            scaled_shape = (image_x / centerbias_x, image_y / centerbias_y)
            centerbias = zoom(centerbias_template, scaled_shape, order=0, mode='nearest')
            centerbias_tensor = tensor(centerbias).unsqueeze(0).type(FloatTensor)
            centerbias_tensor.to(DEVICE)
            prediction = model(image_tensor, centerbias_tensor)
            detached_prediction = array(prediction.detach().cpu().squeeze()) # TODO: Check return value of these functions
            output_path.parent.mkdir(parents=True, exist_ok=True)
            save(output_path, detached_prediction)

def predict_dataset() -> None:
    """
    Predict the saliency map for all images in the dataset at `../data` using the DeepGazeIIE model.
    """
    for directory in Path("../data").iterdir():
        image_paths = [ directory / "images" / f"{image_number}.png" for image_number in range(1, 101) ]
        centerbias_path = directory / "centerbias_57.npy"
        predict(image_paths, centerbias_path)