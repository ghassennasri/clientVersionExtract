const op = require('/MarkLogic/optic');
xdmp.log(sqlQuery)
// Assuming `op.fromSQL` executes a SQL query and returns an iterator of rows
const rowIterator = op.fromSQL(sqlQuery).result();

let csvContent = [];
for (let row of rowIterator) {
    if (csvContent.length === 0) {
        // Add header row
        csvContent.push(Object.keys(row).join(','));
    }
    // Add row values
    const rowValues = Object.values(row).map(value => 
        // Ensure that values containing commas are quoted
        `"${String(value).replace(/"/g, '""')}"`
    ).join(',');
    csvContent.push(rowValues);
}

// Join all rows with newline to create the CSV content
csvContent = csvContent.join('\n');

// Set the Content-Type to 'text/csv'
xdmp.addResponseHeader('Content-Type', 'text/csv');

// Suggest a filename for the download
xdmp.addResponseHeader('Content-Disposition', 'attachment; filename=report.csv');

// Return the CSV content
csvContent;