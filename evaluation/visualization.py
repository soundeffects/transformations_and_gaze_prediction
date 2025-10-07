from csv import reader
from dataset import directories_omitting
from matplotlib import pyplot
from numpy import linspace, polyfit, corrcoef, uint8, zeros
from PIL import Image
from random import seed, randint
from scipy.ndimage import gaussian_filter
from scipy.stats import zscore
from utilities import load_image, get_transformation_name

def visualize_correlations(csv_file: str, z_score_threshold: float = 3.0) -> None:
    """
    Visualize the correlations between the reference and transformed saliency maps.
    """
    transformations = {}
    table_row_labels = []
    with open(csv_file, 'r') as file:
        rows = reader(file)
        next(rows)
        for row in rows:
            transformation = row[0]
            if transformation not in transformations:
                transformations[transformation] = { 'ssim': [], 'cc': [], 'kl': [], 'reference_nss': [], 'reference_ig': [], 'transformed_nss': [], 'transformed_ig': [] }
                table_row_labels.append(transformation)
            for index, statistic in enumerate(transformations[transformation].keys()):
                transformations[transformation][statistic].append(float(row[index + 2]))
    table_rows = []
    table_headers = []
    for transformation in transformations:
        zscores = {}
        for statistic in transformations[transformation]:
            zscores[statistic] = zscore(transformations[transformation][statistic])
        rows = 2
        columns = 5
        figure, axes = pyplot.subplots(rows, columns)
        figure.suptitle(transformation)
        table_row = []
        def plot_data(stat_1: str, stat_2: str) -> tuple[list[float], list[float], str, str]:
            x = []
            y = []
            for index in range(len(transformations[transformation][stat_1])):
                zscore_1 = zscores[stat_1][index]
                zscore_2 = zscores[stat_2][index]
                if zscore_1 < z_score_threshold and zscore_2 < z_score_threshold:
                    x.append(transformations[transformation][stat_1][index])
                    y.append(transformations[transformation][stat_2][index])
            return x, y, stat_1, stat_2
        plots = [
            plot_data('ssim', 'transformed_nss'),
            plot_data('cc', 'transformed_nss'),
            plot_data('kl', 'transformed_nss'),
            plot_data('reference_nss', 'transformed_nss'),
            plot_data('reference_ig', 'transformed_nss'),
            plot_data('ssim', 'transformed_ig'),
            plot_data('cc', 'transformed_ig'),
            plot_data('kl', 'transformed_ig'),
            plot_data('reference_nss', 'transformed_ig'),
            plot_data('reference_ig', 'transformed_ig'),
        ]
        for index, (x, y, x_label, y_label) in enumerate(plots):
            row = index // columns
            column = index % columns
            table_header = f'{x_label},{y_label}'
            table_headers.append(table_header)
            correlation = corrcoef(x, y)[0, 1]
            slope, intercept = polyfit(x, y, 1)
            table_row.append(f'{correlation:.2f}')
            axes[row, column].scatter(x, y)
            axes[row, column].plot([min(x), max(x)], [slope * min(x) + intercept, slope * max(x) + intercept])
            axes[row, column].set_xlabel(f'{x_label}\n(CC: {correlation:.2f})')
            axes[row, column].set_ylabel(y_label)
            axes[row, column].set_title(table_header)
            axes[row, column].grid()
        table_rows.append(table_row)
        pyplot.subplots_adjust(hspace=0.5, wspace=0.5)
        pyplot.show()
    print(f'transformation, {",".join(table_headers)}')
    for index, table_row in enumerate(table_rows):
        print(f'{table_row_labels[index]}, {",".join(table_row)}')

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

