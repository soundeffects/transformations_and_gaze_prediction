# Effects of Transformations on Gaze Prediction

## Set Up
- The dataset has been redistributed on Google Drive: https://drive.google.com/file/d/1JFCYDkm0x1ssk8P7Cii6tA_xQ2i-udhY/view?usp=sharing.
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

We estimate the centerbias priors for each of the transformation datasets by simply summing all fixation maps and applying a gaussian blur with a kernel size equal to one degree of visual angle when the data was measured (equal to 57 pixels according to the source of the data). We confirm that saliency maps provided by the original authors of the transformation paper do indeed use a kernel size of 57 pixels. When we downscale images to the size of the MIT1003 dataset, this roughly corresponds to their 35 pixel kernel size as well.
We want to double check that saliency maps are regularized for KL/IG. After that, there is a common optimization scheme for NSS/IG and CC/KL that we will use respectively.
We want to resize images we input to the models to be of similar size to what they were originally trained on. The UNISAL paper used image sizes of 224 x 384 for their 16:9 dataset (DHF1K) and 288 x 384 for their 4:3 dataset (SALICON). We will also test 216 x 384, since that is an actual 16:9 ratio (as is seen in our dataset). For DeepGaze, we follow their advice on the Github repository to downscale our 1920 x 1080 dataset images to be 1024 on the longer side, meaning 1024 x 576 for our dataset. We will also try both on the full 1920 x 1080 resolution.

Unfortunately, I was not able to replicate the performance expected from the DeepGazeIIE model. It performed worse than the centerbias, even for images without transformations. I will have to email the original paper authors to find out what might be going on.

We find that with UNISAL, we get a clear drop in performance with transformed image predictions compared to reference image predictions, which confirms our hypothesis.

- [2 hours] Express the information gain in number of people whose gaze is predicted correctly

### Step 4: ANCOVA Statistical Test on all independent/dependent variables (including transformation types)
    We want to see if any correlations exist between data we have on hand when testing a new transformation (i.e. the fixations/centerbias for an untransformed reference, predictions for reference and transform, and image difference metrics) and the performance of the model for the transformed image (whicih we would not have on hand when testing a new transformation), namely the metrics between the prediction and fixation or centerbias and fixation for the transformed set.

    Independent variables:
    - transformation type
    - image difference metrics between reference and transformed
    - metrics between the reference prediction and the transformed prediction
    - metrics between the reference prediction and reference real fixations
    - metrics between the reference centerbias and reference real fixations
    Dependent Variables:
    - metrics between the transformed prediction and transformed real fixations
    - metrics between the transformed centerbias and transformed real fixations
    
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
