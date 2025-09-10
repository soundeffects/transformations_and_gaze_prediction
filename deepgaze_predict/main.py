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
        model = DeepGazeIIE(pretrained=True).to(DEVICE)
        centerbias_template = load(centerbias_path)
        centerbias_x, centerbias_y = centerbias_template.shape
        cuda.empty_cache()
        for image_path in image_paths:
            output_path = Path(str(image_path).replace('images', 'deepgaze').replace('png', 'npy'))
            if output_path.exists():
                continue
            try:
                image_data = array(Image.open(image_path)).transpose(2, 0, 1) / 255
            except:
                print("failed", str(image_path))
                continue
            image_x, image_y = image_data.shape[1], image_data.shape[2]
            image_tensor = tensor(image_data).unsqueeze(0).type(FloatTensor).to(DEVICE)
            scaled_shape = (image_x / centerbias_x, image_y / centerbias_y)
            centerbias = zoom(centerbias_template, scaled_shape, order=0, mode='nearest')
            centerbias_tensor = tensor(centerbias).unsqueeze(0).type(FloatTensor).to(DEVICE)
            log_density = model(image_tensor, centerbias_tensor).detach().cpu().squeeze()
            density = array(log_density)
            output_path.parents[0].mkdir(parents=True, exist_ok=True)
            save(output_path, density)

def predict_dataset() -> None:
    """
    Predict the saliency map for all images in the dataset at `../data` using the DeepGazeIIE model.
    """
    for directory in Path("../data").iterdir():
        image_paths = [ directory / "images" / f"{image_number}.png" for image_number in range(1, 101) ]
        centerbias_path = directory / "centerbias_57.npy"
        predict(image_paths, centerbias_path)