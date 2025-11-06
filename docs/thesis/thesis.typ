// Preliminary counter
#let preliminary = counter("preliminary")

// From https://github.com/typst/typst/issues/2196
#let content-to-string(item) = {
  if type(item) == str {
    item
  } else if type(item) != content {
    str(item)
  } else if item.has("text") {
    item.text
  } else if item.has("children") {
    item.children.map(content-to-string).join()
  } else if item.has("body") {
    content-to-string(item.body)
  } else if item == [ ] {
    " "
  }
}

// Initial styling
#set page(
  header: context {
    let current_page = counter(page).get()
    let current_preliminary = counter("preliminary").get()

    // First, check page if there is a heading
    let heading_query = query(selector(heading))
    let heading_present = heading_query.any(item => {
      let item_page = counter(page).at(item.location())
      let item_preliminary = counter("preliminary").at(item.location())
      item_page == current_page and item_preliminary == current_preliminary
    })

    // Second, check page if there is a no-header tag
    let no_header_query = query(<no-header>)
    let no_header_present = no_header_query.any(item => {
      let item_page = counter(page).at(item.location())
      let item_preliminary = counter("preliminary").at(item.location())
      item_page == current_page and item_preliminary == current_preliminary
    })

    if not heading_present and not no_header_present [
      #h(1fr) #counter(page).display()
    ]
  },
  header-ascent: 40%,
  number-align: right,
  margin: (
    x: 1.25in,
    y: 1in,
  ),
  numbering: "i",
  footer: "",
  paper: "us-letter"
)

#let font_size = 12pt
#let double_spaced = 20pt
#let single_spaced = 6pt

#set text(
  size: font_size,
  font: "Times New Roman",
)

#set par(
  spacing: double_spaced,
  leading: double_spaced
)

// Metadata
#let author = "James Youngblood"
#let year = "2025"
#let month = "December"
#let degree = "Master of Science"
#let program = "Computing"
#let department = "Kahlert School of Computing"
#let title = "DIGITAL IMAGE TRANSFORMATIONS DEGRADE\nGAZE PREDICTION ACCURACY"
#let abstract = [
  Using saccadic fixation points collected on images and digital transformations of those images, we show that common transformations--including cropping, rotation, contrast adjustment, and noise--degrade prediction accuracy for state-of-the-art gaze fixation prediction models. We fail to find any heuristics which indicate the degradation of prediction accuracy for arbitrary image transformations. Our work emphasizes the need for more varied training data for gaze prediction models.
]
#let committee_chair = "Rogelio E. Cardona-Rivera"
#let committee_second = "Paul A. Rosen"
#let committee_third = "Cem Yuksel"
#let department_chair = "Mary W. Hall"
#let graduate_dean = "Darryl P. Butt"

#show heading: item => [
  #set align(center)
  #set text(size: font_size, weight: "regular")
  #set par(leading: 1em)
  #pagebreak(weak: true)
  #v(1in)
  #item
  #v(40pt)
]

#show figure: set block(width: auto)

#show figure.caption: item => [
  #set par(leading: single_spaced)
  #set align(left)
  #set text(size: font_size)
  #item
  #v(40pt)
]

// Title page
#counter(page).update(0)
#align(center)[
  #text([#title]) <no-header>
  #v(1fr)
  by \
  #author
  #v(1fr)
  #set par(leading: single_spaced)
  A thesis submitted to the faculty of \
  The University of Utah \
  in partial fulfillment of the requirements for the degree of
  #set par(leading: double_spaced)
  #v(1fr)
  #degree \
  in \
  #program
  #v(1fr)
  #department \
  The University of Utah \
  #month #year
]
#pagebreak()

// Copyright page
#align(center)[
  #v(1fr)
  Copyright © <no-header> #author #year \
  All Rights Reserved
  #v(1fr)
]
#pagebreak()

