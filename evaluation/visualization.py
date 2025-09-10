import csv
import matplotlib.pyplot as plt
from metrics import regularize
import numpy as np
from utilities import directories, load_fixation_map, load_real_saliency_map, gaussian_filter, normalize_to_range

def load_and_process_data(csv_path):
    """Load and process the CSV data to extract metrics for comparison."""
    # Read CSV data
    data = []
    with open(csv_path, 'r', newline='') as file:
        reader = csv.DictReader(file)
        for row in reader:
            data.append(row)
    
    # Filter for summary statistics (mean, median, std)
    summary_data = [row for row in data if row['image_number'] in ['mean', 'median', 'std']]
    
    # Create separate lists for each model
    model_35 = [row for row in summary_data if row['model'] == 'centerbias_35']
    model_57 = [row for row in summary_data if row['model'] == 'centerbias_57']
    
    return model_35, model_57

def create_comparison_charts(model_35, model_57, save_path=None):
    """Create bar charts comparing the two models across different metrics."""
    
    # Get unique transformations and metrics
    transformations = list(set(row['transformation'] for row in model_35))
    metrics = ['nss', 'ig_35', 'ig_57']
    
    # Set up the plotting
    fig, axes = plt.subplots(1, 3, figsize=(18, 8))
    fig.suptitle('Model Comparison: centerbias_35 vs centerbias_57', fontsize=16, fontweight='bold')
    
    colors = ['#2E86AB', '#A23B72']  # Blue for 35, Red for 57
    
    for i, metric in enumerate(metrics):
        ax = axes[i]
        
        # Prepare data for this metric
        x = np.arange(len(transformations))
        width = 0.35
        
        # Get values for both models
        values_35 = []
        values_57 = []
        
        for trans in transformations:
            val_35 = next((float(row[metric]) for row in model_35 if row['transformation'] == trans), 0.0)
            val_57 = next((float(row[metric]) for row in model_57 if row['transformation'] == trans), 0.0)
            values_35.append(val_35)
            values_57.append(val_57)
        
        # Create bars
        bars1 = ax.bar(x - width/2, values_35, width, label='centerbias_35', color=colors[0], alpha=0.8)
        bars2 = ax.bar(x + width/2, values_57, width, label='centerbias_57', color=colors[1], alpha=0.8)
        
        # Customize the plot
        ax.set_xlabel('Transformation Type')
        ax.set_ylabel(metric.upper())
        ax.set_title(f'{metric.upper()} Comparison')
        ax.set_xticks(x)
        ax.set_xticklabels(transformations, rotation=45, ha='right')
        ax.legend()
        ax.grid(True, alpha=0.3)
        
        # Add value labels on bars
        for bar in bars1:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.3f}', ha='center', va='bottom', fontsize=8)
        
        for bar in bars2:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.3f}', ha='center', va='bottom', fontsize=8)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Chart saved to {save_path}")
    
    plt.show()

def create_summary_statistics_chart(model_35, model_57, save_path=None):
    """Create a chart showing summary statistics (mean, median, std) for NSS metric."""
    
    # Filter for NSS metric only
    nss_35 = next((float(row['nss']) for row in model_35 if row['image_number'] == 'mean'), 0.0)
    nss_57 = next((float(row['nss']) for row in model_57 if row['image_number'] == 'mean'), 0.0)
    
    # Get all transformations for NSS mean
    transformations = list(set(row['transformation'] for row in model_35))
    
    # Prepare data
    x = np.arange(len(transformations))
    width = 0.35
    
    values_35 = []
    values_57 = []
    
    for trans in transformations:
        val_35 = next((float(row['nss']) for row in model_35 if row['transformation'] == trans), 0.0)
        val_57 = next((float(row['nss']) for row in model_57 if row['transformation'] == trans), 0.0)
        values_35.append(val_35)
        values_57.append(val_57)
    
    # Create the plot
    fig, ax = plt.subplots(figsize=(15, 8))
    
    bars1 = ax.bar(x - width/2, values_35, width, label='centerbias_35', color='#2E86AB', alpha=0.8)
    bars2 = ax.bar(x + width/2, values_57, width, label='centerbias_57', color='#A23B72', alpha=0.8)
    
    ax.set_xlabel('Transformation Type')
    ax.set_ylabel('NSS Score (Mean)')
    ax.set_title('NSS Score Comparison: centerbias_35 vs centerbias_57 (Mean Values)', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(transformations, rotation=45, ha='right')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Add value labels on bars
    for bar in bars1:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
               f'{height:.3f}', ha='center', va='bottom', fontsize=9)
    
    for bar in bars2:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
               f'{height:.3f}', ha='center', va='bottom', fontsize=9)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Summary chart saved to {save_path}")
    
    plt.show()

