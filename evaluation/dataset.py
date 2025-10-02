from csv import writer, DictReader
from pathlib import Path
from PIL import Image
from typing import List
from zipfile import ZipFile, ZIP_DEFLATED

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
    with ZipFile(output_path, 'w', ZIP_DEFLATED, compresslevel=6) as output_file:
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

    def load_csv(self, input_path: str) -> None:
        """
        Load a table from a CSV file.
        """
        with open(input_path, 'r', newline='') as csvfile:
            reader = DictReader(csvfile)
            self.data = { header: [] for header in reader.fieldnames }
            for row in reader:
                self.add_row(row)

    def get_column(self, column: str) -> list[float]:
        """
        Get a column from the table.
        """
        return self.data[column]