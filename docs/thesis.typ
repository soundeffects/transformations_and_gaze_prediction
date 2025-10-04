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
#let title = "TRANSFORMING IMAGES DEMONSTRATES DEGRADATION OF GAZE FIXATION PREDICTION PERFORMANCE"
#let abstract = [  
  Using saccadic fixation points collected on reference images and the transformations of those images, we show that common digital image transformations--including cropping, rotation, contrast adjustment, and noise overlay--significantly degrade the performance of state-of-the-art gaze fixation prediction models. We show that there are no reliable heuristics which indicate the degradation of performance for image transformations in general; the collection of real gaze distribution data on transformed images is required.
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
The prediction of human gaze behavior, sometimes referred to as saliency, has many potential use cases. Our study is motivated by the potential for new interactive experiences which operate on knowledge of where the player is looking.

However, for most of these use cases, it is difficult to constrain the image a gaze prediction model will see to a specific style or class of image, such as those we see in datasets that the models train on. The number of studies which test the effects of images which stray from these datasets is sparse, and out of date with the state-of-the-art models.

Gaze prediction models are notably biased towards candid photography: Matthias Kümmerer and Matthias Bethge @annurev-vision show that all leading gaze prediction models utilize transfer learning from other problem domains, primarily object recognition. Researchers do this becase of the lack of training data for the gaze recognition task, relative to the object recognition task.  The object recognition task prioritizes candid photography over stylistic representations due to the assumption that object recognition applications usually involve unaltered images captured with a camera, but this assumption does not hold true for the gaze prediction task. This assumption is implicitly encoded into most of the training data a gaze prediction model will see, and so the model's performance may suffer when generalizing to stylized images.

Furthermore, a study by Zhaohui Che, Ali Borji, Guangtao Zhai, Xiongkuo Min, Guodong Guo and Patrick Le Callet @gaze-transformations shows that image transformations influence gaze fixations, and effects of transformations on gaze behavior may be difficult to model. This fact is problematic, because modern visual productions use multiple steps of image processing and rendering for stylistic effect. Each step represents an image transformation, and a possible degradation of gaze prediction performance.

Our work measures the performance of state-of-the-art gaze prediction models on images which have been transformed with common image transformations,using the data from Che et al., and we find that the performance degrades significantly.

Additionally, we correlate derived metrics gathered from the images and their transformations, in an effort to find heuristics that signal how much a prediction's accuracy has degraded without the need to conduct a human study. Unfortunately, we find that there are no significant relationships between the metrics and the performance of the model on the transformed image.

= RELATED WORK
The effects of image transformations--including cropping, rotation, skewing, and edge detection--on gaze behavior are studied by Che et al. @gaze-transformations. Their paper is motivated by the possibility of augmenting gaze prediction datasets with transformed images. We extend their work by repeating their experiments using current state-of-the-art models which had not been published at the time. Rather than analyze our results with the intention to augment a training dataset, as Che et al. did, we analyze our results to determine the extent to which prediction performance might degrade when transformations of various kinds are aplpied, and whether there are reliable heuristics which can be used to predict the degradation of performance of a gaze prediction model on a transformed image.

The effects of digital image alterations on gaze behavior have also been studied by Rodrigo Quian Quiroga and Carlos Pedreira @quianquiroga, who performed an experiment collecting gaze fixations before and after manual Photoshop edits were made to photographs of paintings. Insufficient explanation for the intention behind edits makes it difficult to formally and generally describe the image transformations they studied. Instead, we study computationally-modeled image transformations, such that we can describe the effects they produce on gaze behavior more formally and generally, and so that we can study a greater scale of data which does not require human decisions for each image.

= BACKGROUND
The foundations we build upon are reviewed comprehensively by Kümmerer et al. @annurev-vision. We will briefly describe key terms and concepts.

In the process of studying an image, the human eye will occasionally jump to a new fixation point in what is called a "saccade". Both measured and predicted gaze can be represented by a two-dimensional probability distribution. This is usually represented using a grayscale image called a "saliency map".

