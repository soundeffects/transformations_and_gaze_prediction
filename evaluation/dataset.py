import zipfile
from pathlib import Path
from typing import List

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

def zip_paths(base_path: Path, paths: List[Path], output_path: str) -> None:
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as output_file:
        for path in paths:
            for file in path.rglob('*'):
                if file.is_file():
                    output_file.write(file, file.relative_to(base_path))

def zip_images_and_fixations(output_path: str = "../dataset.zip") -> None:
    paths = []
    for directory in directories:
        paths.append(Path(directory) / "images")
        paths.append(Path(directory) / "fixations")
    zip_paths(Path("../data"), paths, output_path)

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