// Preliminary counter
#let preliminary = counter("preliminary")

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
    x: 1.5in,
    y: 1in,
  ),
  numbering: "i",
  footer: "",
)

#set text(
  size: 12pt,
  font: "Times New Roman",
)

#set par(
  spacing: 1em,
  leading: 1em,
)

// Metadata
#let author = "James Youngblood"
#let year = "2025"
#let month = "August"
#let degree = "Master of Science"
#let department = "School of Computing"
#let title = "DIGITAL IMAGE TRANSFORMATIONS DEGRADE GAZE PREDICTION ACCURACY"
#let abstract = [  
  Using saccadic fixation points collected on images and digital transformations of those images, we show that common transformations--including cropping, rotation, contrast adjustment, and noise--degrade prediction accuracy for state-of-the-art gaze fixation prediction models. We fail to find any generalizable heuristics which indicate the degradation of prediction accuracy for image transformations; the only known way to confirm an arbitrary transformation has caused a degradation in prediction accuracy is to collect real gaze distribution data on transformed images.
]
#let committee_chair = "Rogelio Cardona-Rivera"
#let committee_second = "Paul Rosen"
#let committee_third = "Cem Yuksel"
#let department_chair = "Mary Hall"
#let graduate_dean = "Darryl P. Butt"

#show heading: item => [
  #set align(center)
  #set text(14pt, weight: "regular")
  #set par(leading: 1em)
  #pagebreak(weak: true)
  #v(1in)
  #item
  #v(1em)
]

#show figure.caption: emph

