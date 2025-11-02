# Effects of Transformations on Gaze Prediction
Code associated with my thesis *Digital Image Transformations Degrade Gaze Prediction Accuracy*, which can be found under
the `docs` directory in this repository.

You're probably viewing this code on one of two mirrors. You may choose to browse using whichever
you prefer.
- Github: https://github.com/soundeffects/transformations_and_gaze_prediction
- Codeberg: https://codeberg.org/soundeffects/transformations_and_gaze_prediction

## Run It Yourself
- The dataset has been redistributed on Google Drive: https://drive.google.com/file/d/1JFCYDkm0x1ssk8P7Cii6tA_xQ2i-udhY/view?usp=sharing. Download and unzip into a directory named `data`. Transformation directories should be directly under the `data` directory, i.e. `data/Boundary`, etc.
- Install [`uv`](https://docs.astral.sh/uv/#installation) (Python package manager)
- To run the DeepGaze prediction code in `deepgaze_predict`, you need to add the DeepGaze github repository as a dependency using `uv pip install -e https://github.com/matthias-k/DeepGaze`
- Run using the shell script: `sh run_experiment.sh`

## License
The contents of this repository are distributed under the MIT License, as seen in the `license` file, except for the thesis manuscript found at the location `docs/thesis.typ`, which is distributed under the [CC BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/).
