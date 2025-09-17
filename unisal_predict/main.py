from numpy import array, save
from pathlib import Path
from PIL import Image
from torch import no_grad, cuda
from unisal.unisal.model import UNISAL

DEVICE = 'cuda'

def predict(image_paths: list[Path]) -> None:
    trainer = {
        "num_epochs": 16,
        "optim_algo": "SGD",
        "momentum": 0.9,
        "lr": 0.04,
        "lr_scheduler": "ExponentialLR",
        "lr_gamma": 0.8,
        "weight_decay": 1e-4,
        "cnn_weight_decay": 1e-5,
        "grad_clip": 2.0,
        "loss_metrics": ("kld", "nss", "cc"),
        "loss_weights": (1, -0.1, -0.1),
        "data_sources": ("DHF1K", "Hollywood", "UCFSports", "SALICON"),
        "batch_size": 4,
        "salicon_batch_size": 32,
        "hollywood_batch_size": 4,
        "ucfsports_batch_size": 4,
        "salicon_weight": 0.5,
        "hollywood_weight": 1.0,
        "ucfsports_weight": 1.0,
        "data_cfg": {},
        "salicon_cfg": {},
        "hollywood_cfg": {},
        "ucfsports_cfg": {},
        "shuffle_datasets": True,
        "cnn_lr_factor": 0.1,
        "train_cnn_after": 2,
        "cnn_eval": True,
        "model_cfg": { "sources": ("DHF1K", "Hollywood", "UCFSports", "SALICON") },
        "prefix": utils.get_timestamp(),
        "suffix": "unisal",
        "num_workers": 6,
        "chkpnt_warmup": 3,
        "chkpnt_epochs": 2,
        "tboard": True,
        "debug": False,
        "new_instance": True,
        "device": torch.device(DEVICE),
        "epoch": 0,
        "phase": None,
        "_datasets": {},
        "_dataloaders": {},
        "_scheduler": None,
        "_optimizer": None,
        "_model": model.UNISAL(sources=("DHF1K", "Hollywood", "UCFSports", "SALICON")),
        "best_epoch": 0,
        "best_val_score": None,
        "is_best": False,
        "all_scalars": {},
        "_writer": None,
        "_salicon_datasets": {},
        "_salicon_dataloaders": {},
        "_hollywood_datasets": {},
        "_hollywood_dataloaders": {},
        "_ucfsports_datasets": {},
        "_ucfsports_dataloaders": {},
        "mit1003_finetuned": False,
    }
    unisal = UNISAL(sources=("DHF1K", "Hollywood", "UCFSports", "SALICON"))
    # unisal.load_weights(train_dir, "ft_mit1003")
    unisal.load_best_weights(Path("training_runs/pretrained_unisal"))
    unisal.to(DEVICE)
    unisal.eval()
    cuda.empty_cache()
    # trainer.copy_code()
    source = "SALICON" # CAT2000
    with no_grad():
        # dataset = data.FolderImageDataset(Path("../data/Boundary/images"))
        # pred_dir = folder_path / "saliency"
        # pred_dir.mkdir(exist_ok=True)

        for image_path in image_paths:
            output_path = Path(str(image_path).replace('images', 'unisal').replace('png', 'npy'))
            if output_path.exists():
                continue
            try:
                image_data = array(Image.open(image_path))
            except:
                print("failed", str(image_path))
                continue
            args = {
                "source": source,
                "vid_nr": image_path, # img_idx in range(len(dataset))
                "dataset": dataset,
                "seq_len_factor": 0.5,
                "random_seed": 27,
            }
            # Get the original resolution
            target_size = dataset.target_size_dict[vid_nr]

            # Set the keyword arguments for the forward pass
            model_kwargs = {"source": source, "target_size": target_size, "static": True }

            # Set additional parameters
            n_images = 1
            unisal.to(DEVICE)
            unisal.eval()
            cuda.empty_cache()

            # Prepare the prediction and target tensors
            results_size = (1, n_images, 1, *model_kwargs["target_size"])
            pred_seq = torch.full(results_size, 0, dtype=torch.float)
            sal_seq, fix_seq = None, None

            # Define input sequence length
            # seq_len = self.batch_size * self.get_dataset('train').seq_len * \
            #     seq_len_factor
            seq_len = int(12 * seq_len_factor)

            sample = dataset.get_data(vid_nr)

            # Preprocess the data
            sample = sample[:-1]
            if len(sample) >= 4:
                # if len(sample) == 5:
                #     sample = sample[:-1]
                frame_nrs, frame_seq, this_sal_seq, this_fix_seq = sample
                this_sal_seq = this_sal_seq.unsqueeze(0).float()
                this_fix_seq = this_fix_seq.unsqueeze(0)
                if frame_seq.dim() == 3:
                    frame_seq = frame_seq.unsqueeze(0)
                    this_sal_seq = this_sal_seq.unsqueeze(0)
                    this_fix_seq = this_fix_seq.unsqueeze(0)
            else:
                frame_nrs, frame_seq = sample
                this_sal_seq, this_fix_seq = None, None
                if frame_seq.dim() == 3:
                    frame_seq = frame_seq.unsqueeze(0)
            frame_seq = frame_seq.unsqueeze(0).float()
            frame_idx_array = [f_nr - 1 for f_nr in frame_nrs]
            frame_seq = frame_seq.to(self.device)

            # Run all sequences of the current offset
            h0 = [None]
            for start in range(0, len(frame_idx_array), seq_len):

                # Select the frames
                end = min(len(frame_idx_array), start + seq_len)
                this_frame_seq = frame_seq[:, start:end, :, :, :]
                this_frame_idx_array = frame_idx_array[start:end]

                # Forward pass
                this_pred_seq, h0 = self.model(
                    this_frame_seq, h0=h0, return_hidden=True, **model_kwargs
                )

                # Insert the predictions into the prediction array
                this_pred_seq = this_pred_seq.cpu()
                pred_seq[:, this_frame_idx_array, :, :, :] = this_pred_seq

            # Posporcess prediction
            smap = smap.exp()
            smap = torch.squeeze(smap)
            smap = utils.to_numpy(smap)

            prediction = predicted_sequence[:, 0, ...]
            detached_prediction = array(prediction.detach().cpu().numpy()) # TODO: Check return value of these functions
            output_path.parent.mkdir(parents=True, exist_ok=True)
            save(output_path, detached_prediction)