// Title page
#counter(page).update(0)
#align(center)[
  #text([#title], size: 14pt) <no-header>
  #v(1fr)
  by \
  #author
  #v(1fr)
  A thesis submitted to the faculty of \
  The University of Utah \
  in partial fulfillment of the requirements for the degree of
  #v(1fr)
  #degree
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
The thesis of #emph([#author]) has been approved by the following supervisory committee members:
#v(1em)
#grid(
  columns: (auto, auto, 1fr),
  gutter: 1em,
  [#emph([#committee_chair]),],
  [Chair,],
  [_(Date Approved)_],
  [#emph([#committee_second]),],
  [Member,],
  [_(Date Approved)_],
  [#emph([#committee_third]),],
  [Member,],
  [_(Date Approved)_],
)
#v(1em)
by #emph([#department_chair]), the Chair of the #department, \
and by #emph([#graduate_dean]), the Dean of the Graduate School.
#v(1fr)
#pagebreak()

// Abstract page
= ABSTRACT
#h(2em)#abstract
#pagebreak()

// Table of Contents
#outline(
  title: [CONTENTS #v(2em)],
  indent: auto,
  depth: 2,
)
#pagebreak()

// List of Figures
= LIST OF FIGURES
#outline(
  title: none,
  target: figure.where(kind: image),
)
#pagebreak()

// Setup for main content
#set page(numbering: "1")
#set par(first-line-indent: (amount: 2em, all: true))
#set heading(numbering: "I.")
#counter(page).update(1)
#counter("preliminary").update(1)

= INTRODUCTION
In the production of visual media, predictions for human gaze behavior provide feedback on the way a scene will be percieved, and can be used to focus production effort on the most important visual aspects of a scene. For robotics, gaze predictions provide a guidance for training an agent to scan its surroundings. For our research, we are motivated by gaze prediction for interactive applications, which will allow unique program logic based on the visual attention of the user.

The field of gaze prediction has seen rapid progress with the emergence of deep learning models over the past decade, but when using deep learning models, users must be careful of possible hidden assumptions the model makes based on its training data. The studies which explore model behavior for application-specific classes of images are sparse, those which exist are out of date with the state-of-the-art models.

Gaze prediction models are notably biased towards a class of images we will refer to as "candid photography"; minimally stylized images captured from a camera for practical purposes. Matthias Kümmerer and Matthias Bethge @annurev-vision show that all leading gaze prediction models utilize transfer learning #footnote("Transfer learning, generally defined, is a term for retraining a deep learning model designed for one task on another, similar task.") from other problem domains, primarily object recognition. There is a greater volume of object recognition data than gaze recognition data, and so transfer learning from the object recognition domain can improve gaze prediction performance without additional data collection.

The object recognition task deprioritizes visual effects or style, because those do not meaningfully alter outcomes when completing the task, and so prioritizes candid photography. This prioritization does not hold true for our application in gaze prediction, in which we may encounter stylized, illustrated, or computer-generated images and post-processing for aesthetic purposes. The assumption of candid photography, implied by most of the training data a gaze prediction model will see, is a concern for the model's performance when generalizing to stylized images.

A study by Zhaohui Che, Ali Borji, Guangtao Zhai, Xiongkuo Min, Guodong Guo and Patrick Le Callet @gaze-transformations shows that many digital image transformations influence gaze behavior nontrivially. Visual media produced for aesthetic purposes utilize several post-processing effects with similar characteristics to the digital transformations studied by Che et al. The study supports the concern that deep-learning gaze prediction models may not generalize well to visual media applications.

Using the data the Che et al. collected from human subjects in a new study, our work measures the performance of state-of-the-art gaze prediction models on images which have been transformed with common digital image transformations. We find that the prediction accuracy degrades significantly for almost all transformations, compared to accuracy on untransformed images, which strongly indicates that state-of-the-art, deep learning models are biased towards candid photography.

Improving the performance of gaze prediction models for transformations will require more training data, but the space of possible transformations is vast. In order to prioritize training and data gathering efforts, a computational heuristic that indicates a loss in performance after a transformation--without the need for human subjects--would be very valuable for exploring the space of possible transformations. Searching for such a heuristic, we correlate derived metrics gathered from the images against the performance of the model on the transformed images. Unfortunately, we find that there are only a few weak relationships--none that are a strong and general indicator for a loss in performance after a transformation.

= RELATED WORK
We build on the work of Che et al. @gaze-transformations, who studied digital transformations such as cropping, rotation, skewing, and edge detection on gaze behavior. They were motivated by the possibility of augmenting gaze prediction datasets with transformations that produced a significant difference in the image, but not in the gaze behavior of human subjects, which would allow the gaze fixation data to be reused for a new, transformed image. They analyze the differences in the gaze distributions that they collected. Our study uses the data they collected on image transformations to evaluate performance on transformed images for state-of-the-art gaze prediction models which were not published at the time. We are primarily concerned with analysis of the differences between predicted and real gaze distributions, rather than between the real gaze distributions of various transformations.

The effects of digital image alterations on gaze behavior have also been studied by Rodrigo Quian Quiroga and Carlos Pedreira @quianquiroga, who performed an experiment collecting gaze fixations before and after manual Photoshop edits were made to photographs of paintings. Insufficient explanation for the intention behind edits makes it difficult to formally and generally describe the image transformations they studied. Instead, we study computationally-modeled image transformations, such that we can describe the effects they produce on gaze behavior more formally and generally, and so that we can study a greater scale of data which does not require human decisions for each image.

The effect of adversarial digital image transformations have been tested for both humans and deep learning models for the object recognition task by Girik Malik, Dakarai Crowder, and Ennio Mingolla @object-recognition-transforms. In contrast to their work, our experiments and datasets are designed for the gaze recognition task, a closely related but distinct domain. They test on variations of a pixel-shuffling algorithm, while we test cropping, rotation, skewing, edge detection, and other transformations.

= BACKGROUND
The foundations of the gaze prediction field we build upon are reviewed comprehensively by Kümmerer et al. @annurev-vision, for which we will provide a brief overview.

The most popular method for representing gaze measurements and predictions for images is with a two-dimensional field spanning the image area. This is usually represented using a grayscale image called a "saliency map". In the process of studying an image, the human eye will occasionally jump to a new fixation point in what is called a "saccade". We define a saliency map such that the pixels with the highest intensity are those most likely to be the next fixation target after a saccade for an arbitrary person under "free-viewing" conditions (which means the person has not been instructed to search for an element of the image).

When collecting gaze distribution data from human subjects, we receive a collection of saccadic fixation points from an eye tracker over the area of the image presented to the subject. Converting these points into a saliency map can be done by brightening the pixels each point falls on. We can further define our saliency map by normalizing it to a probability distribution, such that each pixel has a probability of being the next fixation point.

At this point, our saliency map would be "speckled", with scattered points of high intensity and all other locations being low intensity. This saliency map likely diverges from the real gaze distribution because of the limited sample size of fixation points. When testing greater fixation point sample sizes, we see that on the limit of infinite sample size, the saliency map would converge to a smooth probability distribution rather than a discrete point cloud.

Thus, if we wish to obtain a better estimate of the real gaze distribution, we should blur the saliency map with a Gaussian kernel to obtain a smoother probability distribution. This step is referred to as "regularization". Note that it is convention to set the size of the Gaussian kernel to a pixel value equivalent to one degree of visual angle in length from the human subject's perspective.

#figure(
  grid(
    columns: (1fr, 1fr),
    image("fixation_map_example.png", width: 150pt),
    image("real_map_example.png", width: 150pt),
  ),
  caption: "An illustrative example of a 'speckled' saliency map (left) with 15 randomly placed fixation points, and a smoothed saliency map (right) produced from the other saliency map by a regularization step using a gaussian blur.",
)

