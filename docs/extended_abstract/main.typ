#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

#let asterisk = super(sym.ast.basic)

#let title = [Reliability of Gaze Prediction for Stylized and Transformed Images]
#let authors = (
  (
    name: "James Youngblood",
    department: "Kahlert School of Computing",
    institute: "The University of Utah",
    city: "Salt Lake City, UT, USA\njames@youngbloods.org",
    email: "james@youngbloods.org",
  ),
  (
    name: "Rogelio Cardona-Rivera",
    department: "Games Division",
    institute: "The University of Utah",
    city: "Salt Lake City, UT, USA\nr.cardona.rivera@utah.edu",
    email: "r.cardona.rivera@utah.edu",
  ),
)
#let affiliations = ()
#let conference = (
  name:  [2026 ACM Siggraph Symposium on Interactive 3D Graphics and Games],
  short: [I3D Symposium 2026],
  year:  [2026],
  date:  [May 13-15],
  venue: [San Francisco, CA, USA],
)
#let doi = "https://doi.org/10.1145/0000000000"
#let ccs = (
  (
    generic: [Computing Methodologies],
    specific: (
      [Interest point and salient region detection],
      [Cross-validation],
      [Neural networks],
      [Perception],
      [Image processing],
      [Non-photorealistic rendering]
    ),
  ),
)
#let keywords = ("saliency", "visual attention", "generalizability", "visual fixation prediction", "rendering")

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: conference,
  doi: doi,
  copyright: "cc",
)


= Abstract
Recent advancements have shown increasingly accurate and fast visual gaze prediction models, which might now be feasible for real-time scenarios. These gaze prediction models would allow a program to infer where a user might focus on in an rendered scene, and might allow unique program behavior, rendering optimizations based on perception, or modelling of the user's visual attention, without requiring direct eye-tracking hardware. Current state-of-the-art models use deep learning techniques, and most published image data sets for training are biased towards photography, at the expense of computer-rendered scenes, especially those with stylized subjects. We raise concerns over the generalizability of state-of-the-art models. We study a number of digital image transformations on existing datasets, using them as a reference point for what various rendering techniques or stylization effects might have on gaze prediction models. Our findings show that state-of-the-art models perform significantly worse on common image transformations. Our experiments reveal no significant, computable indicators of loss in accuracy, meaning more human gaze distribution data must be gathered in order to train and validate the generalizability of gaze prediction models.

#acmart-ccs(ccs)
#acmart-keywords(keywords)
#acmart-ref(to-string(title), authors, conference, doi)

= Introduction <sec:intro>
Recent years have seen many advancements in the field of visual fixation prediction, which is the
task of predicting the points at which a human will first focus on within the area of an image
(sometimes called the "saliency" of an image). Droste et al. provide a new gaze prediction
model, called UNISAL @unisal, which is among the top performing models on the MIT/Tuebingen
Saliency Benchmark @mit-tuebingen, and which generates predictions on frames in the DHF1K
@dhf1k dataset in nine milliseconds, moving gaze prediction tasks into the realm of real-time
computing.

The most prominent published data sets for image saliency, including the MIT 300 @mit300 and
CAT 2000 @cat2000, provide only a handful of 3D computer-rendered scenes. Even the amount of
stylized art, such as painting and collage, is noticeably lesser than that of photos of
physical subjects in these datasets. The report from Kümmerer et al. @annurev-vision shows that
leading gaze prediction models use deep-learning techniques, and the black-box nature of these
techniques raises concerns that the models will not generalize well to all classes of images,
especially those which are under-represented in the training data set.

= Method <sec:method>
Although we wish to study model accuracy on computer-rendered images against benchmark results,
we realize that it is difficult to isolate against the effects of uncontrolled variables when
comparing two differing data sets. Instead, we hypothesize that digital transformations of a set
of images, when compared to the untransformed images, will degrade the model's predictive
accuracy. We assume that by showing common digital transformations degrade accuracy, we show
that the models cannot be expected to generalize well to many other domains of images,
including stylized and computer-rendered images, especially those which have visual
similarities to the transformations we test.

We utilize the dataset produced by Che et al. @gaze-transformations, which randomly selects 100
images from the CAT 2000 @cat2000 dataset, produces corresponding transformed images for 18
transformation types, and measures gaze distributions of human subjects for all 1900 images. For
each image, we measure its score on the NSS @nss and IG @information-gain metrics, and express
those scores as percentages of the "gold standard" minus the "center bias" scores. The gold
standard and the center bias are are described by Kümmerer et al. @information-gain to be the
"best guess" for an image with all image-specific human gaze data considered, and with only
dataset-specific human gaze data considered, respectively. Together, they provide a good upper
bound and lower reference point with which to consider a model's prediction accuracy.
Expressing scores within this range allows us to find model degradation beyond that which might
be expected due to a destructive or non-reversible transformation, as the degradation in
performance produced by any destructive transformation should be captured by the gold standard
and center bias for that transformation.

= Results <sec:results>
We find that for both DeepGaze IIE @deepgazeiie and UNISAL models, which hold top spots
on the MIT/Tuebingen Saliency benchmark, all transformations except a simple horizontal mirror
transformation result in loss of 5 to 95 percentage points of the center bias/gold standard
range, for both IG and NSS metrics, relative to untransformed images. Untransformed images
perform roughly in line with benchmark expectations, while almost all transformed images degrade
to some degree beyond that which can be expected by loss of information during the
transformation. These findings support our hypothesis, and seem to indicate that current models
have poor generalizability to stylized images which bear resemblance to the common
transformations we tested (including cropping, gaussian noise, contrast adjustment, rotation,
shearing, motion blur, and edge enhancement).

== Accuracy Loss Indicators
IG and NSS are the most useful metrics for measuring predictive accuracy, but we computed
many others described by Bylinskii et al. @saliency-metrics during our experiment. We were
curious to see if any of the metrics we tested were indicators of loss in predictive accuracy
for any transformation. Unfortunately, linear correlation revealed no strong trends between the change in any metric between untransformed and transformed images, and loss in accuracy. There
is no method for revealing a model's loss in predictive accuracy for a class of images other
than measuring against human gaze distributions, according to the knowledge of the authors.

= Conclusion <sec:conclusion>
Our work indicates that state-of-the-art gaze prediction models cannot be relied on to produce
predictions that are as accurate as benchmarks profess for images that are not well represented
by prominent saliency data sets. This includes stylized and computer-rendered images. Unlocking
gaze prediction for real-time rendering applications will likely require much greater amounts of
training data and validation studies for these models.

Code for model inference, metric computation, and visualization of data; as well as plaintext data
for our results; can be found at our repository @our-code.

#bibliography("main.bib", title: "References", style: "association-for-computing-machinery")

#colbreak(weak: true)
#set heading(numbering: "A.a.a")