// Approval page
#align(center)[
  *The University of Utah Graduate School* <no-header>
  #v(3em)
  STATEMENT OF THESIS APPROVAL
  #v(3em)
]
The thesis of #author has been approved by the following supervisory committee members:
#v(1em)
#grid(
  columns: (1fr, auto, 80pt),
  row-gutter: double_spaced,
  gutter: 1em,
  [#committee_chair,],
  [Chair],
  [11/3/2025],
  [#committee_second,],
  [Member,],
  [10/27/2025],
  [#committee_third,],
  [Member,],
  [10/30/2025],
)
#v(1em)
by #department_chair, the Chair of the #department, \
and by #graduate_dean, the Dean of the Graduate School.
#pagebreak()

// Abstract page
= ABSTRACT
#h(2em)#abstract
#pagebreak()

// Table of Contents
#outline(
  title: [CONTENTS],
  indent: auto,
  depth: 2,
)
#pagebreak()

// List of Figures
= LIST OF FIGURES
#set par(leading: single_spaced)
#show outline.entry: item => link(
  item.element.location(),
  [
    #counter("figure_counter").step()
    #context {
      counter("figure_counter").display()
    }
    #h(4pt)
    #content-to-string(item.body()).split(". ").first().
    #box(width: 1fr, item.fill)
    #item.page()
    #v(0pt)
  ]
)
#outline(
  title: none,
  target: figure.where(kind: image),
)
#set par(spacing: double_spaced, leading: double_spaced)
#pagebreak()

// Setup for main content
#set page(numbering: "1")
#set par(first-line-indent: (amount: 2em, all: true))
#counter(page).update(1)
#counter("preliminary").update(1)

= INTRODUCTION
In the production of visual media, predictions for human gaze behavior provide feedback on the way a scene will be perceived, and can be used to focus production effort on the most important visual aspects of a scene. For robotics, gaze predictions provide guidance for training an agent to scan its surroundings. For our research, we are motivated by gaze prediction for interactive applications, which will allow unique program logic based on the visual attention of the user.

The field of gaze prediction has seen rapid progress with the emergence of deep learning models over the past decade. Still, when using deep learning models, users must be careful of possible hidden assumptions the model makes based on its training data. The studies which explore model behavior for application-specific classes of images are sparse, and those which exist are out-of-date with the state-of-the-art models.

Gaze prediction models are notably biased towards a class of images we will refer to as "candid photography"; minimally stylized images captured from a camera for practical purposes. Matthias Kümmerer and Matthias Bethge @annurev-vision show that all leading gaze prediction models utilize transfer learning (a term referring to the retraining of a deep learning model designed for one task on another, similar task) from the domain of object recognition. There is a greater volume of object recognition data than gaze recognition data, and so transfer learning from the object recognition domain can improve gaze prediction performance without additional data collection.

The object recognition task deprioritizes visual effects or style, because those do not meaningfully alter outcomes when completing the task, and so prioritizes candid photography. This prioritization does not hold true for our application in gaze prediction, in which we may encounter stylized, illustrated, or computer-generated images and post-processing for aesthetic purposes. The assumption of candid photography, implied by most of the training data a gaze prediction model will see, is a concern for the model's performance when generalizing for stylized images.

A study by Zhaohui Che, Ali Borji, Guangtao Zhai, Xiongkuo Min, Guodong Guo, and Patrick Le Callet @gaze-transformations shows that many digital image transformations influence gaze behavior in nontrivial ways. Visual media produced for aesthetic purposes utilize similar transformations to the ones studied by Che et al. for postprocessing. The study supports the concern that deep-learning gaze prediction models may not generalize well to visual media applications.

Using the data Che et al. collected from human subjects in a new study, our work measures the performance of state-of-the-art gaze prediction models on images which have been transformed with common digital image transformations. We find that the prediction accuracy degrades significantly for almost all transformations, compared to accuracy on untransformed images, which strongly indicates that state-of-the-art, deep learning models are biased towards candid photography.

Improving the performance of gaze prediction models for transformations will require more training data, but the space of possible transformations is vast. In order to prioritize training and data gathering efforts, a computational heuristic that indicates a loss in performance after a transformation--without the need for human subjects--would be very valuable for exploring the space of possible transformations. Searching for such a heuristic, we correlate derived metrics gathered from the images against the performance of the model on the transformed images. Unfortunately, we find that there are only a few weak relationships--none that are a strong and general indicator for a loss in performance after a transformation.

= RELATED WORK
We build on the work of Che et al. @gaze-transformations, who studied digital transformations such as cropping, rotation, skewing, and edge detection on gaze behavior. Their study seeks to augment existing gaze prediction datasets. They search for transformations that produce significantly different images without significantly changing the gaze behavior of human subjects, which allows reuse of the gaze fixation data for the transformations of images in existing datasets. Our study uses the data they collected on image transformations and evaluates performance for state-of-the-art gaze prediction models which Che et al. did not study. We primarily analyze the differences between predicted and real gaze distributions, whereas Che et al. only compared the real gaze distributions of various transformations to each other.

