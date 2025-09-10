from centerbias import centerbiases_for_transformations
from metrics import NSS, IG
from numpy import mean, std, median
from pathlib import Path
from utilities import directories, load_centerbias, load_saliency_map, load_fixations, Table, get_transformation_name, load_real_saliency_map

def centerbias_comparison_benchmark(new_kernel_size: int, old_kernel_size: int) -> Table:
    """
    Run a comparison on a new centerbias with a different kernel size against an
    old centerbias using the difference in the NSS score and the information gain
    to evaluation the difference in performance of the two centerbiases.
    """
    centerbiases_for_transformations(sigma=new_kernel_size)
    centerbiases_for_transformations(sigma=old_kernel_size)
    output = Table(['transformation', 'mean_nss', 'mean_ig', 'median_nss', 'median_ig', 'std_nss', 'std_ig'])
    for directory in directories:
        new_centerbias = load_centerbias(directory, new_kernel_size)
        old_centerbias = load_centerbias(directory, old_kernel_size)
        data = { 'nss': [], 'ig': [] }
        for image_number in range(1, 101):
            fixations = load_fixations(directory, image_number)
            data['nss'].append(NSS(new_centerbias, fixations) - NSS(old_centerbias, fixations))
            data['ig'].append(IG(new_centerbias, old_centerbias, fixations))
        output.add_row({
            'transformation': get_transformation_name(directory),
            'mean_nss': mean(data['nss']),
            'mean_ig': mean(data['ig']),
            'median_nss': median(data['nss']),
            'median_ig': median(data['ig']),
            'std_nss': std(data['nss']),
            'std_ig': std(data['ig'])})
    return output

def centerbias_range_benchmark(maximum_kernel_size: int, csv_directory: str = 'centerbias_benchmarks'):
    """
    Run the `centerbias_benchmark` on a range of centerbias kernel sizes,
    and return the highest performing kernel size.
    """
    if not Path(csv_directory).exists():
        Path(csv_directory).mkdir(parents=True, exist_ok=True)
    best_kernel_size = 1
    for kernel_size in range(2, maximum_kernel_size + 1):
        output = centerbias_benchmark(kernel_size, best_kernel_size)
        output.to_csv(f'{csv_directory}/{kernel_size}_vs_{best_kernel_size}.csv')
        performance_aggregate = mean(output.get_column('mean_nss')) + mean(output.get_column('mean_ig'))
        if performance_aggregate > 0:
            best_kernel_size = kernel_size

def fixation_point_benchmarks(models: list[str], include_centerbias: bool = True, include_real: bool = True, centerbias_size: int = 57) -> Table:
    """
    Run NSS and IG benchmarks for a set of provided model saliency maps, identified
    by the name of the directory in which the saliency maps are stored. The IG metric
    will compare against the centerbias of the given kernel size.
    """
    if include_real:
        models += ['real']
    if include_centerbias:
        models += ['centerbias']
    output = Table(['transformation', 'model', 'mean_nss', 'mean_ig', 'median_nss', 'median_ig', 'std_nss', 'std_ig'])
    for directory in directories:
        centerbias = load_centerbias(directory, centerbias_size)
        for model in models:
            data = { 'nss': [], 'ig': [] }
            for image_number in range(1, 101):
                fixations = load_fixations(directory, image_number)
                if model == 'centerbias':
                    saliency_map = centerbias
                elif model == 'real':
                    saliency_map = load_real_saliency_map(directory, image_number)
                else:
                    saliency_map = load_saliency_map(directory, model, image_number)
                data['nss'].append(NSS(saliency_map, fixations))
                data['ig'].append(IG(saliency_map, centerbias, fixations))
            output.add_row({
                'transformation': get_transformation_name(directory),
                'model': model,
                'mean_nss': mean(data['nss']),
                'mean_ig': mean(data['ig']),
                'median_nss': median(data['nss']),
                'median_ig': median(data['ig']),
                'std_nss': std(data['nss']),
                'std_ig': std(data['ig'])})
    return output