If we perform these regularization steps on collected fixations from human subjects for an image, the resulting regularized saliency map is our best proxy for the real gaze distribution. We will refer to this as a "real map" for brevity.

Gaze prediction models will compute a saliency map for an image using only the image's contents. It will not have access to any fixation points gathered from human subjects. Using a metric for distance between a predicted saliency map and a real map, or a metric for the distance of both from another reference point, one can gain a sense for how well the predicted saliency map matches the real gaze distribution.

We note that a paper by Matthias Kümmerer, Thomas S. A. Wallis,  and Matthias Bethge @information-gain describes computation for a "gold standard" prediction that is conceptually similar to the real map we use. The primary difference is that the gold standard is intended to be an expected upper bound for the prediction accuracy of gaze prediction models. We remind that gaze prediction models do not receive the fixation points from human subjects directly. To ensure that a fair comparison is made to gaze prediction models, they ensure that the gold standard does not use any human subject's fixation data to predict itself, and so the gold standard will use a map produced from the fixations of all other subjects when predicting a given subject.

For our study, we do not require an upper bound for gaze prediction model performance. We only require an upper reference point such that we can compare effects between transformations even when image information content undergoes destructive transformations. When an image undergoes such a transformation, we expect fixation to be more random, and the real map will be unable to score accuracy metrics as high as if the fixation points were orderly and concentrated. The real map prediction accuracy falls in tandem with the loss of information, and thus allows us to reduce the influence of losses of information on our measurements of gaze prediction model performance. We omit the computation of the gold standard in favor of the real map's simplicity.

If the real map acts as an upper reference point for prediction accuracy, we wish also to find a lower reference point, such that we can compare gaze prediction model performance in terms of the fraction of the accuracy that a model achieves between the upper and lower reference points.

For a saliency map to be a lower reference point, it should account for any features or biases that are common in the dataset or class of images we are studying, but should not predict any features based on any individual image's contents. This will allow us to see what information the gaze prediction model can inference from an image directly, beyond any general assumptions the model might make based on previous experience with the dataset or class of images.

For datasets exceeding a certain sample size, an adequate lower reference point can be computed by collecting all fixation points for the entire dataset of interest at once and regularizing similar to the real map. The process will produce an average of all fixations across all images in the dataset. This is usually referred to as the "center bias", due to the prevalent tendency of most human subjects (and therefore datasets of human gaze behavior) to fixate towards the center of an image. The center bias will account for dataset-wide biases, and as the number of images in the dataset increases, the weight of any individual image's fixations will trend towards zero.

#figure(
  image("reference_centerbias.png", width: 200pt),
  caption: "The center bias computed by summing all fixation points for the untransformed group of images in our dataset and blurring; it is provided as an illustrative example.",
)

Using the collected fixation points, real maps, center biases, and metrics for comparison compiled by Zoya Bylinskii, Tilke Judd, Aude Olivia, Antonio Torralba and Frédo Durand @saliency-metrics, we can measure the accuracy of a model's predictions. Each metric is either "location-based" or "distribution-based", as Bylinskii et al. call them, meaning they either compute a score between a saliency map and fixation points, or between two saliency maps, respectively. We evaluate the qualities and usefulness of each metric as it pertains to our study in the "Method" section. Using these metrics, we can conclude a decrease in accuracy of a model's predictions when the fraction of the metric score a model achieves, relative to the range between the scores of the real map and the center bias, falls.