The effects of digital image alterations on gaze behavior have also been studied by Rodrigo Quian Quiroga and Carlos Pedreira @quianquiroga, who performed an experiment collecting gaze fixations before and after manual Photoshop edits were made to photographs of paintings. Insufficient explanation for the intention behind edits makes it difficult to formally and generally describe the image transformations they studied. Instead, we study computationally-modeled image transformations. This allows us to describe the effects they produce on gaze behavior without requiring unique decisions on each image. This enables us to study a greater scale of data.

The effect of adversarial digital image transformations have been tested for both humans and deep learning models for the object recognition task by Girik Malik, Dakarai Crowder, and Ennio Mingolla @object-recognition-transforms. In contrast to their work, our experiments and datasets are designed for the gaze recognition task, a closely related but distinct domain. They test on variations of a pixel-shuffling algorithm, while we test cropping, rotation, skewing, edge detection, and other transformations more commonly seen in visual media applications.

= BACKGROUND
The foundations of the gaze prediction field we build upon are reviewed comprehensively by Kümmerer et al. @annurev-vision, for which we will provide a brief overview.

The most popular method for representing gaze measurements and predictions for images is with a two-dimensional field spanning the image area. This is usually represented using a grayscale image called a "saliency map." In the process of studying an image, the human eye will occasionally jump to a new fixation point in what is called a "saccade." We define a saliency map such that the pixels with the highest intensity are those most likely to be the next fixation target after a saccade. It is worth noting that most gaze prediction research, including our work, assigns "free-viewing" conditions to test subjects, meaning they have not been instructed to search for an element of the image.

When collecting gaze distribution data from human subjects, we receive a collection of saccadic fixation points from an eye tracker over the area of the image presented to the subject. Converting these points into a saliency map can be done by brightening the pixels each point falls on. We can further define our saliency map by normalizing it to a probability distribution, such that each pixel has a probability of being the next fixation point.

At this point, our saliency map would be "speckled," with scattered points of high intensity and all other locations being low intensity. This saliency map likely diverges from the real gaze distribution because of the limited sample size of fixation points. When testing greater fixation point sample sizes, we see that on the limit of infinite sample size, the saliency map would converge to a smooth probability distribution rather than a discrete point cloud.

Thus, if we wish to obtain a better estimate of the real gaze distribution, we should blur the saliency map with a Gaussian kernel to obtain a smoother probability distribution. This step is referred to as "regularization." Note that it is convention to set the size of the Gaussian kernel to a pixel value equivalent to one degree of visual angle in length from the human subject's perspective. See Figure 1 for an illustrative example of both speckled and regularized saliency maps.

If we perform these regularization steps on collected fixations from human subjects for an image, the resulting regularized saliency map is our best proxy for the real gaze distribution. We will refer to this as a "real map" for brevity.

Gaze prediction models will compute a saliency map for an image using only the image's contents. It will not have access to any fixation points gathered from human subjects. We might then compute a metric for distance between a predicted saliency map and a real map, or the distance of both from a common baseline, to measure the accuracy of the prediction to reality.

We note that a paper by Matthias Kümmerer, Thomas S. A. Wallis, and Matthias Bethge @information-gain describes computation for a "gold standard" prediction that is conceptually similar to the real map we use. The gold standard is intended to be an expected upper bound for the prediction accuracy of gaze prediction models. Because prediction models do not receive fixation points of an image as input, the gold standard attempts to provide a fair comparison by summing all fixation points except those attached to the image of concern when computing the gold standard.

For our study, we require that our real map reflects the loss of information content undergoes destructive transformations. When an image undergoes such a transformation, we expect fixations to be more chaotic, and the summation of those points will spread across a wider area. The real map prediction accuracy falls as saliency is distributed over a broader area. This means that, for the purposes of our study, the real map serves as a good upper reference point for comparison with gaze prediction model performance. We do not require the gold standard's strictness with regard to fair comparisons to potential model performance, and so we omit the computation of the gold standard in favor of the real map's simplicity.

With the real map as an upper reference point for prediction accuracy, we seek a lower reference point. With both upper and lower reference points, we may normalize all prediction accuracy scores between the range of the scores of the reference points, allowing us to make a fair comparison between the performance of different transformations.

An ideal lower reference point should account for biases in gaze behavior present in the dataset of images, but should not account for any individual image's contents. This will allow us to see what information the gaze prediction model can inference from an image directly, beyond any general assumptions the model might make based on previous experience with the dataset or class of images.

