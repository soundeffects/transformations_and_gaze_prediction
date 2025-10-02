from csv import DictReader
from re import X
from numpy import mean, ndarray

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

def build_ancova_matrix() -> ndarray:
    # for every transformation:
    # image difference metric
    # reference-transform prediction CC
    # reference-transform prediction KL
    # reference prediction NSS
    # reference prediction IG
    # reference centerbias NSS
    # transformed prediction NSS
    # transformed prediction IG
    # transformed centerbias NSS
    pass