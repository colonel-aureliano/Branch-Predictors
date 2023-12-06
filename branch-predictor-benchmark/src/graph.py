import matplotlib.pyplot as plt

# Function to calculate prediction accuracy for different PHT sizes
def get_accuracy():
    pht_sizes = [2 ** i for i in range(4, 15)]  # List to store PHT sizes (power of two between 16 and 16384)
    bimodal_accuracy = []  # List to store accuracy for Bimodal Predictor
    global_accuracy = []  # List to store accuracy for Global Predictor
    gshare_accuracy = []  # List to store accuracy for GShare Predictor
    
    # Read the contents of the file
    with open('run_result.txt', 'r') as file:
        accuracy_data = file.readlines()

    bimodal_accuracy = []
    global_accuracy = []
    gshare_accuracy = []

    for line in accuracy_data:
        parts = line.split()
        accuracy_value = float(parts[-1])  # Extract accuracy value as a float
        if parts[3] == 'BranchBimodal,':
            bimodal_accuracy.append(accuracy_value)
        elif parts[3] == 'BranchGlobal,':
            global_accuracy.append(accuracy_value)
        elif parts[3] == 'BranchGShare,':
            gshare_accuracy.append(accuracy_value)
 
    return pht_sizes, bimodal_accuracy, global_accuracy, gshare_accuracy

def plot_accuracy(pht_sizes, bimodal_accuracy, global_accuracy, gshare_accuracy):
    # Plotting
    plt.figure(figsize=(10, 6))
    
    # Plot the three lines for Bimodal, Global, and GShare Predictors
    plt.plot(pht_sizes, bimodal_accuracy, label='Bimodal Predictor', marker='o')
    plt.plot(pht_sizes, global_accuracy, label='Global Predictor', marker='o')
    plt.plot(pht_sizes, gshare_accuracy, label='GShare Predictor', marker='o')

    plt.title('Prediction Accuracy vs. PHT Size')
    plt.xlabel('PHT Size (Number of Entries)')
    plt.ylabel('Prediction Accuracy')
    plt.xscale('log', base=2)
    plt.grid(True)
    plt.legend()

    # Save the plot to a PNG file named "prediction_accuracy_plot.png"
    plt.savefig('prediction_accuracy_plot.png', dpi=300)

# Calculate accuracy for different PHT sizes
pht_sizes, bimodal_accuracy, global_accuracy, gshare_accuracy = get_accuracy()

# Plot the accuracy for the three predictors
plot_accuracy(pht_sizes, bimodal_accuracy, global_accuracy, gshare_accuracy)