def performance_degradation(csv_file: str, model: str, metric: str) -> None:
    rows = 2
    columns = 5
    _, axes = pyplot.subplots(rows, columns)
    model_performance = {}
    centerbias_performance = {}
    real_performance = {}
    with open(csv_file, 'r') as file:
        rows = reader(file)
        next(rows)
        for row in rows:
            transformation = row[0]
            model_name = row[1]
            value = None
            if metric == 'nss':
                value = float(row[2])
            elif metric == 'ig':
                value = float(row[3])
            if model_name == model:
                model_performance[transformation] = value
            elif model_name == 'centerbias':
                centerbias_performance[transformation] = value
            elif model_name == 'real':
                real_performance[transformation] = value
    plots = [
        ('Reference', 'Boundary'),
        ('Reference', 'Compression_1', 'Compression_2'),
        ('Reference', 'ContrastChange_1', 'ContrastChange_2'),
        ('Reference', 'Cropping_1', 'Cropping_2'),
        ('Reference', 'Inversion'),
        ('Reference', 'Mirroring'),
        ('Reference', 'MotionBlur_1', 'MotionBlur_2'),
        ('Reference', 'Noise_1', 'Noise_2'),
        ('Reference', 'Rotation_1', 'Rotation_2'),
        ('Reference', 'Shearing_1', 'Shearing_2', 'Shearing_3'),
    ]
    for index, plot in enumerate(plots):
        row = index // columns
        column = index % columns
        x = [ i for i in range(len(plot)) ]
        model_y = [ model_performance[transformation] for transformation in plot ]
        centerbias_y = [ centerbias_performance[transformation] for transformation in plot ]
        real_y = [ real_performance[transformation] for transformation in plot ]
        axes[row, column].plot(x, model_y)
        axes[row, column].plot(x, centerbias_y, color='red')
        axes[row, column].plot(x, real_y, color='green')
        axes[row, column].fill_between(x, centerbias_y, real_y, color='red', alpha=0.2)
        axes[row, column].set_xticks(x, plot, rotation=70)
        axes[row, column].set_title(f'{plot[0]} to {plot[-1]}')
    pyplot.subplots_adjust(wspace=0.3, hspace=0.6)
    pyplot.show()

def pairwise_correlations(csv_file: str, stat_1: str, stat_2: str, z_score_threshold: float = 3.0) -> None:
    x_values = {}
    y_values = {}
    with open(csv_file, 'r') as file:
        rows = reader(file)
        headers = next(rows)
        stat_1_index = headers.index(stat_1)
        stat_2_index = headers.index(stat_2)
        for row in rows:
            transformation = row[0]
            if transformation not in x_values:
                x_values[transformation] = []
                y_values[transformation] = []
            x_values[transformation].append(float(row[stat_1_index]))
            y_values[transformation].append(float(row[stat_2_index]))
    rows = 3
    columns = 6
    _, axes = pyplot.subplots(rows, columns)
    for index, transformation in enumerate(x_values):
        row = index // columns
        column = index % columns
        x_zscores = zscore(x_values[transformation])
        y_zscores = zscore(y_values[transformation])
        x = []
        y = []
        for i in range(len(x_values[transformation])):
            if x_zscores[i] < z_score_threshold and y_zscores[i] < z_score_threshold:
                x.append(x_values[transformation][i])
                y.append(y_values[transformation][i])
        correlation = corrcoef(x, y)[0, 1]
        slope, intercept = polyfit(x, y, 1)
        line = { 'x': [min(x), max(x)], 'y': [slope * min(x) + intercept, slope * max(x) + intercept] }
        quadratic_delta, linear_delta, intercept = polyfit(x, y, 2)
        curve = { 'x': [], 'y': [] }
        for x_value in linspace(min(x), max(x), 100):
            curve['x'].append(x_value)
            curve['y'].append(quadratic_delta * x_value**2 + linear_delta * x_value + intercept)
        axes[row, column].scatter(x, y, alpha=0.5)
        axes[row, column].plot(line['x'], line['y'], color='red', alpha=0.5)
        axes[row, column].plot(curve['x'], curve['y'], color='red')
        axes[row, column].set_xlabel(f"(CC: {correlation:.2f})")
        axes[row, column].set_title(transformation)
        print(f'{transformation}, {correlation:.2f}, {quadratic_delta:.2f}')
    pyplot.subplots_adjust(wspace=0.3, hspace=0.6)
    pyplot.show()

pairwise_correlations("../results/unisal_correlation_metrics.csv", "reference_nss", "transformed_nss")
pairwise_correlations("../results/unisal_correlation_metrics.csv", "reference_ig", "transformed_ig")