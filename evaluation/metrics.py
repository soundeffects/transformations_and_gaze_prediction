from numpy import ndarray, log2, corrcoef
from scipy.special import kl_div
from skimage.metrics import structural_similarity

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
    total_score = 0.0
    for x, y in fixation_points:
        total_score += normalized_map[x, y]
    return total_score / len(fixation_points)

def CC(saliency_1: ndarray, saliency_2: ndarray) -> float:
    """
    Pearson's Correlation Coefficient (CC) is used to evaluate the
    correlation or dependence of any two variables. For a fair
    comparison between saliency maps, both saliency maps should be
    regularized to a valid probability distribution, and both should
    encode information on similar frequency bandwiths: if one signal
    contains higher frequency information than the other, ensure that
    high frequency information is controlled using a low-pass (Gaussian) 
    filter.
    """
    return corrcoef(saliency_1.flatten(), saliency_2.flatten())[0, 1]

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

def KL(ground_truth: ndarray, prediction: ndarray) -> float:
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
    return kl_div(ground_truth, prediction).sum()

def SSIM(reference: ndarray, transformed: ndarray) -> float:
    """
    Structural Similarity Index (SSIM) is a metric for evaluating the
    similarity between two images.
    """
    return structural_similarity(reference, transformed, data_range=transformed.max() - transformed.min(), channel_axis=2)