The most widely adopted benchmark for gaze prediction model performance is the MIT/Tuebingen Saliency Benchmark @mit-tuebingen, which lists many of the metrics described by Bylinskii et al. @saliency-metrics to compare the performance of submitted models. We select the current top contender on the benchmark, DeepGaze IIE (from Akis Linardos, Matthias Kümmerer, Ori Press, and Matthias Bethge) @deepgazeiie, and a runner-up with smaller memory footprint and faster inference speed, UNISAL (from Richard Droste, Jianbo Jiao, and J. Alison Noble) @unisal, as state-of-the-art models for our study.

Kümmerer et al. @information-gain describe the use of cross-validation for enhancing the accuracy of the center bias. As we show in the "Method" section, our center bias performs closely with the center bias on the MIT/Tuebingen Saliency Benchmark which uses the cross-validation step, and so we conclude that the cross-validation step only provides marginal improvements in prediction accuracy of the center bias. We omit the cross-validation step in the interest of simplicity.

Kümmerer et al @information-gain also describe using a leave-one-out policy for the center bias. When using a center bias a lower reference point prediction for an image, they leave out the fixation point data tied to that image when computing the center bias, and use only the fixation points from the rest of the dataset. This will ensure that the center bias does not include any information specific to the image in question, and ensure a better lower reference point.

As we will describe in the "Method" section, we compute center biases using fixations gathered for 100 images. If we omit the leave-one-out policy, the error between our center bias and that of the leave-one-out policy will be within around 1% error of each other, due to the summing and normalizing over 100 images. We decide that this difference is negligible, and so we omit the leave-one-out policy, once again in the interest of simplicity.

= METHOD
We aim to measure the accuracy of gaze prediction models on both untransformed images and their transformed counterparts, and analyze the differences in accuracy between the two.

We use the dataset provided by Che et al. @gaze-transformations, which includes 100 randomly selected images from the CAT2000 dataset @cat2000, with 18 different transformations applied to each image. This produces a total of 1900 images, including the untransformed images. Gaze fixation points are recorded for each image. See figures 3 and 4 for examples of all transformations.

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    image("reference_example.png", width: 100pt),
    image("cropping_1_example.png", width: 100pt),
    image("cropping_2_example.png", width: 100pt),
    gutter: 3pt,
  ),
  caption: "Examples of the Cropping_1 (second) and Cropping_2 (third) transformations applied to the untransformed image (first)."
)

#figure(
  image("transformation_examples.png", width: 240pt),
  caption: "A slice of one of the images in the dataset, along with applications of all transformations except for Cropping_1 and Cropping_2, which are shown in figure 3."
)

There will be two steps to our study. First, we wish to compare the prediction accuracy of the models between the untransformed and transformed images. We hypothesize that the model's performance will be degraded as images are transformed.

Some transformations are similar to others in all but intensity, i.e. the `ContrastChange_1` and `ContrastChange_2` transformations. Although we do not have strict measures for the relative intensity between two transformations, we will still plot the prediction accuracy of similar groups of transformations in ascending order such that we can reveal trends in the effect that a transformation will have as intensity increases.

Second, we wish to find a heuristic for expected prediction accuracy loss for a transformation, without requiring human subject data. We will collect a set of relevant metrics images we can derive from a source gaze distribution dataset and transformations upon that dataset, and compute their correlation to the prediction accuracy of the models on the transformed images. This leads us to examine the metrics compiled by Bylinskii et al. @saliency-metrics for both the first and the second step.

We will need both of what Bylinskii et al. @saliency-metrics call "location-based" and "distribution-based" metrics. Location-based metrics compare a saliency map to a set of fixation points, and distribution-based metrics compare two saliency maps. We will select location-based metrics for the first step of our study, where we must evaluate the performance of models given a set of fixation points, because location-based metrics require fewer parameters to configure. For the second step of our study, the comparison between the saliency maps produced for both untransformed and transformed images may be a valuable heuristic, and so we will select distribution-based metrics as well.

