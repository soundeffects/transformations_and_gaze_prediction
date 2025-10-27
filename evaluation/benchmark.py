from csv import DictReader
from centerbias import centerbiases_for_transformations
from dataset import directories, Table
from metrics import CC, KL, NSS, IG, SSIM
from numpy import mean, std, median, polyfit
from pathlib import Path
from scipy.stats import zscore
from utilities import load_centerbias, load_image, load_saliency_map, load_fixations, get_transformation_name, load_real_saliency_map

def fixation_point_averages(models: list[str], include_centerbias: bool = True, include_real: bool = True, centerbias_size: int = 57, logging: bool = False) -> Table:
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
                    saliency_map = load_saliency_map(directory, model, image_number, (1920, 1080))
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
            if logging:
                print(f"Finished {model} for {get_transformation_name(directory)}")
    return output

def all_fixation_point_averages(logging: bool = False) -> Table:
    """
    Run all fixation point benchmarks.
    """
    return fixation_point_averages(['deepgaze_1024_576', 'deepgaze_1920_1080', 'unisal_384_224', 'unisal_384_288', 'unisal_384_216', 'unisal_1920_1080'], logging=logging)

def correlation_metrics(model: str, logging: bool = False) -> Table:
    """
    Compute the correlation metrics (as described in section 4 of the readme) for a given model.
    """
    output = Table(['transformation', 'image_number', 'ssim', 'cc', 'kl', 'reference_nss', 'reference_ig', 'transformed_nss', 'transformed_ig'])
    transformations = []
    reference_directory = None
    for directory in directories:
        if 'Reference' in directory:
            reference_directory = directory
        else:
            transformations.append(directory)
    for transformation_directory in transformations:
        transformation_centerbias = load_centerbias(transformation_directory, 57)
        reference_centerbias = load_centerbias(reference_directory, 57)
        for image_number in range(1, 101):
            transformation = get_transformation_name(transformation_directory)
            transformed_image = load_image(transformation_directory, image_number)
            reference_image = load_image(reference_directory, image_number)
            ssim = SSIM(reference_image, transformed_image)
            transformed_saliency_map = load_saliency_map(transformation_directory, model, image_number, (1920, 1080))
            reference_saliency_map = load_saliency_map(reference_directory, model, image_number, (1920, 1080))
            cc = CC(transformed_saliency_map, reference_saliency_map)
            kl = KL(reference_saliency_map, transformed_saliency_map)
            reference_fixations = load_fixations(reference_directory, image_number)
            transformed_fixations = load_fixations(transformation_directory, image_number)
            reference_nss = NSS(reference_saliency_map, reference_fixations)
            reference_ig = IG(reference_saliency_map, reference_centerbias, reference_fixations)
            transformed_nss = NSS(transformed_saliency_map, transformed_fixations)
            transformed_ig = IG(transformed_saliency_map, transformation_centerbias, transformed_fixations)
            output.add_row({
                'transformation': transformation,
                'image_number': image_number,
                'ssim': ssim,
                'cc': cc,
                'kl': kl,
                'reference_nss': reference_nss,
                'reference_ig': reference_ig,
                'transformed_nss': transformed_nss,
                'transformed_ig': transformed_ig})
        if logging:
            print(f"Finished {transformation}")
    return output

def best_resolution_unisal(csv_path: str) -> None:
    """
    Find the best resolution for the UNISAL model, given a csv file of benchmark results.
    """
    NSS = {}
    IG = {}
    with open(csv_path, 'r', newline='') as csvfile:
        reader = DictReader(csvfile)
        for row in reader:
            if row['model'].startswith('unisal'):
                if row['model'] not in NSS:
                    NSS[row['model']] = { 'mean': [], 'median': [], 'std': [] }
                    IG[row['model']] = { 'mean': [], 'median': [], 'std': [] }
                NSS[row['model']]['mean'].append(float(row['mean_nss']))
                NSS[row['model']]['median'].append(float(row['median_nss']))
                NSS[row['model']]['std'].append(float(row['std_nss']))
                IG[row['model']]['mean'].append(float(row['mean_ig']))
                IG[row['model']]['median'].append(float(row['median_ig']))
                IG[row['model']]['std'].append(float(row['std_ig']))
    for model in NSS:
        print(model, mean(NSS[model]['mean']), mean(IG[model]['mean']), mean(NSS[model]['median']), mean(IG[model]['median']), mean(NSS[model]['std']), mean(IG[model]['std']))