For datasets exceeding a certain sample size, an adequate lower reference point can be computed by collecting all fixation points for the entire dataset of interest at once and regularizing similar to the real map. The process will produce an average of all fixations across all images in the dataset. In gaze prediction research, this is usually referred to as the "center bias," due to the prevalent tendency of most human subjects (and therefore datasets of human gaze behavior) to fixate towards the center of an image. The center bias will account for dataset-wide biases, and as the number of images in the dataset increases, the weight of any individual image's fixations will trend towards zero. This fulfills our requirements for a lower reference point. As an example from our dataset, the center bias is shown in Figure 2.

Using metrics for comparison compiled by Zoya Bylinskii, Tilke Judd, Aude Olivia, Antonio Torralba, and Frédo Durand @saliency-metrics, we can measure the accuracy of a model's predictions. Each metric is categorized as either "location-based" or "distribution-based," meaning they either compute a score between a saliency map and fixation points, or between two saliency maps, respectively. We evaluate the qualities and usefulness of each metric for our study in the "Method" section.

Using these metrics, along with the real map and center bias, we can conclude a decrease in accuracy of a model's predictions when the normalized score (between the range of the real map and center bias) of the prediction falls.

The most widely adopted benchmark for gaze prediction model performance is the MIT/Tuebingen Saliency Benchmark @mit-tuebingen @made-easy @mit300, which lists many of the metrics described by Bylinskii et al. @saliency-metrics to compare the performance of submitted models. We select two high-scoring models as state-of-the-art from this Benchmark. The first is the current top contender on the benchmark, DeepGaze IIE, from Akis Linardos, Matthias Kümmerer, Ori Press, and Matthias Bethge @deepgazeiie. The second is a runner-up, UNISAL, from Richard Droste, Jianbo Jiao, and J. Alison Noble @unisal. UNISAL has a smaller memory footprint and faster inference speed than DeepGaze IIE.

For completeness, we note that Kümmerer et al. @information-gain describe the use of cross-validation for enhancing the accuracy of the center bias. In the "Method" section, we show that our center bias performs closely with the center bias on the MIT/Tuebingen Saliency Benchmark, which uses the cross-validation step. From this observation we conclude that the cross-validation step only provides marginal improvements in prediction accuracy of the center bias for our dataset. We omit the cross-validation step in the interest of simplicity.

Kümmerer et al @information-gain also describe using a leave-one-out policy for the center bias. When comparing an image to the center bias, they leave out the fixation point data tied to that image when computing the center bias, and use only the fixation points from the rest of the dataset. This will ensure that the center bias does not include any information specific to the image in question, and ensure a better lower reference point.

We find this leave-one-out policy to have marginal impact on our dataset as well. As we will describe in the "Method" section, we compute center biases using fixations gathered for 100 images. After summation and normalization over 100 images, the error between our center bias and that of the leave-one-out policy will be within around 1%. We decide that this difference is negligible, and so we omit the leave-one-out policy, once again in the interest of simplicity.

#pagebreak()

#figure(
  grid(
    columns: (1fr, 1fr),
    image("fixation_map_example.png", width: 150pt),
    image("real_map_example.png", width: 150pt),
  ),
  caption: [
    An illustrative example of a "speckled" saliency map and its regularization. On the left is the speckled saliency map with 15 randomly placed fixation points, and a regularized saliency map produced by smoothing using a Gaussian blur is on the right.
  ],
)

#figure(
  image("reference_centerbias.png", width: 200pt),
  caption: [
    The center bias for the untransformed set of images in our dataset. It is computed by summing all fixation points for the untransformed set of images and blurring for regularization.
  ],
)

= METHOD
We aim to measure the accuracy of gaze prediction models on both untransformed images and their transformed counterparts. We hypothesize that transformed counterparts will achieve lower accuracy scores than untransformed counterparts.

We use the dataset provided by Che et al. @gaze-transformations, which includes 100 randomly selected images from the CAT2000 dataset @cat2000, with 18 different transformations applied to each image. This produces a total of 1900 images, including the untransformed images. Gaze fixation points are recorded for each image. See Figures 3 and 4 for examples of all transformations.

Some transformations are similar to others in all but intensity, i.e. the `ContrastChange_1` and `ContrastChange_2` transformations. We do not have absolute measures for the difference in intensity between two transformations, only ranks of intensity. We will plot the prediction accuracy of similar groups of transformations in ascending order of intensity to reveal any potential trends.

As a second step of our study, we search for a heuristic for expected degradation for a transformation that does not require human subject data. We will collect a set of relevant metrics that only require a reference dataset of human subject data, for which arbitrary transformations can be applied. We compute the metrics' correlation to the prediction accuracy of the models on the transformed images.