Listing the metrics considered, we see the area-under-the-curve (AUC-Judd) metric @aucjudd, the shuffled area-under-the-curve (sAUC) metric @sauc, the normalized scanpath saliency (NSS) metric @nss, the information gain metric (IG) @information-gain, the Earth Mover's Distance metric (EMD) @emd, as well as image-based versions of histogram similarity (SIM), Pearson correlation coefficients (CC), and Kullback-Leibler divergence (KL).

We wish to isolate the most relevant metrics for our study. With relevant metrics, we can evaluate prediction accuracy and compute correlations. However, by checking too many metrics, we increase the likelihood of false positives when searching for relationships between metrics due to noise. Thus, we select metrics with the most useful qualities and most significance.

We decide against the AUC metric because it is invariant to monotonic transformations, and has been deemed to be relatively saturated and uninformative in benchmarks compared to other metrics by Bylinskii et al. due to this property. We would like to be sensitive to the relative importance of salient regions, which the AUC metric is not.

We decide against the sAUC metric because it assumes no centerbias is present in the saliency maps that a model produces, and we wish to include centerbias in our study such that we study holistic viewing behavior.

We decide against the SIM metric because it is not symmetrical for false positives and negatives, meaning a false negative will impact the score more than a false positive. Additionally, it is highly rank-correlated to the NSS and CC metrics, which means that relationships involving the NSS and CC metrics are likely to be present with SIM metric as well.

We decide against the EMD metric because it is computationally expensive, and because it is also highly rank-correlated to the NSS and CC metrics.

We select the remaining metrics: NSS, CC, IG, and KL. NSS and IG are location-based, while CC and KL are distribution-based. NSS and CC have been likened as the discrete and continuous analogs of each other, respectively, as a similarity metric. Meanwhile, the IG and KL metrics utilize similar information-theoretic foundations. IG is favored, because it provides a comparitive measure against a baseline (the center bias), but it also has the limitation that it does not provide a meaningful measure for the center bias itself.

Additionally, we will use the structural similarity index (SSIM) @ssim metric to compare the difference not between saliency maps but between images, before and after a transformation. We hypothesize that a measure of difference before and after a transformation may also be a valuable heuristic for expected prediction accuracy loss.

Before we can begin evaluation of the models, we must compute the center biases and real maps for the dataset. We compute the center bias for the untransformed and all transformations separately, collecting all fixation points for the 100 images of each and applying a Gaussian blur with a kernel size and sigma value of 57 pixels, which would be one degree of visual angle during the data collection according to Che et al.

At this point, we test to confirm that our center bias performs as expected. We compare against the MIT/Tuebingen Saliency Benchmark reported as 2.0870 on the NSS metric (one of the metrics compiled by Bylinskii et al. @saliency-metrics, which we will cover in more detail shortly) for their center bias on the CAT2000 dataset. Our centerbias achieves a mean NSS of approximately 2.0665 on the untransformed image set. The error between the two scores is under 1% of the expected value. If we find the range between the gold standard and the center bias listed on the Benchmark (0.6559), which is the range we expect our model prediction scores to fall within, the error between our center bias and the listed centerbias would be 3% of that range. Additionally, our center bias scores lower, and so is more conservative for the purposes of determining whether transformations have significantly degraded the model's prediction accuracy. We decide that this error range is acceptable, and continue without the using the techniques described in the "Background" section to improve our center bias score.

We also compute real map for each image using the same Gaussian blur kernel on the fixation points for each image separately.

#figure(
  grid(
    columns: (1fr, 1fr),
    image("reference_real_map.png", width: 150pt),
    image("reference_centerbias.png", width: 150pt),
    gutter: 3pt,
  ),
  caption: "Left is the real map for the image shown in figures 3 and 4, right is the centerbias for the untransformed group in the dataset.",
)

We run the DeepGaze IIE @deepgazeiie and UNISAL @unisal models on all untransformed and transformed images. The dataset images are at 1920x1080 resolution, and we run inference for both models at this resolution, but we also run inference for downscaled images which better match the expected resolution of the models. DeepGaze IIE @deepgazeiie expects an image with a width of 1024, so we downscale the images to 1024x576, which matches the aspect ratio of the original 1920x1080 image, for another DeepGaze inference. UNISAL @unisal expects several resolutions for different datasets it was trained on, so we run an inference for the resolutions of 384x224 (which matches the DHF1K dataset @dhf1k resolution), 384x288 (which matches the SALICON dataset @salicon resolution), and 384x216 (which preserves the aspect ratio of the original image). We run inference for each model at each resolution, and intend to select the best-performing resolution for each model.