Under this definition of a saliency map, pixels with the highest intensity are those most likely to be the next fixation target after a saccade for an arbitrary person under "free-viewing" conditions (which means the person has not been instructed to search for an element of the image).

When collecting gaze distribution data from human subjects, we receive a collection of saccadic fixation points from an eye tracker over the area of the image presented to the subject. Converting these points into a saliency map can be done by brightening the pixels each point falls under and normalizing to a probability distribution, but such a saliency map is "speckled" rather than smooth, and likely diverges from the real gaze distribution because of the limited sample size of fixation points.

// figure of speckled saliency map

When testing greater fixation point sample sizes, we see that on the limit of infinite sample size, the saliency map would converge to a smooth probability distribution rather than a discrete point cloud. Thus, if we wish to obtain a better estimate of the real gaze distribution, we should blur the saliency map with a Gaussian kernel to obtain a smoother probability distribution. This step is referred to as "regularization". (It is convention to set the size of the Gaussian kernel to a pixel value equivalent to one degree of visual angle in length from the human subject's perspective.)

// figure of a smoothed saliency map

This regularized saliency map is our best proxy for the real gaze distribution. We will refer to it as the "real map" for brevity.

Gaze prediction models will compute a saliency map for an image using only the image's contents. It will not have access to any fixation points gathered from human subjects. Using performance metrics whose computation we will describe shortly, one can use those metrics computed on the real map as a reference point for the upper limit of performance for those metrics computed on the gaze prediction model's output.

We wish also to find a lower reference point for performance. For a prediction to be a lower reference point, it should predict any features or biases that are common in the dataset or class of images we are studying, but should not predict any features based on the image's contents. This will allow us to see what information the gaze prediction model can inference from an image itself, rather than any assumptions the model might make based on previous experience with the dataset or class of images.

An adequate lower reference point can be computed by collecting all fixation points for the entire dataset of interest, and regularizing similar to the real map. This is usually referred to as the "center bias", due to the prevalent tendency of most human subjects (and therefore datasets of human gaze behavior) to fixate towards the center of an image. The centerbias will account for most dataset-wide biases because of the averaging across all images in the dataset, and it will weight any fixations which were specific to any given image to a lesser degree due to the averaging as well.

// figure of centerbias

(Note that one can compute a more "competitive" lower reference point by using a cross-validation approach to improve upon the centerbias, as shown by Matthias Kümmerer, Thomas S. A. Wallis, and Matthias Bethge @information-gain. We find that the improvement this step provides is marginal, and so we omit the process. For more details, see the "Method" section.)

We compare saliency maps using metrics compiled by Zoya Bylinskii, Tilke Judd, Aude Olivia, Antonio Torralba and Frédo Durand @saliency-metrics. Each metric computes a measure of either divergence or similarity between two saliency maps, or measures the saliency values at a set of fixation points. We evaluate the usefulness and qualities of each metric as it pertains to our study in the "Method" section.

Using these metrics, if a saliency map produced by a gaze prediction model is closer to the real map than the center bias, we can conclude that the gaze prediction model is performing well.

The most widely adopted benchmark for gaze prediction model performance is the MIT/Tuebingen Saliency Benchmark @mit-tuebingen, which lists many of the metrics described by Bylinskii et al. @saliency-metrics to compare the performance of submitted models. We intended to select the current top contender on the benchmark, DeepGaze IIE @deepgazeiie, and a lower accuracy but faster-running and smaller memory-footprint model, UNISAL @unisal, as our state-of-the-art models for our study. Both of these models perform better than the centerbias on the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset (which the Che et al. @gaze-transformations dataset is derived from), while the models Che et al. @gaze-transformations studied performed worse.

Unfortunately, we were unable to replicate the performance expected from the DeepGaze IIE model, and so we continued our study only using the UNISAL model. More details are described in the "Results" section.

= METHOD
We use the dataset provided by Che et al. @gaze-transformations, which includes 100 randomly selected images from the CAT2000 dataset @cat2000, with 18 different transformations applied to each image. This produces a total of 1900 images, including the reference untransformed images. See figure 2 for examples of all 18 transformations. Gaze fixation points are recorded for each image.

// figure of all 18 transformations

We compute the centerbias for the reference (untransformed) set and each transformation set by collecting all fixation points for the images of the transformation and applying a Gaussian blur with a kernel size of 57 pixels, which is one degree of visual angle according to Che et al. As reported in the "Results" section, we find that the centerbias performs closely to the reported performance of the centerbias on the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset for the reference (untransformed) images. Given this, we decide to omit any cross-validation step as improvements would be marginal.

// Centerbias example

We also compute the real map for each image using the same Gaussian blur kernel on the fixation points for each image separately.

// Real map example

We run the DeepGaze IIE @deepgazeiie and UNISAL @unisal models on all reference and transformed images. The dataset images are at 1920x1080 resolution, and we run inference for both models at this resolution, but we also run inference for downscaled images which better match the expected resolution of the models. DeepGaze IIE @deepgazeiie expects an image with a width of 1024, so we downscale the images to 1024x576 for another DeepGaze inference. UNISAL @unisal expects several resolutions for different datasets it was trained on, so we run an inference for the resolutions of 384x224 (which matches the DHF1K dataset [citation needed] resolution), 384x288 (which matches the SALICON dataset [citation needed] resolution), and 384x216 (which preserves the ratio of the 1920x1080 image, but with a width of 384). We run inference for each model at each resolution, and intend to select the best-performing resolution for each model.

There will be two steps to our study. First, we wish to evaluate the performance of the models on both reference and transformed images. When comparing average performance, we hypothesize that the model's performance will be degraded, but we wish also to get a sense of how much the performance degrades in our analysis, if possible.

Second, we wish to find a correlation between any metrics we can derive from a source gaze distribution dataset and transformations upon that dataset, without having to gather human trials or real gaze distributions, that can be used as a heuristic to estimate the performance of a model's predictions for a type of transformation in general. We will look to the metrics described by Bylinskii et al. @saliency-metrics for both the first and the second step.

We consider the metrics described by Bylinskii et al. @saliency-metrics to compare saliency maps produced by models. These metrics include area-under-the-curve (AUC-Judd, citation needed) metric, the shuffled area-under-the-curve (sAUC, citation needed) metric, the histogram similarity metric (SIM, citation needed), the correlation coefficient metric (CC, citation needed), the Kullback-Leibler divergence metric (KL, citation needed), the information gain metric (IG, citation needed), and the Earth Mover's Distance metric (EMD, citation needed).

We wish to isolate the most relevant metrics for our study. With relevant metrics, we can evaluate model performance and conduct statistical and correlation analysis. However, by checking too many metrics, we increase the likelihood of false positives when searching for relationships between metrics due to noise. Thus, we select metrics with the most useful qualities and most significance.

The metrics cluster into rank-correlated groups. Bylinskii et al. @saliency-metrics show that the AUC-Judd, sAUC, SIM, CC, NSS, and EMD metrics are highly rank-correlated to each other on the MIT/Tuebingen Saliency Benchmark @mit-tuebingen. Additionally, they find that IG and KL metrics are rank-correlated in a separate group. If we find an external correlation exists for a metric in one of these groups, and we assume that the rank correlation between the metrics of the group is close enough to a linear relationship such that it does not excessively weaken or distance any transitive relationships, then the external correlation must also exist for the other metrics of the group. We will make the above assumption, and so we should select the fewest metrics possible from each group.

We decide against the AUC metric because it is invariant to monotonic transformations, and has saturated benchmarks due to this property. We would like to be sensitive to the relative importance of salient regions, which the AUC metric is not.

We decide against the sAUC metric because it assumes no centerbias is present in the saliency maps that a model produces, and we wish to include centerbias in our study such that we study holistic viewing behavior.

We decide against the SIM metric because it is not symmetrical for false positives and negatives, meaning a false negative will impact the score more than a false positive.

We decide against the EMD metric because it priorities the accuracy of relative saliency of regions, but does not prioritize the accurate placement of those regions. These are opposite priorities to our motivating causes for the study--we want to know where a user is looking as accurately as possible.

Thus, for the first group, we select the NSS and CC metrics. NSS is favored, because it is parameter-free whereas CC requires a decision on the size of a gaussian kernel to blur the saliency map before computation, as Bylinskii et al. @saliency-metrics recommend for fair comparisons between saliency maps that include various frequencies of information. However, NSS compares a saliency map to a set of fixation points, whereas CC compares two saliency maps. Fixation points are not available when comparing between two saliency maps that where produced by two model inferences, for example.

For the second rank-correlated group, we select the IG and KL metrics. IG is favored, because it provides a comparitive measure against a baseline (the centerbias), and because it is parameter-free, but once again requires fixation points. KL requires the same tuning of the gaussian kernel size as CC, and also does not require fixation points.

Thus, we can apply the metrics we have selected to the two steps of our study. For the first step, we will compute average NSS and IG metrics for each transformation set, and compare the average performance of the models on the transformed images to the average performance of the models on the reference images.

For the second step, we will compute the structural similarity index (SSIM, citation needed) between the reference and transformed images, the CC and KL metrics between the saliency maps produced by the model for the reference and transformed image, and the NSS and IG metrics for the reference saliency map the model produced. These metrics are selected because they can be computed using only a reference dataset with gaze distribution records and any arbitrary image transformation, without the need to measure real gaze distributions for the transformed images. We collect these five metrics as our independent variables. Our dependent variables will be the NSS and IG metrics for the transformed saliency map the model produced.

We wish to find a correlation between any pair of independent and dependent variable. There are 10 possible pairs between these variables, and so we will perform 10 separate correlation tests for each transformation set of images. We will simply graph the independent and dependent variable values for each image in the transformation set to spot patterns, find a line of best fit, and compute the linear correlation coefficient for each pair of variables. From there, we will interpret any correlation with a correlation coefficient above 0.5 as significant, and interpret what meaning those significant relationships might have in the context of our study.

We recognize that it would be ideal to compute a measure of how likely it is that a relationship arises due to a non-representative sample of images, such as a p-value. In order to compute a p-value, you must determine how likely it is that a given sample, in this case an image, is representative of the class of images you wish to study. This would be difficult due to the vague nature of image classes and determining whether an image is representative or not. We instead argue that, with our image class defined as "images from the CAT2000 dataset", and the assumption that the CAT2000 dataset is representative of images found in many other useful tasks we might apply gaze prediction models to, our sample size of 100 randomly selected images from the CAT2000 dataset is large enough to provide a reasonable basis for our study.

We make great effort to ensure our study is reproducible. Find the code and the data at the codeberg repository.

= RESULTS
We find that our centerbias performs closely to the reported performance of the centerbias on the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset for the reference (untransformed) images. (More accurate measurements here)

We also find that the UNISAL model performs similarly to the expectation set by the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset for the reference (untransformed) images. (More accurate measurements here)

However, we were unable to replicate the performance expected from the DeepGaze IIE model, despite our best efforts to follow the protocol outlined in the DeepGaze IIE paper. (More accurate measurements of how bad here) We have reached out to the authors of the paper for comment, but have not heard back yet, and so we continue our study only using the UNISAL model.

Though we found that UNISAL performs as expected for reference images, we find that it performs worse for transformed images. We find that the average NSS and IG metrics for the transformed images are significantly lower than the average NSS and IG metrics for the reference images. If using the centerbias as a binary threshold for whether the prediction is "good enough", then the UNISAL model would be good enough for reference images but not for transformed images. (More intuitive numbers here)



#bibliography("thesis.bib", title: "REFERENCES")