Both the first step and second step of our study need metrics of model prediction accuracy, which leads us to examine the metrics compiled by Bylinskii et al. @saliency-metrics. We will select location-based metrics for the first step of our study, where we must evaluate the performance of models given a set of fixation points, because location-based metrics require fewer configuration parameters than distribution-based metrics. For the second step of our study, the comparison between the saliency maps produced for both untransformed and transformed images may be a valuable heuristic, and so we will select distribution-based metrics as well.

Listing the metrics, along with their abbreviations, we have area-under-the-curve (AUC) @aucjudd, shuffled area-under-the-curve (sAUC) @sauc, normalized scanpath saliency (NSS) @nss, information gain (IG) @information-gain, and Earth Mover's Distance (EMD) @emd. We also have image-based versions of histogram similarity (SIM), Pearson correlation coefficients (CC), and Kullback-Leibler divergence (KL).

We wish to isolate the most relevant metrics for our study. With relevant metrics, we can evaluate prediction accuracy and compute correlations. However, by checking too many metrics, we increase the likelihood of false positives when searching for relationships between metrics due to noise. Thus, we select metrics with the most useful qualities for our motivating use cases.

We decide against the AUC metric because it is invariant to monotonic transformations, and has been deemed to be relatively saturated and uninformative in benchmarks compared to other metrics by Bylinskii et al. due to this property. We would like to be sensitive to the relative importance of salient regions, which the AUC metric is not.

We decide against the sAUC metric because it assumes no center bias is present in the saliency maps that a model produces. We wish to include the center bias in our study such that we may study holistic viewing behavior.

We decide against the SIM metric because it does not penalize false positives and false negatives equally, which can produce unexpected metric behavior. Additionally, it is highly rank-correlated to the NSS and CC metrics, which means that relationships involving the NSS and CC metrics are likely to be present with SIM metric as well.

We decide against the EMD metric because it is computationally expensive, and because it is also highly rank-correlated to the NSS and CC metrics.

We select the remaining metrics: NSS, CC, IG, and KL. NSS and IG are location-based, while CC and KL are distribution-based. NSS and CC have been likened as the discrete and continuous analogs of each other, respectively, as a similarity metric. Meanwhile, the IG and KL metrics utilize similar information-theoretic foundations. IG is favored, because it provides a comparative measure against the center bias as a baseline. This baseline characteristic of IG means that we must use other metrics to compare center biases.

Additionally, we will use the structural similarity index (SSIM) @ssim metric to compare the difference between images before and after a transformation. We hypothesize that a measure of difference before and after a transformation may also be a valuable heuristic for expected prediction accuracy loss.

Before evaluation of the models, we compute the center bias for the untransformed set of images and all transformation sets separately. We collect all fixation points for all images by set and apply a Gaussian blur with a kernel size and sigma value of 57 pixels, which corresponds to one degree of visual angle according to Che et al.

At this point, we test to confirm that our center bias performs as expected. We compare against the MIT/Tuebingen Saliency Benchmark reported as 2.0870 on the NSS metric for their center bias on the CAT2000 dataset. Our center bias achieves a mean NSS of approximately 2.0665 on the untransformed image set. The error between the two scores is under 1% of the expected value. We expect our model prediction scores to fall between the gold standard and the center bias listed on the Benchmark. The range between the gold standard and the center bias is 0.6559, and the error between our center bias and the listed center bias would be 3% of that range. We decide that this error range is acceptable, and continue without utilizing cross-validation or leave-one-out policies to improve our center bias.

We also compute real map for each image, using a Gaussian blur kernel with a size of 57 pixels on the fixation points for each image separately.

We run the DeepGaze IIE @deepgazeiie and UNISAL @unisal models on all untransformed and transformed images. The dataset images have a resolution of 1920 by 1080. We run inference for both models at this resolution, but we also run inference for downscaled images which better match the resolutions with which the models were trained. DeepGaze IIE expects an image with a width of 1024, so we downscale and run the model again for images of a 1024 by 576 resolution (preserving the aspect ratio of the original 1920 by 1080 image).

UNISAL was trained on several resolutions. We run the model for 384 by 224 (which matches the DHF1K dataset @dhf1k resolution), 384 by 288 (which matches the SALICON dataset @salicon resolution), and 384 by 216 (which preserves the aspect ratio of the original image with the width of the previous two resolutions).