For the first step of our study, we will compute our location-based metrics (NSS and IG) for each transformation set, and compare the average prediction accuracy of the models on the transformed images to the average prediction accuracy of the models on the untransformed images. To better inform this comparison, we also plot the prediction accuracy for transformations that are similar to each other at varying intensities, and compute the loss in percentage points for their accuracy scores, with percentage points being the fraction of the score of the image's real map that a model can achieve relative to the center bias.

For the second step of the study, we will compute the SSIM between the untransformed and transformed images, the CC and KL metrics between the saliency maps produced by the model for the untransformed and transformed image, and the NSS and IG metrics for the untransformed saliency map the model produced. These metrics are selected because they can be computed using only a untransformed dataset with gaze distribution records and any arbitrary image transformation, without the need to measure real gaze distributions for the transformed images.

We recognize that these metrics are not an exhaustive list of all relevant characteristics of the transformation or predictions, and we task future studies with enumerating metrics with possible relationships more thoroughly.

We collect the five metrics mentioned above as our independent variables. Our dependent variables will be the NSS and IG metrics for the transformed saliency map the model produced, which measure the model's prediction accuracy on the transformed image.

We wish to find a correlation between any pair of independent and dependent variable. There are 10 possible pairs between these variables, and so we will plot the 10 pairs and compute 10 correlation coefficients for each transformation. We will interpret any relationship with a Pearson's correlation coefficient above 0.5 for both the DeepGaze IIE and UNISAL models as a meaningfully strong relationship, and proceed to interpret the applicability of each significant relationship on a case-by-case basis.

As we plot the data, we find that some outliers exist. We filter any sample which falls beyond three standard deviations from the mean for either the independent or the dependent variable in each graph. These samples are also omitted from the correlation coefficient computation.

We recognize that computing a measure of how likely it would be that a relationship for our heuristics arose due to a non-representative sample of images, such as a p-value, would allow greater confidence in our results. In order to compute a p-value for our heuristics, we must determine the likelihood of a given image being representative of a class of images which we wish to study. Defining rigorous distinctions with which to isolate the class of images relevant to our motivating use cases is an extraordinarliy difficult task, which we will leave for future work.

Instead, we will limit our claims on potential heuristics: any heuristics found only indicate a likely loss in accuracy for images found in the CAT2000 dataset or similar gaze prediction datasets, from which Che et al. have sampled 100 images at random. We argue that our sample size is large enough to provide a reasonable basis for our study.

We take efforts to ensure our study is reproducible. We publish our code at our repository on Codeberg @our-code.

= RESULTS
When averaging performance increases for all transformation image sets, and additionally when only considering the untransformed set, we find that inferencing UNISAL at a resolution of 384x224 is optimal, and the same is true for inferencing DeepGaze IIE at a resolution of 1024x576. We note that for the `Boundary`, `ContrastChange_1`, `ContrastChange_2`, and `Shearing_2` transformations, the 384x288 resolution for UNISAL performs marginally better than 384x224, and for the `Cropping_1`, `Cropping_2`, `Inversion`, `Rotation_1` and `Rotation_2` transformations, the 384x216 resolution for UNISAL performs marginally better.

For the untransformed image set, we find that both DeepGaze IIE @deepgazeiie and UNISAL @unisal perform similarly to the expectation set by the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset when considering the IG metric. For DeepGaze IIE, the Benchmark lists a score of 0.1893, while our inference achieves a score of approximately 0.1665. This results in an error of about 12% of the expected value, or an error around 3% of the range between the gold standard and the center bias (0.8026). For UNISAL, the Benchmark lists a score of 0.0321, while our inference achieves a score of approximately 0.0381. This results in an error of about 18% of the expected value, but the error is less than 1% of the range between the gold standard and the center bias.

