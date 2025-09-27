import zipfile
from pathlib import Path
from PIL import Image
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