Considering the average metric performance across all transformations, and additionally when only considering the untransformed set, we find that inferencing UNISAL at a resolution of 384 by 224 is optimal. The same is true for inferencing DeepGaze IIE at a resolution of 1024 by 576. We note that for the `Boundary`, `ContrastChange_1`, `ContrastChange_2`, and `Shearing_2` transformations, the 384 by 288 resolution for UNISAL performs marginally better than 384 by 224. For the `Cropping_1`, `Cropping_2`, `Inversion`, `Rotation_1` and `Rotation_2` transformations, the 384 by 216 resolution for UNISAL performs marginally better.

We decide that these situational differences between several UNISAL resolutions, which are at maximum an approximate 0.02 points in NSS score, do not outweigh the overall performance lead of 0.02 points for the 384 by 224 resolution of UNISAL. From this point forwards, we will only study the 384 by 224 resolution for UNISAL and the 1024 by 576 resolution for DeepGaze IIE.

We will compute our location-based metrics (NSS and IG) for each transformation set as the first step of our study. We will compare the scores for each transformation to the scores for the untransformed set of images, as well as similar transformations in escalating intensity. For all scores, we will normalize between the range of the real map and the center bias, allowing for comparisons between transformations.

Next, we will utilize SSIM, CC, KL, NSS, and IG metrics for the second step of our study. We wish to find correlations between some independent metrics and those metrics which measure the model's prediction accuracy on the transformed images.

For our independent metrics, we use the SSIM between the untransformed and transformed images and the CC and KL metrics between the saliency maps produced by the model for the untransformed and transformed image. We also use the NSS and IG metrics for the untransformed saliency map the model produced. These metrics are selected because they can be computed using only an untransformed dataset with gaze distribution records, along with any arbitrary image transformation. These metrics do not require real gaze distribution data for the transformed images, and as such may be useful insights without costly human trials.

Our dependent variables will be the NSS and IG metrics for the transformed saliency map the model produced, which measure the model's prediction accuracy on the transformed image.

We recognize that these metrics do not represent an exhaustive list of all possible metrics which may relate to our dependent variables, and we task future studies with enumerating metrics with possible relationships more thoroughly.

We wish to find a correlation between any pair of independent and dependent variable. There are 10 possible pairs between these variables, and so we will plot the 10 pairs and compute 10 correlation coefficients for each transformation. We will interpret any relationship with a Pearson's correlation coefficient above 0.5 for both the DeepGaze IIE and UNISAL models as a strong enough relationship to be useful as a heuristic.

As we plot the data, we find that some outliers exist. We filter any sample which falls beyond three standard deviations from the mean for either the independent or the dependent variable in each plot. These samples are also omitted from the correlation coefficient calculations.

We publish the code for our experiment at our repository on Codeberg @our-code.

#pagebreak()

#figure(
  grid(
    rows: (200pt, 200pt, 200pt),
    image("reference_example.png", width: 380pt),
    image("cropping_1_example.png", width: 380pt),
    image("cropping_2_example.png", width: 380pt),
    gutter: 3pt,
  ),
  caption: [
    Demonstrations of `Cropping_1` and `Cropping_2` transformations. The images, listed from top to bottom, are the untransformed image, the `Cropping_1` transformation, and the `Cropping_2` transformation.
  ]
)

#figure(
  image("transformation_examples.png", width: 290pt),
  caption: [Demonstrations of all transformations except `Cropping_1` and `Cropping_2`. (`Cropping_1` and `Cropping_2` are shown in Figure 3.) A slice of one of the images in the dataset is shown, where both the untransformed slice and all transformations of the slice are displayed, with transformation names listed above each slice.]
)

= RESULTS
For the untransformed image set, we find that both DeepGaze IIE @deepgazeiie and UNISAL @unisal perform similarly to the expectation set by the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset when considering the IG metric. For DeepGaze IIE, the Benchmark lists a score of 0.1893, while our inference achieves a score of approximately 0.1665. This results in an error of about 12% of the expected value, or an error around 3% of the range between the gold standard and the center bias (0.8026). For UNISAL, the Benchmark lists a score of 0.0321, while our inference achieves a score of approximately 0.0381. This results in an error of about 18% of the expected value, but the error is less than 1% of the range between the gold standard and the center bias.

For the NSS metric, both DeepGaze IIE and UNISAL outperform the expectation set by the MIT/Tuebingen Saliency Benchmark considerably. For DeepGaze IIE, the Benchmark lists a score of 2.1122, while our inference achieves a score of approximately 2.4429. This results in an error of about 16% of the expected value, or about 50% of the range between the gold standard and the center bias (0.6559). For UNISAL, the Benchmark lists a score of 1.9359, while our inference achieves a score of approximately 2.1563. This results in an error of about 11% of the expected value, or about 33% of the range between the gold standard and the center bias.

