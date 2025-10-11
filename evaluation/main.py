from benchmark import all_fixation_point_averages, correlation_metrics
from visualization import all_performance_degradation, all_pairwise_correlations, visualize_correlations

logging = True
all_correlations = False
all_fixation_point_averages(logging=logging).to_csv("../results/all_fixation_point_averages.csv")
correlation_metrics("deepgaze_1024_576", logging=logging).to_csv("../results/deepgaze_correlation_metrics.csv")
correlation_metrics("unisal_384_224", logging=logging).to_csv("../results/unisal_correlation_metrics.csv")
all_performance_degradation()
if all_correlations:
    visualize_correlations("../results/deepgaze_correlation_metrics.csv")
    visualize_correlations("../results/unisal_correlation_metrics.csv")
all_pairwise_correlations()