def centerbias_performance_comparison(data_path: str = 'centerbias_fixation_metrics.csv'):
    """Main function to run the visualization."""
    data = []
    with open(data_path, 'r', newline='') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if row['image_number'] == 'mean':
                data.append((row['model'], row['transformation'], row['nss']))
            elif row['image_number'] == 'median':
                medians.append(row)
            elif row['image_number'] == 'std':
                stds.append(row)
    
    # Filter for summary statistics (mean, median, std)
    summary_data = [row for row in data if row['image_number'] in ['mean', 'median', 'std']]
    
    # Create separate lists for each model
    model_35 = [row for row in summary_data if row['model'] == 'centerbias_35']
    model_57 = [row for row in summary_data if row['model'] == 'centerbias_57']
    try:
        # Load and process data
        print("Loading data...")
        model_35, model_57 = load_and_process_data(csv_path)
        
        print(f"Found {len(model_35)} summary records for centerbias_35")
        print(f"Found {len(model_57)} summary records for centerbias_57")
        
        # Create comparison charts
        print("Creating comparison charts...")
        create_comparison_charts(model_35, model_57, 'model_comparison_charts.png')
        
        # Create summary statistics chart
        print("Creating summary statistics chart...")
        create_summary_statistics_chart(model_35, model_57, 'nss_summary_chart.png')
        
        # Print summary statistics
        print("\nSummary Statistics:")
        print("=" * 50)
        
        for metric in ['nss', 'ig_35', 'ig_57']:
            mean_35 = next((float(row[metric]) for row in model_35 if row['image_number'] == 'mean'), 0.0)
            mean_57 = next((float(row[metric]) for row in model_57 if row['image_number'] == 'mean'), 0.0)
            print(f"\n{metric.upper()} Metric:")
            print(f"centerbias_35 mean: {mean_35:.4f}")
            print(f"centerbias_57 mean: {mean_57:.4f}")
            print(f"Difference (35-57): {mean_35 - mean_57:.4f}")
        
    except FileNotFoundError:
        print(f"Error: Could not find the CSV file '{csv_path}'")
        print("Please make sure the file is in the current directory.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

def check_real_saliency_maps(sigma: int = 57) -> bool:
    for directory in directories:
        for image_number in range(1, 101):
            fixation_smoothed_map = regularize(gaussian_filter(load_fixation_map(directory, image_number), sigma=sigma))
            real_map = normalize_to_range(load_real_saliency_map(directory, image_number), fixation_smoothed_map.min(), fixation_smoothed_map.max())
            difference = real_map - fixation_smoothed_map
            _, axes = plt.subplots(1, 3, figsize=(10, 5))
            axes[0].imshow(real_map, cmap='viridis')
            axes[0].set_title('Real Saliency Map')
            axes[1].imshow(fixation_smoothed_map, cmap='viridis')
            axes[1].set_title('Fixation Smoothed Map')
            axes[2].imshow(difference, cmap='viridis', vmin=0.0, vmax=fixation_smoothed_map.max() - fixation_smoothed_map.min())
            axes[2].set_title('Difference')
            plt.show()