The increase in NSS scores cannot be attributed to differences in normalization between our method and the Benchmark's reports. The NSS computation has a normalization scheme built into its definition, using the mean and standard deviation of pixel intensities in the saliency map. We have double-checked that our method follows the definition as described in the paper by Bylinskii et al. @saliency-metrics. Whether it be chance due to the collection process of the dataset of Che et al. @gaze-transformations, or an elusive error or effect in our methodology, the reason for this unexpected increase in prediction accuracy is unclear.

We find that all transformations except for `Mirroring` cause both models' prediction accuracy to drop by 5 to 95 percentage points of the range between the real map and the center bias, depending on model and transformation type. This holds true for both the NSS and IG metrics. An increase in the intensity of the transformation leads to a loss in prediction accuracy. Figures 5 and 6 plot the degradation of each model's NSS and IG metrics respectively, along with comparisons to the real map and center bias, for each transformation.

These results confirm our general hypothesis that digital transformations will degrade the model's prediction accuracy. However, for the specific case of the `Mirroring` transformation, the model's prediction accuracy is mostly unaffected. The results tell us that it is likely that models will require additional training on data collected for transformed images (excluding `Mirroring`) in order to mitigate performance degradation.

Next, we hope to find heuristics that will allow us to quickly explore for transformations which will require additional training. For the second step of our study, we find only a few strong correlations. For most transformations there exists a strong correlation (above 0.5 for both DeepGaze IIE and UNISAL, as per our "Method" section) between untransformed and transformed NSS scores. This holds true for all transformations except the `ContrastChange_1`, `ContrastChange_2`, `Rotation_2`, and `Shearing_3` transformations. We notice that UNISAL performs especially poorly on the contrast change transformations, even though DeepGaze IIE performs well. See Figure 7 for a scatterplot of all images in the dataset on axes of untransformed and transformed NSS scores, and a correlation coefficient for each transformation and model.

The relationships between untransformed and transformed IG scores displays similar but weaker patterns compared to the relationships with NSS scores. As with NSS, the IG metric fell below our threshold for a strong correlation for the `ContrastChange_1`, `ContrastChange_2`, `Rotation_2`, and `Shearing_3`. Additionally, it the IG metric fell below the threshold for the `Boundary`, `MotionBlur_1`, `MotionBlur_2`, `Rotation_1`, and `Shearing_2`. See Figure 8 for a similar plot to Figure 7 but with IG instead of NSS scores.

For all transformations which degraded by 30% or greater for the IG metric for the first step of our study (for both models), the strongest intensities of the same transformation fail our threshold for strong correlation (for NSS or IG). Additionally, the `Boundary` transformation displays a weak correlation, though it does not degrade by 30% or more in the first step. We find no other patterns between the data gathered in the first and second steps of our study.

From the above data, we conclude that an increase in prediction accuracy for untransformed images correlates with an increase in prediction accuracy for almost all transformations. This tells us that, even in the absence of a more effective strategy, investing greater amounts of data and compute into existing training techniques will improve performance for both untransformed and transformed images.

For transformations with weaker correlation coefficients, the relationship seems to be nonlinear to some extent. We infer that the first step's performance degradation indicates a drop-off in accuracy increase for those transformations with weak correlations. For such transformations, untransformed accuracy improvements greatly outpace those seen in transformed accuracy. These transformations indicate the need for a targeted training plan that addresses the performance degradation seen in the transformation. 

Besides the correlations mentioned above, only one other correlation passes our threshold for both DeepGaze IIE and UNISAL: that between the CC metric across the predictions for the untransformed and transformed images, and the NSS metric for the transformed image. See Figure 9.

This final correlation seems to indicate that, for the contrast change metrics specifically, the greater the similarity of the prediction for the transformed image and that for the untransformed image, the more accurate the prediction for the transformed image is. We might hypothesize this effect is due to image features not changing location, nor changing in relative emphasis or contrast, after a contrast change transformation. This means the real gaze distribution should remain unaffected, and so should the prediction. However, there are transformations which we might also intuitively believe to exhibit little change in real gaze distribution, such as noise and compression, which do not exhibit similar correlations.

Transformations which do not effect gaze distributions are called "label-preserving" by Che et al. @gaze-transformations. This is because machine learning domains would call the associated gaze distributions the "labels" of our image data. We invite future work to study label-preserving transformations as a class of transformations which may have unique characteristics which allow unique heuristics, such as the CC metric.

