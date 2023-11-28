import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Load the CSV file
file_path = 'final_report.csv'  # Replace with your file path
data = pd.read_csv(file_path)

# Combine the software name and version into a single column
data['software_combination'] = data['clientInformation.clientInfoView.softwareName'] + " " + data['clientInformation.clientInfoView.softwareVersion']

# Aggregate the data to count the occurrences of each software combination
software_counts = data['software_combination'].value_counts()

# Generate a wide color palette
colors = list(mcolors.TABLEAU_COLORS) + list(mcolors.CSS4_COLORS.values())
if len(software_counts) > len(colors):
    colors = colors * (len(software_counts) // len(colors) + 1)

# Plot a pie chart without labels
plt.figure(figsize=(14, 12))
patches, texts, autotexts = plt.pie(software_counts, autopct=lambda pct: '{:.1f}%'.format(pct) if pct >= 2 else '', startangle=140, colors=colors[:len(software_counts)])
plt.axis('equal')

# Create custom labels for the legend
total = sum(software_counts)
legend_labels = [f'{name}: ({count/total:.1%})' for name, count in software_counts.items()]

# Display a legend with custom labels
plt.legend(legend_labels, title="Software Combinations", loc="center left", bbox_to_anchor=(1, 0, 0.5, 1))
plt.title('Distribution of Software Versions', y=1.05)
# Adjust layout
plt.subplots_adjust(bottom=0.2, top=0.85)  # Adjusted parameters
plt.tight_layout(pad=4.0)  # Added padding
plt.savefig('software_distribution.jpg', format='jpeg', dpi=300)
