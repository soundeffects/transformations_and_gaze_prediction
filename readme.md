# Effects of Transformations on Gaze Prediction
Code associated with my thesis *Digital Image Transformations Degrade Gaze Prediction Accuracy*, which can be found under
the `docs` directory in this repository.

## Run It Yourself
- The dataset has been redistributed on Google Drive: https://drive.google.com/file/d/1JFCYDkm0x1ssk8P7Cii6tA_xQ2i-udhY/view?usp=sharing. Download and unzip into a directory named `data`. Transformation directories should be directly under the `data` directory, i.e. `data/Boundary`, etc.
- Install [`uv`](https://docs.astral.sh/uv/#installation) (Python package manager)
- To run the DeepGaze prediction code in `deepgaze_predict`, you need to add the DeepGaze github repository as a dependency using `uv pip install -e https://github.com/matthias-k/DeepGaze`
- Run using the shell script: `sh run_experiment.sh`
