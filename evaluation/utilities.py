from csv import writer
from metrics import fixation_map_to_points, regularize
from numpy import array, exp, load, ndarray, float32
from PIL import Image
from pathlib import Path

directories = [
    "../data/Boundary",
    "../data/Compression_1",
    "../data/Compression_2",
    "../data/ContrastChange_1",
    "../data/ContrastChange_2",
    "../data/Cropping_1",
    "../data/Cropping_2",
    "../data/Inversion",
    "../data/Mirroring",
    "../data/MotionBlur_1",
    "../data/MotionBlur_2",
    "../data/Noise_1",
    "../data/Noise_2",
    "../data/Reference",
    "../data/Rotation_1",
    "../data/Rotation_2",
    "../data/Shearing_1",
    "../data/Shearing_2",
    "../data/Shearing_3",
]

def to_png(paths: list[Path], delete_original: bool = False) -> None:
    """
    Convert a set of images to PNG format.
    """
    for path in paths:
        with Image.open(path) as img:
            img.save(path.with_suffix('.png'), 'PNG')
        if delete_original:
            path.unlink()

def report_missing() -> None:
    """
    Scan the dataset for any missing image files, saliency maps, or
    fixation maps.
    """
    for directory in directories:
        for image_number in range(1, 101):
            if not (Path(directory) / "deepgaze" / f"{image_number}.npy").exists():
                print(f"Missing deepgaze saliency map for {image_number} in {directory}")
            if not (Path(directory) / "fixations" / f"{image_number}.png").exists():
                print(f"Missing fixation map for {image_number} in {directory}")
            if not (Path(directory) / "images" / f"{image_number}.png").exists():
                print(f"Missing image {image_number} in {directory}")
            if not (Path(directory) / "real" / f"{image_number}.png").exists():
                print(f"Missing real saliency map for {image_number} in {directory}")
            if not (Path(directory) / "unisal" / f"{image_number}.png").exists():
                print(f"Missing unisal saliency map for {image_number} in {directory}")
            if not (Path(directory) / "centerbias_57.npy").exists():
                print(f"Missing centerbias for {directory}")

def load_centerbias(directory: str, kernel_size: int = 57) -> ndarray:
    """
    Load a centerbias from the dataset.
    """
    return regularize(load(f"{directory}/centerbias_{kernel_size}.npy"))

def load_saliency_map(directory: str, model: str, image_number: int) -> ndarray:
    """
    Load a saliency map from the dataset.
    """
    return regularize(exp(load(f'{directory}/{model}/{image_number}.npy')))

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

def load_fixations(directory: str, image_number: int) -> list[tuple[int, int]]:
    """
    Load a set of fixation points from the dataset.
    """
    return fixation_map_to_points(load_fixation_map(directory, image_number))

class Table:
    """
    A table of data, useful for visualizing using matplotlib or saving to a CSV file.
    """
    def __init__(self, headers: list[str]):
        """
        Create a table with the given headers.
        """
        self.data = { header: [] for header in headers }

    def add_row(self, row: dict[str, float]) -> None:
        """
        Add a row to the table.
        """
        for header in self.data.keys():
            self.data[header].append(row[header])

    def to_csv(self, output_path: str = "benchmark.csv") -> None:
        """
        Save the table to a CSV file.
        """
        with open(output_path, 'w', newline='') as csvfile:
            output = writer(csvfile)
            output.writerow(self.data.keys())
            for i in range(len(self.data[next(iter(self.data.keys()))])):
                output.writerow([self.data[header][i] for header in self.data.keys()])

    def get_column(self, column: str) -> list[float]:
        """
        Get a column from the table.
        """
        return self.data[column]

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