For the NSS metric, both DeepGaze IIE and UNISAL outperform the expectation set by the MIT/Tuebingen Saliency Benchmark considerably. For DeepGaze IIE, the Benchmark lists a score of 2.1122, while our inference achieves a score of approximately 2.4429. This results in an error of about 16% of the expected value, or about 50% of the range between the gold standard and the center bias (0.6559). For UNISAL, the Benchmark lists a score of 1.9359, while our inference achieves a score of approximately 2.1563. This results in an error of about 11% of the expected value, or about 33% of the range between the gold standard and the center bias. The NSS metric is normalized by the mean and the standard deviation of pixel intensities in the saliency map, and so differences in normalization between our process and the Benchmark's cannot account for the unexpected increase in prediction accuracy. Whether it be noise, differences in how the data was collected, or errors that elude us in our inference code or measurement process, the reason for this unexpected increase in prediction accuracy is unclear.

We find that all transformations except for `Mirroring` cause both models' prediction accuracy to drop by 5 to 95 percentage points of the range between the real map and the center bias, depending on model and transformation type. An increase in the intensity of the transformation leads to a loss in prediction accuracy. See figures 6 and 7.

#figure(
  image("performance_degradation_nss.png", width: 360pt),
  caption: "Plots of the NSS metric for each transformation, with the the untransformed (Reference) set as initial performance and transformations in order of increasing transformation intensity. Red lines plot UNISAL metrics, blue lines plot DeepGaze IIE, green lines plot center bias, and yellow lines plot real map. The red colored region denotes the range between the real map and the center bias. Below each figure we list the loss in percentage points between the untransformed and the most intense transformation, where percentage points are the fraction of the score of the image's real map that a model can achieve relative to the center bias."
)

#figure(
  image("performance_degradation_ig.png", width: 360pt),
  caption: "As with figure 6, but plotting the IG metric. We plot in order of increasing transformation intensity. Red lines plot UNISAL, blue lines plot DeepGaze IIE, green lines plot center bias, and yellow lines plot real map. The red colored region denotes the range between the real map and the center bias. Below each figure we list the loss in percentage points as described in figure 6."
)

These results confirm our general hypothesis that digital transformations will degrade the model's prediction accuracy. However, for the specific case of the `Mirroring` transformation, the model's prediction accuracy is unaffected, and may even increase by a marginal amount. The results tell us that models will require additional training in order to perform well on transformed images (excluding `Mirroring`); now we hope to find heuristics that will allow us to quickly explore for transformations which will require additional training.

For the second step of our study, we find that for most transformations there exists a strong correlation, for which we require as a correlation coefficient with an absolute value above 0.5 for both DeepGaze IIE and UNISAL, between untransformed image NSS performance and transformed image NSS performance. This holds true for all transformations except the `ContrastChange_1`, `ContrastChange_2` `Rotation_2`, and `Shearing_3` transformations. We notice that UNISAL performs especially poorly on the contrast change transformations, even though DeepGaze IIE performs well. See figure 8.

#figure(
  image("correlation_nss.png", width: 400pt),
  caption: "We plot both DeepGaze IIE and UNISAL's NSS metric for untransformed images against the NSS metric for transformed images. Red denotes UNISAL, while blue represents DeepGaze IIE. Points represent values for a single image, while lines and paraboles are plotted to best fit the data. We compute the correlation coefficient for each model, listed below each plot."
)

The relationships between untransformed image IG metrics and transformed image IG metrics displays similar but weaker patterns compared to the relationships with NSS metrics. In addition to the `ContrastChange_1`, `ContrastChange_2`, `Rotation_2`, and `Shearing_3` transformations which fell below our threshold with NSS, the `Boundary`, `MotionBlur_1`, `MotionBlur_2`, `Rotation_1`, and `Shearing_2` transformations also fell below thresholds for IG. See figure 9.

#figure(
  image("correlation_ig.png", width: 400pt),
  caption: "We plot both DeepGaze IIE and UNISAL's IG metric for untransformed images against the IG metric for transformed images. Red denotes UNISAL, while blue represents DeepGaze IIE. Points represent values for a single image, while lines and paraboles are plotted to best fit the data. We compute the correlation coefficient for each model, listed below each plot."
)

Although the `ContrastChange_1`, `ContrastChange_2`, `Rotation_1`, `Rotation_2`, `MotionBlur_2`, and `Shearing_3` transformations, which saw weak correlation coefficients, also performed noteably poorly on average in the first part of the study (as seen in figures 6 and 7), we cannot find strong connection between the performance results of the first step and the correlation coefficients of this second step of our study. For example, the `Boundary` transformation did not perform particularly poorly in the first part compared to other transformations, and yet saw a weak correlation coefficient.

