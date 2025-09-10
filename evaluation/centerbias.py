from PIL import Image
from pathlib import Path
from numpy import float32, uint8, save, ndarray
from scipy.ndimage import gaussian_filter
from utilities import directories, load_fixation_map


def estimate_centerbias(directory_path: str, sigma: float = 1.0) -> ndarray:
    """
    Sum all fixation maps from a directory and apply Gaussian blur to the result.
    The result is interpreted as the center bias prior for the dataset. Note that
    it has been normalized to the range [0, 1], but it is not normalized as a
    valid probability distribution.
    """
    centerbias = None
    for image_number in range(1, 101):
        image = load_fixation_map(directory_path, image_number)
        if centerbias is None:
            centerbias = image
        else:
            centerbias += image
    
    centerbias = gaussian_filter(centerbias, sigma=sigma)
    centerbias = centerbias.astype(float32)
    centerbias = centerbias / centerbias.max()
    
    return centerbias

def centerbiases_for_transformations(sigma: float = 57.0) -> None:
    """
    Estimate the centerbias for each transformation in the dataset by averaging
    all fixation maps and applying a gaussian blur of kernel size `sigma`. Each
    centerbias is saved as a numpy array file and an image file.
    """
    for directory in directories:
        if (Path(directory) / f"centerbias_{sigma}.npy").exists():
            continue
        centerbias = estimate_centerbias(directory, sigma)
        save(f"{directory}/centerbias_{sigma}.npy", centerbias)
        Image.fromarray((centerbias * 255).astype(uint8)).save(f"{directory}/centerbias_{sigma}.png")