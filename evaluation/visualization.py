from csv import reader
from matplotlib import pyplot
from numpy import polyfit, corrcoef
from scipy.stats import zscore

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

visualize_correlations("../results/correlation_metrics.csv")