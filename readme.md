# Effects of Transformations on Gaze Prediction

## Set Up
- To run the script in `deepgaze_predict`, you need to add the DeepGaze directory as a dependency using pip -e

## Additional Related Work
- "Stylization and Abstraction of Photographs"

## Planning
### Step 1: Figure out which metrics are most likely to be heuristics
Sources:
- What do different evaluation metrics tell us about saliency models? Bylinskii et al.
- Selection of a best metric and evaluation of bottom-up visual saliency models. Emami et al.
- Information-theoretic model comparison unifies saliency metrics. Kummerer et al.

We want to only test those metrics which may have distinct relationships from other metrics. This makes our results more succinct, but also makes it less likely that multiple statistical tests show a relationship out of chance.

Metrics:
- Consider AUC: use only for "receiving" relationship. It is saturating benchmarks because it is invariant to monotonic transformations. We care about relative importance of salient regions, so we care about monotonic transformations. However, it may display a more meaningful relationship since it is a weaker measure (has less guarantees of relative saliency).
- Consider sAUC: don't use because it assumes no centerbias. We want holistic viewing behavior, so we want to include centerbias.
- Consider SIM: don't use because not symmetrical for false positives/negatives, and is highly rank-correlated to other metrics we already use.
- Consider CC: use for heuristics because it is highly rank-correlated to NSS (similar mathematical foundations), and doesn't depend on real fixations like NSS.
- Consider NSS: use for the performace step because it is symmetric for false positives/negatives, does not assume parameters, highly rank-correlated to other metrics, invariant for linear transformations. Also, it and CC are ranked as the most similar to human judgement on the similarity of saliency maps. It relies on real fixations, so can't use for the heuristics.
- Consider EMD: don't use because it is highly rank-correlated to NSS (likely because although it considers distance, that still makes it center-biased), and because we care about accurate locations more than accurate levels (which is opposite priorities than EMD)
- Consider KL: don't use because it is highly rank-correlated to IG, displays similar behaviors in saliency map transformation tests, and is not parameter-free like IG. It also is least human-like in discriminating saliency maps (see the note on NSS). Reconsider though, because IG depends on baselines.
- Consider IG: use it because it is good for probabilistic models, is highly-rank correlated to KL, is parameter-free, and measures performance against baselines.

Summary:
- Performance benchmark: IG and NSS (requires fixations)
- Heuristics: CC and KL (requires only saliency maps)

Note that when comparing real-to-real, we will be converting fixations into saliency maps such that comparison is easier (since there aren't easy ways to compare potentially differently-sized point clouds)

### Step 2: Check the performance of DeepGaze and UNISAL against baselines
Sources:
- Information gain paper from previous section (Information theoretic...)
- Saliency Benchmarking Made Easy: Separating Models From Metrics. Kummerer et al.
- How is Gaze Influenced by Image Transformations? Dataset and Model. Che et. al.
- DeepGazeIIE
- UNISAL
- MIT Saliency Benchmark (for CAT2000)

We estimate the centerbias priors for each of the transformation datasets by simply summing all fixation maps and applying a gaussian blur with a kernel size equal to one degree of visual angle when the data was measured (equal to 57 pixels according to the source of the data). We confirm that saliency maps provided by the original authors of the transformation paper do indeed use a kernel size of 57 pixels.
We want to double check that saliency maps are regularized for KL/IG. After that, there is a common optimization scheme for NSS/IG and CC/KL that we will use respectively.

Unfortunately, I was not able to replicate the performance expected from the DeepGazeIIE model. It performed worse than the centerbias, even for images without transformations. I will have to email the original paper authors to find out what might be going on.

- [2 hours] Get unisal probabalistic maps
- Try downscaling the images for DeepGaze

### Step 3: Bin results for independent/dependent variables for every transformation
    [2 hours planning]
    [5 hours]

### Step 4: ANCOVA Statistical Test on all independent/dependent variables (including transformation types)
    variables:
    - transformation type
    - reference real-to-prediction NSS
    - reference real-to-prediction IG
    - transformed real-to-prediction NSS
    - transformed real-to-prediction IG
    - prediction-to-prediction CC
    - prediction-to-prediction KL
    - real-to-real CC
    - real-to-real KL
    - reference-to-transformed real-to-prediction NSS
    - reference-to-transformed real-to-prediction IG
    - transformed-to-reference real-to-prediction NSS
    - transformed-to-reference real-to-prediction IG
    - model type
    - reference-to-reference centerbias-to-prediction CC
    - reference-to-reference centerbias-to-prediction KL
    - reference-to-transformed centerbias-to-prediction CC
    - reference-to-transformed centerbias-to-prediction KL
    - transformed-to-reference centerbias-to-prediction CC
    - transformed-to-reference centerbias-to-prediction KL
    - transformed-to-transformed centerbias-to-prediction CC
    - transformed-to-transformed centerbias-to-prediction KL
    [2 hours planning]
    [6 hours]

### Step 5: Possibly linking back to earlier experiments
    [2 hours planning]
    [2 hours]
- Possibly include a measurement of performance on the "stylized" sections of the CAT2000 training dataset

### Step 6: Write paper
- [1 hour] Intro stating the problem domain these tools operate in and practical use cases of the tools (including our desired use case for games)
- [1 hour] State problem and how we found it, explain the terms, then restate the problem and how we found it
- [1 hour] Terms to explain: the metrics we used to evaluate performance/compare saliency maps, and why we selected them
- [1 hour] Terms to explain: interpreting the performance with respect to the reference performance, centerbias, ground truth, and MIT Benchmark
- [2 hours] We dig deeper and show relationship between metrics using ANCOVA
- [1 hour] Do the above for every section

### Step 7: Final Checkup
- [1 hour] Verify that metric computations are correct
- [2 hours] Due diligence with citations and descriptive background + methodology information
- [2 hours] Paper formatting
