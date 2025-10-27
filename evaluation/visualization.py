from csv import reader, DictReader
from dataset import directories_omitting
from matplotlib import pyplot
from numpy import linspace, polyfit, corrcoef, uint8, zeros
from PIL import Image
from random import seed, randint
from scipy.ndimage import gaussian_filter
from scipy.stats import zscore
from utilities import load_image, get_transformation_name

unisal_color = '#ff4040'
deepgaze_color = '#0000a0'

def fixation_map_example() -> None:
    seed(0)
    fixation_points = [(randint(0, 99), randint(0, 99)) for _ in range(15)]
    fixation_map = zeros((100, 100))
    for point in fixation_points:
        fixation_map[point] = 1
    fixation_map = fixation_map / fixation_map.max()
    Image.fromarray((fixation_map * 255).astype(uint8)).save("../docs/fixation_map_example.png")

def real_map_example() -> None:
    seed(0)
    fixation_points = [(randint(0, 99), randint(0, 99)) for _ in range(15)]
    fixation_map = zeros((100, 100))
    for point in fixation_points:
        fixation_map[point] = 1
    real_map = gaussian_filter(fixation_map, sigma=10.0)
    real_map = real_map / real_map.max()
    Image.fromarray((real_map * 255).astype(uint8)).save("../docs/real_map_example.png")