We save all metrics and data gathered in our study in the `results` directory of our repository on Codeberg @our-code. The code used to compute them and produce visualizations is also available in the same repository.

#pagebreak()

#figure(
  image("degradation_nss.png", width: 380pt),
  caption: [Plotting the degradation of NSS metrics for each transformation. Each group of transformations are ordered by increasing intensity, and prepended with the untransformed set. For each group and each model, we plot the NSS score normalized between the range of the real map and the center bias NSS scores. We color the UNISAL plot light red and the DeepGaze IIE plot dark blue. We list the change in value from untransformed to most intense transformation for each model at the top of each plot.]
)

#figure(
  image("degradation_ig.png", width: 380pt),
  caption: [Plotting the degradation of IG metrics for each transformation. As with Figure 5, each group of transformations are ordered by increasing intensity, and prepended with the untransformed set. For each group and each model, we plot the IG score normalized between the range of the real map and the center bias IG scores. We color the UNISAL plot light red and the DeepGaze IIE plot dark blue. We list the change in value from untransformed to most intense transformation for each model at the top of each plot.]
)

#figure(
  image("correlation_nss.png", width: 380pt),
  caption: [NSS correlation between untransformed and transformed images. For both models, we plot a point for each image, where its horizontal and vertical position are determined by the untransformed and transformed NSS scores, respectively. We plot UNISAL with light red and DeepGaze IIE with dark blue. We then plot a line of best fit for both sets of points.]
)

#figure(
  image("correlation_ig.png", width: 380pt),
  caption: [IG correlation between untransformed and transformed images. As with Figure 7, we plot a point for each image for both models, where its horizontal and vertical position are determined by the untransformed and transformed NSS scores, respectively. We plot UNISAL with light red and DeepGaze IIE with dark blue. We then plot a line of best fit for both sets of points.]
)

#figure(
  image("correlation_cc.png", width: 260pt),
  caption: [CC metric between untransformed and transformed saliency maps, related to NSS metric for transformed images. As with Figures 7 and 8, we plot a point for each image for both models, where its horizontal position is determined by the CC score between untransformed and transformed prediction saliency maps. The vertical position is determined by the transformed NSS score. We plot UNISAL with light red and DeepGaze IIE with dark blue. We then plot a line of best fit for both sets of points.]
)

= CONCLUSION
For all transformations except `Mirroring`, both DeepGaze IIE and UNISAL models perform worse than the untransformed set of images. Increasing the intensity of the transformation leads to further loss in prediction accuracy. Losses in prediction accuracy are measured relative to the real map and center bias, and so these losses are not attributable to loss of image information content due to the transformation.

Even so, there is usually a correlation between prediction accuracy on an untransformed image and prediction accuracy on a transformed image. A minority of transformations display weak correlations, and for these transformations the models usually suffer higher loss in prediction accuracy. We are assured that a greater amount of data and compute applied to existing training techniques will improve performance across the board for both untransformed and transformed images. Even so, we anticipate that some transformations may require a more targeted training plan in order to mitigate relatively weak performance.

We find that for the contrast change transformations only, the image-based correlation coefficient between the predictions for an untransformed image and its transformation is a heuristic for predicting the performance of a model on transformed images. In this unique case, one can infer some information about a model's performance on contrast-changed images without gathering human trial data. We refer to transformations which display this behavior as label-preserving.

Our work concludes that current state-of-the-art gaze prediction models cannot be confidently assumed to generalize to several image classes outside of those seen in their training data. Because many of the transformations we studied are commonly used in digital media production, we raise concerns when applying gaze prediction models to many classes of images in digital media.

To the extent that CAT2000 @cat2000 and other gaze prediction datasets are representative of image classes of interest to an arbitrary application, we have shown that performance will degrade for those image classes when common digital image transformations are applied. Alternatively, if we assume that CAT2000 is not representative of an area of interest, there is almost no data to show how well the models will perform for those image classes, and so confidence remains low.

For future work, we would like to test a greater number of transformations, including distortions, color manipulations, stylistic filters, and compositions of all the above. We would also like to study the characteristics of potential label-preserving transformations in greater detail. Finally, we would like to test transformations with more rigorous definitions of "intensity", at a granular level such that we can more accurately elucidate trends in performance as we increase the intensity of the transformation.

#set par(spacing: double_spaced, leading: single_spaced)
#bibliography("thesis.bib", title: "REFERENCES")