from numpy import ndarray, ndindex, log2, cov

def regularize(saliency_map: ndarray) -> ndarray:
    """
    Regularize the saliency map to a valid probability distribution,
    which additionally does not have any zero probability regions,
    which are unlikely in real-world gaze distributions and which
    overly punish both KL-divergence and information gain metrics
    because of logarithmic function behavior approaching negative
    infinity for small probability values.
    """
    regularized = saliency_map - min(0.0, saliency_map.min()) + 1e-9
    return regularized / regularized.sum()

def fixation_map_to_points(fixation_map: ndarray) -> list[tuple[int, int]]:
    """
    Convert a fixation map (a black image with white pixels marking
    fixation locations) to a list of points.
    """
    return [(x, y) for x, y in ndindex(fixation_map.shape) if fixation_map[x, y] > 0]

def NSS(saliency_map: ndarray, fixation_points: list[tuple[int, int]]) -> float:
    """
    Normalized Scanpath Saliency (NSS) is a metric for evaluating
    the correspondence of a saliency map with a discrete set of
    fixation points. This metric has a normalization scheme as part
    of its calculation, and does not require the saliency map to be
    regularized. Positive values indicate correspondence, negative
    values indicate anti-correspondence.
    """
    normalized_map = (saliency_map - saliency_map.mean()) / saliency_map.std()
    total_correlation = 0.0
    for x, y in fixation_points:
        total_correlation += normalized_map[x, y]
    return total_correlation / len(fixation_points)

def CC(saliency_1: ndarray, saliency_2: ndarray) -> float:
    """
    Pearson's Correlation Coefficient (CC) is used to evaluate the
    correlation or dependence of any two variables. For a fair
    comparison between saliency maps, both saliency maps should be
    regularized to a valid probability distribution, and both should
    encode information on similar frequency bandwiths: ensure that
    high frequency information is controlled for both saliency maps
    by using a low-pass (Gaussian) filter with similar kernel size.
    """
    return cov(saliency_1, saliency_2)[0, 1] / (saliency_1.std() * saliency_2.std())

def IG(saliency_map: ndarray, baseline: ndarray, fixation_points: list[tuple[int, int]]) -> float:
    """
    Information Gain (IG) is a metric for evaluating the performance
    of a saliency map over a baseline saliency map in predicting a set
    of gaze fixation points. For a fair comparison, both saliency maps
    should be regularized such that no zero probability regions exist.
    Positive values indicate that the saliency map is a better predictor
    than the baseline, while negative values indicate the opposite.
    """
    total_gain = 0.0
    for x, y in fixation_points:
        total_gain += log2(saliency_map[x, y]) - log2(baseline[x, y])
    return total_gain / len(fixation_points)

def KL(saliency_1: ndarray, saliency_2: ndarray) -> float:
    """
    Kullback-Leibler Divergence (KL) is a metric for evaluating the
    divergence between two saliency maps by number of information bits.
    For a fair comparison, both saliency maps should be regularized to
    a valid probability distribution, such that no zero probability
    regions exist. Additionally, both saliency maps should encode
    information on similar frequency bandwiths: ensure that high
    frequency information is controlled for both saliency maps by
    using a low-pass (Gaussian) filter with similar kernel size.
    
    Note that the KL divergence is not a symmetric metric, so the order
    of the saliency maps matters.
    """
    return (saliency_1 * log2(saliency_1 / saliency_2)).sum()
