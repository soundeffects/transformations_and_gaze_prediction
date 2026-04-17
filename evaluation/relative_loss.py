from csv import DictReader, DictWriter

performance_data = {}
with open("../results/relative_loss.csv", 'r', newline='') as csvfile:
    reader = DictReader(csvfile)
    for row in reader:
        if row["transformation"] not in performance_data:
            performance_data[row["transformation"]] = {}
        performance_data[row["transformation"]][row["model"]] = { "nss": float(row["median_nss"]), "ig": float(row["median_ig"]) }

r = performance_data["Reference"]
deepgaze_reference_median_nss = (r["deepgaze_1024_576"]["nss"] - r["centerbias"]["nss"]) / (r["real"]["nss"] - r["centerbias"]["nss"])
deepgaze_reference_median_ig = r["deepgaze_1024_576"]["ig"] / r["real"]["ig"]
unisal_reference_median_nss = (r["unisal_384_224"]["nss"] - r["centerbias"]["nss"]) / (r["real"]["nss"] - r["centerbias"]["nss"])
unisal_reference_median_ig = r["unisal_384_224"]["ig"] / r["real"]["ig"]

relative_loss_data = []
for transformation in performance_data.keys():
    data = performance_data[transformation]
    deepgaze_median_nss = (data["deepgaze_1024_576"]["nss"] - data["centerbias"]["nss"]) / (data["real"]["nss"] - data["centerbias"]["nss"])
    deepgaze_median_ig = data["deepgaze_1024_576"]["ig"] / data["real"]["ig"]
    unisal_median_nss = (data["unisal_384_224"]["nss"] - data["centerbias"]["nss"]) / (data["real"]["nss"] - data["centerbias"]["nss"])
    unisal_median_ig = data["unisal_384_224"]["ig"] / data["real"]["ig"]

    deepgaze_median_nss_delta = deepgaze_median_nss - deepgaze_reference_median_nss
    deepgaze_median_ig_delta = deepgaze_median_ig - deepgaze_reference_median_ig
    unisal_median_nss_delta = unisal_median_nss - unisal_reference_median_nss
    unisal_median_ig_delta = unisal_median_ig - unisal_reference_median_ig

    relative_loss_data.append({
        "transformation": transformation,
        "deepgaze_median_nss_delta": deepgaze_median_nss_delta,
        "deepgaze_median_ig_delta": deepgaze_median_ig_delta,
        "unisal_median_nss_delta": unisal_median_nss_delta,
        "unisal_median_ig_delta": unisal_median_ig_delta
    })

    print(f"{transformation} & {deepgaze_median_nss_delta:.2%} & {deepgaze_median_ig_delta:.2%} & {unisal_median_nss_delta:.2%} & {unisal_median_ig_delta:.2%} \\\\")

with open("../results/relative_loss_next.csv", "w", newline="") as csvfile:
    writer = DictWriter(csvfile, ["transformation", "deepgaze_median_nss_delta", "deepgaze_median_ig_delta", "unisal_median_nss_delta", "unisal_median_ig_delta"])
    writer.writeheader()
    writer.writerows(relative_loss_data)