def transformation_examples() -> None:
    rows = 6
    columns = 3
    _, axes = pyplot.subplots(rows, columns)
    for row in range(rows):
        for column in range(columns):
            axes[row, column].axis('off')
    for index, directory in enumerate(directories_omitting(['Cropping_1', 'Cropping_2'])):
        row = index // columns
        column = index % columns
        transformation = get_transformation_name(directory)
        image = load_image(directory, 1)
        center = (image.shape[0] // 2, image.shape[1] // 2)
        window_size = 100
        slice_indices = (center[0] - window_size, center[0] + window_size, center[1] - window_size, center[1] + window_size)
        window = image[slice_indices[0]:slice_indices[1], slice_indices[2]:slice_indices[3]]
        axes[row, column].imshow(window)
        axes[row, column].set_title(transformation)
    pyplot.subplots_adjust(wspace=0, hspace=0.3)
    pyplot.show()

def performance_degradation(csv_file: str, unisal_model: str, deepgaze_model: str, metric: str) -> None:
    _, axes = pyplot.subplots(2, 5)
    data = { 'centerbias': {}, 'real': {}, unisal_model: {}, deepgaze_model: {} }
    with open(csv_file, 'r') as file:
        for row in DictReader(file):
            transformation = row['transformation']
            model_name = row['model']
            value = float(row[metric])
            if model_name in data:
                data[model_name][transformation] = value
    plots = {
        'Boundary': ('Reference', 'Boundary'),
        'Compression': ('Reference', 'Compression_1', 'Compression_2'),
        'Contrast Change': ('Reference', 'ContrastChange_1', 'ContrastChange_2'),
        'Cropping': ('Reference', 'Cropping_1', 'Cropping_2'),
        'Inversion': ('Reference', 'Inversion'),
        'Mirroring': ('Reference', 'Mirroring'),
        'Motion Blur': ('Reference', 'MotionBlur_1', 'MotionBlur_2'),
        'Noise': ('Reference', 'Noise_1', 'Noise_2'),
        'Rotation': ('Reference', 'Rotation_1', 'Rotation_2'),
        'Shearing': ('Reference', 'Shearing_1', 'Shearing_2', 'Shearing_3'),
    }
    max_value = 1.0
    min_value = float('inf')
    for model in [unisal_model, deepgaze_model]:
        for transformation in data[model]:
            centerbias_value = data['centerbias'][transformation]
            real_value = data['real'][transformation]
            value = data[model][transformation]
            value = (value - centerbias_value) / (real_value - centerbias_value)
            min_value = min(min_value, value)
            data[model][transformation] = value
    for (transformation_type, sequence), axis in zip(plots.items(), axes.flat):
        x = range(len(sequence))
        plot_settings = [
            (unisal_model, 'UNISAL', unisal_color, 0.7),
            (deepgaze_model, 'DeepGaze IIE', deepgaze_color, 0.85),
        ]
        for model, name, color, text_position in plot_settings:
            y = [data[model][transformation] for transformation in sequence]
            axis.plot(x, y, color=color)
            loss = y[-1] - y[0]
            axis.text(0, text_position, f"{name}: {loss:+.4f}", color=color)
        axis.set_xticks(x, sequence, rotation=25)
        axis.set_title(transformation_type)
    for axis in axes.flat:
        axis.set_ylim(min_value, max_value)
    pyplot.subplots_adjust(wspace=0.3, hspace=0.6)
    pyplot.show()

def all_performance_degradation() -> None:
    performance_degradation("../results/all_performance_averages.csv", "unisal_384_224", "deepgaze_1024_576", "mean_nss")
    performance_degradation("../results/all_performance_averages.csv", "unisal_384_224", "deepgaze_1024_576", "mean_ig")

def pairwise_correlations(
    unisal_csv_file: str,
    deepgaze_csv_file: str,
    independent_variable: str,
    dependent_variable: str,
    z_score_threshold: float = 3.0
) -> None:
    unisal_x = {}
    unisal_y = {}
    deepgaze_x = {}
    deepgaze_y = {}
    for x, y, csv_file in [(unisal_x, unisal_y, unisal_csv_file), (deepgaze_x, deepgaze_y, deepgaze_csv_file)]:
        with open(csv_file, 'r') as file:
            for row in DictReader(file):
                transformation = row['transformation']
                independent_value = float(row[independent_variable])
                dependent_value = float(row[dependent_variable])
                if transformation not in x:
                    x[transformation] = []
                    y[transformation] = []
                x[transformation].append(independent_value)
                y[transformation].append(dependent_value)
    max_y = float('-inf')
    max_x = float('-inf')
    min_y = float('inf')
    min_x = float('inf')
    for transformation in unisal_x:
        for data_x, data_y in [(unisal_x, unisal_y), (deepgaze_x, deepgaze_y)]:
            x_zscores = zscore(data_x[transformation])
            y_zscores = zscore(data_y[transformation])
            filtered_x = []
            filtered_y = []
            for index in range(100):
                if x_zscores[index] < z_score_threshold and y_zscores[index] < z_score_threshold:
                    filtered_x.append(data_x[transformation][index])
                    filtered_y.append(data_y[transformation][index])
                    max_y = max(max_y, data_y[transformation][index])
                    min_y = min(min_y, data_y[transformation][index])
                    max_x = max(max_x, data_x[transformation][index])
                    min_x = min(min_x, data_x[transformation][index])
            data_x[transformation] = filtered_x
            data_y[transformation] = filtered_y
    _, axes = pyplot.subplots(3, 6)
    for transformation, axis in zip(unisal_x.keys(), axes.flat):
        axis.set_title(transformation)
        plot_settings = [
            ('UNISAL', unisal_x, unisal_y, unisal_color),
            ('DeepGaze IIE', deepgaze_x, deepgaze_y, deepgaze_color),
        ]
        label = ""
        for model, x, y, color in plot_settings:
            correlation = corrcoef(x[transformation], y[transformation])[0, 1]
            label += f"{model}: {correlation:.2f}\n"
            slope, intercept = polyfit(x[transformation], y[transformation], 1)
            line = { 'x': [min_x, max_x], 'y': [slope * min_x + intercept, slope * max_x + intercept] }
            axis.scatter(x[transformation], y[transformation], color=color, alpha=0.1)
            axis.plot(line['x'], line['y'], color=color)
        axis.set_xlabel(label)
        axis.set_xlim(min_x, max_x)
        axis.set_ylim(min_y, max_y)
    pyplot.subplots_adjust(wspace=0.3, hspace=0.7)
    pyplot.show()

def strong_pairwise_correlations() -> None:
    pairs = [
        ('reference_nss', 'transformed_nss'),
        ('reference_ig', 'transformed_ig'),
        ('cc', 'transformed_nss'),
    ]
    for independent, dependent in pairs:
        pairwise_correlations(
            "../results/unisal_correlation_metrics.csv",
            "../results/deepgaze_correlation_metrics.csv",
            independent,
            dependent
        )

def all_pairwise_correlations() -> None:
    for independent_variable in ['ssim', 'cc', 'kl', 'reference_nss', 'reference_ig']:
        for dependent_variable in ['transformed_nss', 'transformed_ig']:
            pairwise_correlations(
                "../results/unisal_correlation_metrics.csv",
                "../results/deepgaze_correlation_metrics.csv",
                independent_variable,
                dependent_variable
            )

strong_pairwise_correlations()