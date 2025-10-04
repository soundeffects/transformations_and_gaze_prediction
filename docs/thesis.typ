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

This regularized saliency map is our best proxy for the real gaze distribution. We will refer to it as the "real map" for brevity.

Gaze prediction models will compute a saliency map for an image using only the image's contents. It will not have access to any fixation points gathered from human subjects. Using performance metrics whose computation we will describe shortly, one can use those metrics computed on the real map as a reference point for the upper limit of performance for those metrics computed on the gaze prediction model's output.

We wish also to find a lower reference point for performance. For a prediction to be a lower reference point, it should predict any features or biases that are common in the dataset or class of images we are studying, but should not predict any features based on the image's contents. This will allow us to see what information the gaze prediction model can inference from an image itself, rather than any assumptions the model might make based on previous experience with the dataset or class of images.

An adequate lower reference point can be computed by collecting all fixation points for the entire dataset of interest, and regularizing similar to the real map. This is usually referred to as the "center bias", due to the prevalent tendency of most human subjects (and therefore datasets of human gaze behavior) to fixate towards the center of an image. The centerbias will account for most dataset-wide biases because of the averaging across all images in the dataset, and it will weight any fixations which were specific to any given image to a lesser degree due to the averaging as well.

(Note that one can compute a more "competitive" lower reference point by using a cross-validation approach to improve upon the centerbias, as shown by Matthias Kümmerer, Thomas S. A. Wallis, and Matthias Bethge @information-gain. We find that the improvement this step provides is marginal, and so we omit the process. For more details, see the "Method" section.)

We compare saliency maps using metrics compiled by Zoya Bylinskii, Tilke Judd, Aude Olivia, Antonio Torralba and Frédo Durand @saliency-metrics. Each metric computes a measure of either divergence or similarity between two saliency maps, or measures the saliency values at a set of fixation points. We evaluate the usefulness and qualities of each metric as it pertains to our study in the "Method" section.

Using these metrics, if a saliency map produced by a gaze prediction model is closer to the real map than the center bias, we can conclude that the gaze prediction model is performing well.

The most widely adopted benchmark for gaze prediction model performance is the MIT/Tuebingen Saliency Benchmark @mit-tuebingen, which lists many of the metrics described by Bylinskii et al. @saliency-metrics to compare the performance of submitted models. We intended to select the current top contender on the benchmark, DeepGaze IIE @deepgazeiie, and a lower accuracy but faster-running and smaller memory-footprint model, UNISAL @unisal, as our state-of-the-art models for our study. Both of these models perform better than the centerbias on the MIT/Tuebingen Saliency Benchmark for the CAT2000 dataset (which the Che et al. @gaze-transformations dataset is derived from), while the models Che et al. @gaze-transformations studied performed worse.

Unfortunately, we were unable to replicate the performance expected from the DeepGaze IIE model, and so we continued our study only using the UNISAL model. More details are described in the "Experiment" section.

= METHOD
We wish to produce a method which shows whether a predicted gaze density adheres to the real gaze density when considering an image that is transformed with one of three classes of transformation.

First, let us define some terms. We will refer to the gaze density of an image before a transformation as the "prior density", and the gaze density of the image after a transformation as the "subsequent density". We will refer to KL-divergence as "divergence" for brevity. We define "adherence" to be a condition for a transformation, such that the divergence of a prior density to its appropriate real gaze density is greater than or equal (to within 5% of the divergence value) to the corresponding subsequent density to its real gaze density, for 95% of images tested under the transformation.

We call such a transformation a "composable" transformation. Assuming a transformation has been tested for adherence over a large number and large variety of images, we can be confident that the gaze prediction model understands the transformation and its effects on gaze behavior. Composable transformations may be applied freely to an image without concern for degrading the model's performance.

TODO:
- Obviously, if divergence is low, then it stands to reason that greater subsequent adherence is likely.
- If divergence is higher, but information asymmetry is low, then greater subsequent adherence might be the case: we should study.
- Check divergence, information asymmetry, and a  product of both metrics for binary classification and for error bound/trend
- Figure out where to set confidence bounds for adherence

We wish to provide evidence that two metrics, computed on the prior density and the subsequent density, are statistically significant heuristics for whether the adherence of the subsequent density is roughly equal or greater than the adherence of the prior density to its corresponding real gaze density.

We will argue that the condition of greater subsequent adherence implies that the transformation does not degrade the performance of a gaze prediction model. We will refer to this condition as "composability". Transformations that have been proven composable for a gaze prediction model can be applied to images freely, without the need for consideration of the effects on the model's performance.

The first metric is KL-divergence, which will referred to henceforth simply as "divergence". The second is the difference in information gain between the two distributions. We we will invent the term "information asymmetry" to refer to this difference in information gain.

We apply the stylization at relative strengths, such that we can study whether a stylization has non-linear effects on the prediction.

So that we can compare the effects of different stylizations, we normalize the KL-divergence and information gain difference by the size of the image and the least-squares difference between the stylization and the original image. The resulting metric tells us the effect size per pixel of the image, per pixel intensity value altered by the stylization. We compute the mean, median, and standard deviation of these normalized metrics across all images for a given stylization.

We use the divergence and information gain difference resulting from random noise as a control group for the comparison of effects of stylizations. If a stylization produces lower metrics than random noise, the stylization has little effect on the prediction produced by the model, and vice versa for higher metrics.

If a stylization produces metrics significantly different from random noise, whether lower or higher, and if an explanation for the effect based on human visual behavior can't be produced, it warrants further study and training for the model. The same can be said for metrics which are not significantly different, contrary to expectation from human visual behavior.

TODO: 
- add problem statement to the end of background
- add the paper references to MIT benchmark

#bibliography("paper.bib", title: "REFERENCES")