Figures 8 and 9 also plot paraboles of best fit for the data. We find that, aside from the the `Boundary`, `Cropping_1`, and `Cropping_2`, `Rotation_1`, `Rotation_2`, and `Shearing_3` transformations for the UNISAL model's IG metric, which have weak positive coefficients for the quadratic term, all other paraboles have a negative coefficient for the quadratic term. For both metrics, we see particularly high negative coefficients for those transformations which have weaker correlation coefficients.

For most transformations tested, an increase in prediction accuracy on the untransformed image correlates with an increase in prediction accuracy on the transformed image. It does not appear to be at a linear rate, however, and if one were to attempt to measure an increase in accuracy of model predictions for transformed images by measuring the accuracy for untransformed images, there appear to be curves of diminishing returns with varying steepness. Those transformations which have weak correlation coefficients fall off the curve of diminishing returns quickly.

Besides the correlations mentioned above, the only other correlation that passes our threshold for both DeepGaze IIE and UNISAL is the correlation between the CC metric between the predictions for the untransformed and transformed images and the NSS metric for the transformed image. See figure 10.

#figure(
  image("correlation_cc.png", width: 200pt),
  caption: "We plot the CC metric between the predictions for the untransformed and transformed images against the NSS metric for the transformed image. Red denotes values for UNISAL, while blue represents DeepGaze IIE. Points represent values for a single image, while lines plotted to best fit the data. We compute the correlation coefficient for each model, listed below each plot."
)

This correlation seems to indicate that, for the contrast change metrics specifically, the greater the similarity of the prediction for the transformed image and that for the untransformed image, the more accurate the prediction for the transformed image is. We might hypothesize this effect is due to image features not changing location, nor changing in relative emphasis or contrast, after a contrast change transformation, meaning the real gaze distribution should mostly remain unaffected, and so should the gaze prediction. This type of transformation is refered to by Che et al. @gaze-transformations as a "label-preserving" transformation, because it does not change what is referred to in machine learning domains as the "label" of the training data, which in this case is the measured gaze distribution tied to the image. Further experiments may be warranted to study label-preserving transformations as a class of transformations which may have unique characteristics which allow unique heuristics, such as the CC metric.

We have saved all metrics computed in our study in the `results` directory of our repository on Codeberg @our-code, along with the code used to compute them and produce visualizations in the same repository.

= CONCLUSION
For all transformations except for the `Mirroring` transformation, both DeepGaze IIE and UNISAL models perform worse than the untransformed set of images. Increasing the intensity of the transformation leads to further loss in prediction accuracy.

Even so, there is a correlation between prediction accuracy on a untransformed image and prediction accuracy on a transformed image, except for some transformations with weak correlations which the models particularly struggle with. We find that for those transformations with a weaker correlation, the plots of paraboles of best fit seems to indicate a curve of diminishing returns, where improvements in prediction accuracy for transformed images do not keep up with improvements in prediction accuracy for untransformed images.

We find that for the contrast change transformations only, the image-based correlation coefficient between the predictions for an untransformed image and its transformation is a weak heuristic for predicting the performance of a model on transformed images. In this unique case, one can infer some information about a model's performance on contrast-changed images without gathering human trial data. Applying this correlation differently, we might infer that transformations which display this behavior are label-preserving.

Our work indicates that current state-of-the-art gaze prediction models are likely to have biases present in their training data towards candid photography. Extrapolating from the fact that models struggle with some common digital transformations, and that digital post-processing is common for digital visual media, we hypothesize that models will perform poorly on stylized images, or images which have been altered for aesthetic purposes.

For future work, we would like to test a greater number of transformations, including digital distortions, color manipulations, and stylistic filters, or compositions of all of the above, which are other common digital transformations used in visual media. We might also test compilations of stylized images, rather than pairs of images and their transformations. We would also like to study the characteristics of potential label-preserving transformations in greater detail.

Finally, we would like to test transformations with more rigorous definitions of "intensity", at a granular level such that we can more accurately elucidate trends in performance as we increase the intensity of the transformation.

#bibliography("thesis.bib", title: "REFERENCES")