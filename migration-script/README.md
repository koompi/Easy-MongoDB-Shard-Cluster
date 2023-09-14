# Migration Script

- Migration Script, as name suggests, is used for migrate the data from standalone DB to Cluster

- There are 2 script, one for import and one for export

## How to Run

1. Create a `.env` file from `sample.env` and fill out the need information; Example has been given
2. Run the Export Script (which will download the Databases file into a `DATABASE` directory)
3. Run the Import Script (which will upload the the Databases file from the `DATABASE` directory to the New Cluster)

