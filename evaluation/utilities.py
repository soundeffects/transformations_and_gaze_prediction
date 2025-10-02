from metrics import regularize
from numpy import array, exp, load, ndarray, float32, ndindex
from PIL import Image
from scipy.ndimage import zoom

def load_centerbias(directory: str, kernel_size: int = 57) -> ndarray:
    """
    Load a centerbias from the dataset.
    """
    return regularize(load(f"{directory}/centerbias_{kernel_size}.npy"))

def load_saliency_map(directory: str, model: str, image_number: int, resolution: (int, int)) -> ndarray:
    """
    Load a saliency map from the dataset. Resize the image to the given resolution, specified in the
    order of (width, height).
    """
    numpy_resolution = (resolution[1], resolution[0])
    saliency_map = exp(load(f'{directory}/{model}/{image_number}.npy'))
    if saliency_map.shape != resolution:
        shape_scaling = (numpy_resolution[0] / saliency_map.shape[0], numpy_resolution[1] / saliency_map.shape[1])
        saliency_map = zoom(saliency_map, shape_scaling)
    return regularize(saliency_map)

def load_real_saliency_map(directory: str, image_number: int) -> ndarray:
    """
    Load a saliency image from the dataset.
    """
    return regularize(array(Image.open(f'{directory}/real/{image_number}.png')))

def load_fixation_map(directory: str, image_number: int) -> ndarray:
    """
    Load a fixation map from the dataset.
    """
    image = Image.open(f"{directory}/fixations/{image_number}.png")
    image = image.convert("L")
    image = array(image)
    image = image.astype(float32) / 255.0
    return image

def fixation_map_to_points(fixation_map: ndarray) -> list[tuple[int, int]]:
    """
    Convert a fixation map (a black image with white pixels marking
    fixation locations) to a list of points.
    """
    return [(x, y) for x, y in ndindex(fixation_map.shape) if fixation_map[x, y] > 0]

def load_fixations(directory: str, image_number: int) -> list[tuple[int, int]]:
    """
    Load a set of fixation points from the dataset.
    """
    return fixation_map_to_points(load_fixation_map(directory, image_number))

def load_image(directory: str, image_number: int) -> ndarray:
    """
    Load an image from the dataset.
    """
    return array(Image.open(f'{directory}/images/{image_number}.png'))

def get_transformation_name(directory: str) -> str:
    """
    Get the name of a transformation from the directory path string.
    """
    return directory.split('/')[-1]

def normalize_to_range(image: ndarray, min_value: float = 0.0, max_value: float = 1.0) -> ndarray:
    """
    Normalize the image to the range [min_value, max_value].
    """
    return (image - min(0.0, image.min())) / (max(0.0, image.max()) - min(0.0, image.min())) * (max_value - min_value) + min_value