# Stratus
## Release notes

## 1.4.0.2

__Release Date:__ 2021-06-18

__Environment:__ Test

__Front-end:__

- `[Added]` Subject loss section - users can now group losses without having to define a 100% QS. This will reduce the size of the calculation being run in Graphene. 1 subject loss box called _All Losses_ will automatically be created in new structures. As inputs are added, these will automatically link into the _All Losses_ subject loss. These relationships are generated based on the name of the subject loss so manually created _All Losses_ subject loss will have inputs linked into it as new inputs are created.
- `[Fixed]` Disable Run Pricing Analysis button if network contains unsaved changes.

__Back-end:__

- `[Changed]` Graphene error handling - added `x-graphene-enable-grpc-errors=true` header to all Graphene requests. This is an upcoming breaking change and will throw an `RpcException` which is changed behaviour. Should be no change from user point of view.
- `[Updated]` AnalyzeRe Prime library update to include new `one_based_sequencing` input to YELT upload. This is a fix for the OEP issue with YELTs being uploaded in AIR 1-based day of year and AnalyzeRe AIR catalog being adjusted to be 0-based
- `[Fixed]` Missing Graphene to Prime exports - file with results had same name for all requests for a specific node so led to inconsistent concurrency issues when reading the data back. Where the results didn't match the input parameters, no data was exported  
- `[Fixed]` Deterministic exports from Graphene to Prime were being interpreted as stochastic. Corrected deterministic EventIDs using '1' as a prefix for RDS events and '2' for historical events.

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.4.0.1

__Release Date:__ 2021-06-18

__Environment:__ Test

__Front-end:__

- `[Fixed]` Graphene to Prime export base node ID calculation - if only ceded perspectives were selected, these were inadvertently being used for the perspective check, not the node checking for export
- `[Fixed]` Removed unecessary reference in functionRequestHelpers.js causing unknown variable exception when getting the redirect url with token
- `[Changed]` When accessing link to Stratus page and user isn't logged in, now it will continue to the link after redirecting to login rather than going to the backlog.
- `[Changed]` New pricing item ID generation method to ensure uniqueness. Previous method had ~0.5% chance of following ID being a duplicate of the previous one. For a new layer being created (at least 6 items - 3 layers & 3 relationships) there was a ~20% chance of not all IDs being unique. Now unique values are cached and refreshed when required.

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.4.0.0

__Release Date:__ 2021-02-26

__Environment:__ Production

High level changes only covered in this release note. For more detailed information, see the respective test release notes. 

__Major changes:__

- `[Added]` Status page - shows number of messages pending in Stratus queues `[1.3.1.3]`
- `[Updated]` ELT conversion process to reduce maximum memory requirement `[1.3.1.6]`
- `[Updated]` Graphene function app concurrency increased from 1 to 5 `[1.3.1.7]`
- `[Updated]` Backlog page updates `[1.3.1.1]`
- `[Updated]` Loss set mapping within loss view selection `[1.3.1.2]`

__Minor changes & bug fixes:__
- `[Added]` User defined maximum results to load at one time input `[1.3.1.2]`
- `[Added]` Year of account selection can be done from any program page `[1.3.1.2]`
- `[Added]` Exclude loss switch in relationship filter `[1.3.1.4]`
- `[Added]` Program reference validation `[1.3.1.5]`
- `[Added]` Ability to change structure name and YOA `[1.3.1.5]`
- `[Updated]` Limit attachment ordering switched `[1.3.1.2]`
- `[Updated]` Loss set table columns now sortable `[1.3.1.8]`
- `[Fixed]` Issue selecting loss views after deleting one `[1.3.1.1]`
- `[Fixed]` Empty CEDE results error `[1.3.1.1]`

__New Infrastructure:__

Queues:
- `gr-map-elt`

Tables:
None

Logic apps:
None

__Deployment pipeline:__
Matching changes made in test and production pipelines
- `[Added]` Graphene function app settings passed into configuration powershell script:
  - `ConverEltParallelism`
  - `ServiceBusConcurrency`

---
## 1.3.1.8

__Release Date:__ 2021-02-19

__Environment:__ Test

__Front-end:__
- `[Changed]` Backlog stops polling for new task updates if users move away from browser tab. This prevents unexpected behaviour and new tasks being missed in requests.
- `[Changed]` Loss set table columns are now sortable (with default latest uploaded at the top)

__Back-end:__ 
- `[Updated]` Map ELT queue friendly name in Queue Status request

__Infrastructure:__ 
None

__Deployment Pipeline:__ 
None

## 1.3.1.7

__Release Date:__ 2021-02-17

__Environment:__ Test

__Front-end:__

None

__Back-end:__ 
- `[Added]` Additional inputs for graphene function app environment variables to allow them to be set during the release pipeline
  - `$convertEltParallelism`
  - `$serviceBusConcurrency`

__Infrastructure:__ 
None

__Deployment Pipeline:__ 
- `[Added]` Variable `ConverEltParallelism` to deployment pipeline variable groups:
  - `Stratus API Test`: 8
  - `Stratus API Prod`: 8
- - `[Added]` Variable `ServiceBusConcurrency` to deployment pipeline variable groups:
  - `Stratus API Test`: 5 (will reduce after testing to 1)
  - `Stratus API Prod`: 5
- `[Changed]` Pass new variables into function app powershell script

## 1.3.1.6

__Release Date:__ 2021-02-16

__Environment:__ Test

__Front-end:__

None

__Back-end:__ 
- `[Added]` New Map ELT endpoint in function app. This maps the relevant ELT to AIR geography and model mappings prior to ELT conversion.
- `[Changed]` ELT conversion now processes 8 simulation set files simultaneously now the memory requirement is lower during conversion as mapping is pre-done.

__Infrastructure:__ 
- `[Added]` New queue: `gr-map-elt`
- `[Added]` New graphene function app setting: `CONVERT_ELT_PARALLELISM` - default: 8

__Deployment Pipeline:__ None

---

## 1.3.1.5

__Release Date:__ 2021-02-10

__Environment:__ Test

__Front-end:__

- `[Added]` Validation on program name to exact length of 6 characters
- `[Added]` Ability to change name and YOA of graphene structures

__Back-end:__ None

__Infrastructure:__ None

__Deployment Pipeline:__ None

---
## 1.3.1.4

__Release Date:__ 2021-02-09 

__Environment:__ Test

__Front-end:__

- `[Added]` Relationship tab now contains include / exclude toggle option.

__Back-end:__

- `[Added]` Filtering functionality with the option to include or exclude applied filtered logic.

__Infrastructure:__ None

__Deployment Pipeline:__ None


---
## 1.3.1.3

__Release Date:__ 2021-02-04 

__Environment:__ Test

__Front-end:__

- `[Added]` Queue status page. This displays the number of messages currently waiting in each queue within Stratus and calculates the rate of change of messages being added/processed.

__Back-end:__

- `[Added]` QueueStatus endpoint within task function app

__Infrastructure:__ None

__Deployment Pipeline:__ None


---
## 1.3.1.2

__Release Date:__ 2021-01-28 

__Environment:__ Test

__Front-end:__

- `[Changed]` Network results loading - now only loads 5 results and has user set maximum for metter memory management. This should reduce/remove 'Aw Snap' errors
- `[Changed]` Limit and attachment inputs swapped round on layer financials page
- `[Changed]` Loss set mapping functionality now done through pop up. Uses same search filtering functionality as pricing exports.
- `[Added]` YOA can now be selected on any program page 

__Back-end:__

- `[Fixed]` YELT download endpoint stopped working due to change in url folder structure. Change means now we are agnostic to this folder structure. 

__Infrastructure:__ None

__Deployment Pipeline:__ None

---
## 1.3.1.1

__Release Date:__ 2021-01-14 

__Environment:__ Test

__Front-end:__

- `[Fixed]` Null loss view check when activating loss view. This was affecting structures where loss views had been deleted.
- `[Added]` Inclusive date inputs for viewing tasks (defaults to today and yesterday)
- `[Added]` Got to page input for tasks
- `[Changed]` More efficient loading of tasks, once initial load is done, only in progress or pending tasks are updated along with the retrieval of new tasks
- `[Changed]` Filtering of tasks only done on enter or filter button click
- `[Fixed]` Existing network results properly disposed of on network switch

__Back-end:__

- `[Fixed]` Null check for CEDE results for each exposure set when no detailed loss analysis results for peril/location combination. 
  - There will be no results row for these exposure sets i.e. if there are only SCS and WT perils mapped to an exposure set as we don't run these perils, there will be no loss results. Therefore, this exposure set would not exist on the results tab. This is opposed to there being a row with losses displayed as 0.

__Infrastructure:__
None

__Deployment Pipeline:__
None

---
## 1.3.1.0

__Release Date:__ 2020-11-13

__Environment:__ Production

Better handling of large files in Stratus and Graphene with other minor bug fixes

__Front-end:__ 

- `[Changed]` YELT downloads now submit request to back end rather than redirect to download immediately. __N.B.__ Check tasks for YELT download links
- `[Changed]` Better backlog filtering when large volume of tasks, now runs filter on change or enter keypress events rather than key up. This should allow users to type in filter unimpeded.
- `[Changed]` Changes made to enhance process memory when transfering YELT's via streams for both AnalyzeRe Prime / Graphene.
- `[Fixed]` Import RDM - Retry RDM save without treaties on failure. 

__Back-end:__

- `[Changed]` Standard pricing analyses now do not calculate YELT exports by default

__Infrastructure:__

- `[Added]` New Graphene download logic app

__Deployment Pipeline:__

Stratus API test variables:
- `[Added]` `PrimeStreamUploadMinMaxSizeBytes`: 4194304

---
## 1.3.0.2

__Release Date:__ 2020-11-10

__Environment:__ Test

__Front-end:__ 

- `[Changed]` YELT downloads now submit request to back end rather than redirect to download immediately. __N.B.__ Check tasks for YELT download links
- `[Changed]` Better backlog filtering when large volume of tasks, now runs filter on change or enter keypress events rather than key up. This should allow users to type in filter unimpeded.

__Back-end:__

- `[Changed]` Standard pricing analyses now do not calculate YELT exports by default
- `[Added]` Severe convective storm geospatial run

__Infrastructure:__

- `[Added]` New Graphene download logic app

__Deployment Pipeline:__

None

---
## 1.3.0.1

__Release Date:__ 2020-11-03

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Changed]` Changes made to enhance process memory when transfering YELT's via streams for both AnalyzeRe Prime / Graphene.
- `[Fixed]` Import RDM - Retry RDM save without treaties on failure.    

__Infrastructure:__

None

__Deployment Pipeline:__

Stratus API test variables:
- `[Added]` `PrimeStreamUploadMinMaxSizeBytes`: 4194304

---
## 1.3.0.0

__Release Date:__ 2020-10-13

__Environment:__ Production

High level changes only covered in this release note. For more detailed information, see the respective test release notes. 

__Major changes:__

- `[Changed]` Program management restructuring. Files are now loaded separately into a year of account in a program to allow for easier process management `[1.2.0.2]` `[1.2.1.8]` 
- `[Changed]` Touchstone v8 integration `[1.2.1.31]`
- `[Removed]` Loading a new analysis from a folder `[1.2.1.30]`
- `[Added]` Pricing layer perspectives `[1.2.0.4]`
- `[Added]` Multi year pricing templates `[1.2.1.28]`
- `[Added]` File tracking `[1.2.1.13]` `[1.2.1.14]`

Major pricing updates backwards compatible with existing networks upgraded on load - __requires user to save network when prompted__

__Minor changes & bug fixes:__
- `[Added]` View multiple layers side-by-side in pricing results `[1.2.0.1]`
- `[Changed]` YELT download and Prime export selections made more user friendly `[1.2.0.5]`
- `[Changed]` Viewing and interacting with CEDE databases is not dependent on hazard analyses completing `[1.2.1.8]`
- `[Fixed]` ELT parameterisation error. Default to Bernoulli distribution when received invalid parameters for the Beta distribution `[1.2.1.9]`
- `[Changed]` Prime YELT exports include 2 year's of data (duplicated) to allow for multi-year modelling `[1.2.1.10]`
- `[Fixed]` 'not' functionality in Stratus pricing relationships not previously implemented `[1.2.1.10]`
- `[Fixed]` Handling of broker lines of business in CEDE files that included special characters `[1.2.1.15]`
- `[Changed]` Loss uploads no longer lock files `[1.2.1.16]`
- `[Changed]` Hazard analyses slimmed down to only include required information `[1.2.1.19]` `[1.2.1.32]`
- `[Added]` Save mappings button to CEDE. Saves peril and RPX mapping selections without submitting changes `[1.2.1.21]`
- `[Changed]` Geospatial runs submit immediately rather than queuing until 7pm `[1.2.1.23]`
- `[Changed]` Mapping of loss sets to inputs within loss views no longer mandatory for Graphene `[1.2.1.26]`
- `[Added]` Copy layer functionality - includes inward relationships as well as financial definition but not outward relationships `[1.2.1.29]`
- `[Changed]` Removed Inland Flood peril from Touchstone loss analysis runs `[1.2.1.36]`

__New Infrastructure:__

Queues:
None

Tables:
- `stratusProgram`
- `stratusFiles`

Logic apps:
- `stratus-file-ks-func-logicapp-prod`
- `stratus-bulk-file-ks-func-logicapp-prod`
- `stratus-getfilesfromfolder-logicapp-prod`

---
## 1.2.1.36

__Release Date:__ 2020-10-09

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Changed]` Removed Inland Flood from perils run in Touchstone loss analyses

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.35

__Release Date:__ 2020-10-06

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Changed]` Added additional attempt to save base CEDE requirements if saving all exposure summary data fails
- `[Changed]` Removed use of revisions when saving elements in Graphene

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.34

__Release Date:__ 2020-10-01

__Environment:__ Test

__Front-end:__ 

- `[Changed]` When reloading MDF files, check for created BAK files. Use BAK files if they exist.
- `[Changed]` Redirect to task page after file reload submission
- `[Added]` Clearer indication that task pages are live view of tasks

__Back-end:__

- `[Changed]` Test environment zone sids added after environment rebuild - includes FF

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.33

__Release Date:__ 2020-09-30

__Environment:__ Test

__Front-end:__ 

- `[Changed]` Get files modal now redirects to tasks page on submisson to show user of files in progress
- `[Fixed]` Non-lowercase extensions now handled by front end
- `[Fixed]` Bak files created by Stratus were previously available to submit - now checks if equivalent mdf is loaded

__Back-end:__

- `[Changed]` When saving a network, latest version is always retrieved. Same is true for running loss analyses

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.32

__Release Date:__ 2020-09-29

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Changed]` Hazard analysis run profile options. Analysis now only runs the following options. IncludeCaliforniaDOIZone / IncludeDistanceToEffectiveCoast / IncludeFemaFloodZone / IncludeReplacementValue(A+B+C+D)
- `[Changed]` Hazard summary query updated to not query columns not run within updated Hazard analysis options

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.31

__Release Date:__ 2020-09-25

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Changed]` Connected to new Touchstone v8 environment

__Infrastructure:__

None

__Deployment Pipeline:__

Stratus API test variables:
- `[Changed]` `DatabaseBackupPath`: E:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup
- `[Changed]` `TouchstoneDatabaseFilePath`: E:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA
- `[Changed]` `TouchstoneDatabaseLogPath`: L:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA
- `[Changed]` `TouchstoneDatabaseVersion`: 8.0.0
- `[Changed]` `TouchstoneDataSourceFilePathUNC`: \\tch-db-t-01\DATA
- `[Changed]` `TouchstoneEndPoint`: https://tch-app-t-01.wren.co.uk/FEP/AirServiceFacade.svc
- `[Changed]` `TouchstoneLogFilePathUNC`: \\tch-db-t-01\Log_Data
- `[Changed]` `TouchstoneSqlServerName`: tch-db-t-01
- `[Removed]` `TouchstoneDefaultModelVersion`

---
## 1.2.1.30

__Release Date:__ 2020-09-24

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Ability to upload existing analyses data to Graphene
- `[Fixed]` Ability to see related existing analyses now we have moved to program references that do not include the year
- `[Fixed]` Bug that meant users could kick off pricing analysis if one was already in progress.
  - `IsRunning` flag was reset on network save
- `[Removed]` New analysis buttons
- `[Removed]` Analysis page link in header bar

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.29

__Release Date:__ 2020-09-23

__Environment:__ Test

__Front-end:__ 

- `[Added]` Copy layer functionality
  - __N.B.__ This includes copying any relationships that source losses into the layer but __NOT__ any relationships after the copied layer i.e. if losses from the copied layer flow into another layer, this relationship will not be copied.
- `[Added]` Delete input/layer check. Users will be required to confirm they want to delete an input/layer.

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.28

__Release Date:__ 2020-09-22

__Environment:__ Test

__Front-end:__ 

- `[Added]` Additional network upgrade step to convert layers automatically from existing templates to new MultiYear template
- `[Fixed]` Network properties null issue in run analysis button
- `[Fixed]` Node result currency conversion issue created in previous metric fix

__Back-end:__

- `[Changed]` Included new `layer_schema` property for layer data for move to MultiYear template
- `[Added]` New `custom` template search path to include MultiYear template

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.27

__Release Date:__ 2020-09-18

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` Pricing property to set the occurrence key to the event ID. Prior to this all losses were aggregated up to Sequence/Time before layer terms were applied.
- `[Fixed]` Set file status to 'live' when found - previously if the process failed at any time the status was set to 'missing' but not reset to 'live' when process working again.
- `[Changed]` Graphene expiry dates adjusted to be exclusive - where Stratus expiry dates are inclusive

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.26

__Release Date:__ 2020-09-17

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Results currency selection fix

__Back-end:__

- `[Changed]` Backend change to handle un-mapped loss view scenario for blank layer results

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.25

__Release Date:__ 2020-09-16

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Stochastic metrics were not displaying correctly across loss views for the same layer

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.24

__Release Date:__ 2020-09-16

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Deterministic outputs now display with perspective in name 
- `[Changed]` YELT download is same for deterministic page and stochastic page

__Back-end:__

- `[Changed]` Loss sets now have YOA included in metadata
- `[Fixed]` Getting event IDs for network now only retrieve from standard analysis requests

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.23

__Release Date:__ 2020-09-14

__Environment:__ Test

__Front-end:__ 

- `[Changed]` Users no longer prompted for the geospatial timing check 

__Back-end:__

- `[Changed]` Geospatial runs no longer queued for 8pm, they will run immediately
- `[Changed]` Activity checking for geospatial runs occurs every 5 minutes

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.22

__Release Date:__ 2020-09-08

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` YOA selection in program fixed. Users can now view files (and source runs) by YOA. This still does not affect any pricing data selection.
- `[Fixed]` Pricing structures not priced in USD had a bug that meant the currency got stuck on USD (therefore with no results displaying) if all node selections were removed. 

__Back-end:__

- `[Changed]` Graphene contract date conversion updated.
  - Previously we were taking day of year for both inception and expiry date, now expiry date is adjusted dependent on inception date i.e. if contract was 01/07/2020 - 30/06/2020, Graphene inception date would have been 183 & expiry date would have been 182 (meaning no losses taken). Now expiry date would be 182 + 365 = 547.
  - This change will help with Graphene multi year contracts

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.21

__Release Date:__ 2020-09-07

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Clear loss view information on inputs on loss view deletion. Some information was being cached which led to knock on issues.
- `[Fixed]` Azure table continuation token fix, now loads all tasks in the last 2 weeks
- `[Changed]` When reloading a CEDE that was received as an MDF file, front end now sends request to reload created BAK file.
  - __N.B.__ If error occured before creating backup of client MDF i.e. attaching it, users may need to manually detach the file to be able to use the file
- `[Added]` Added save peril mappings button to CEDE source tab. Users can now save mapping progress as they go.

__Back-end:__

- `[Fixed]` Backup database task updates correctly now. Previously only updated on completion, not on start.

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.20

__Release Date:__ 2020-08-28

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Copy network not saving correctly
- `[Fixed]` UI not recognising changes when loss set mapping changed
- `[Changed]` Update LossSet schema version to 1.1 (to include blank mapping functionality). Updates applied to existing structures when loaded.
  - __NB.__ Users will need to open and re-save existing networks for changes to come into effect

__Back-end:__

- `[Changed]` Nodes and links previously deleted only had 'Deleted' flag set to true rather than being excluded. These resources are now not loaded when getting networks.
- `[Fixed]` Hazard summary query updated to not query columns of perils no longer run

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.19

__Release Date:__ 2020-08-27

__Environment:__ Test

__Front-end:__ 

- `[Added]` Client MDFs now display attached DB name (as this differs from client name) 

__Back-end:__

- `[Changed]` EVI file size will now include size of all related files (clf/dlf/ulf/evt) on the front end 

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.18

__Release Date:__ 2020-08-26

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Issue loading standalone MDF files through file load modal

__Back-end:__

- `[Removed]` Flood, ST & Terror profiles from hazard analysis runs
- `[Removed]` Treaty geospatial runs 

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.17

__Release Date:__ 2020-08-25

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` Prevent unnecessary files from being loaded when unzipping zip file
- `[Fixed]` Include 202 Accepted response in file logic apps to prevent erroneous errors
- `[Added]` File sizes are updated every 5 mins to give users up to date data

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.16

__Release Date:__ 2020-08-24

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Prime upload request parameters reverted to correct ones
- `[Fixed]` Search backlog tasks now doesn't cause error
- `[Changed]` Upload groupings will not lock from now on. Groupings you see will always be the last groupings that were uploaded.

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.15

__Release Date:__ 2020-08-21

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` CEDE line of business upload when certain special characters are in broker lines of business
- `[Added]` Display related files in file info
- `[Added]` Link to program files page from data management table

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.14

__Release Date:__ 2020-08-20

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` AnalyzeRe Prime import column headers fixed
- `[Added]` All DB files should be tracked when importing files through a program (MDF/LDF/BAK)

__Infrastructure:__

None

__Deployment Pipeline:__

- `[Added]` New log file folder UNC path deployment variable: `TouchstoneLogFilePathUNC`
  - Test deployment value: `\\SQLTCHDBS01T\LOG\`

---
## 1.2.1.13

__Release Date:__ 2020-08-18

__Environment:__ Test

__Front-end:__ 

- `[Added]` Data page to view all loaded files including file size 
  - Currently this is only size at import i.e. CEDE exposure databases that map additional perils will not be reflected in the size
  - Size is limited to the file that Stratus imports i.e. for CLFs it currently only shows the size of the .evi file which is not reflective of the overall import
- `[Fixed]` Loss set viewing issues created through move to program and gross pricing layer functionality

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.12

__Release Date:__ 2020-08-18

__Environment:__ Test

__Front-end:__ 

None  

__Back-end:__

- `[Fixed]` YELT Sql query for upload to Prime error fixed for UNION ALL issue.

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.11

__Release Date:__ 2020-08-17

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Error loading files from folder when no files had previously been run
- `[Added]` Users can now re-run CEDE analyses

__Back-end:__

None

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.10

__Release Date:__ 2020-08-14

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` CEDE Exposure file selection and LoB mappings within program fixed
- `[Fixed]` CEDE results file selection within program fixed

__Back-end:__

- `[Changed]` Moved Prime uploads back to YELT uploads. This includes duplicating losses over two years and including the 1st January of the current year as the inception date.
- `[Fixed]` Pricing relationship 'not' bug - previous not implemented properly

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.9

__Release Date:__ 2020-08-11

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` YELT generation from ELT with invalid Beta distribution parameters. When $\sigma^2  \gt \mu (1 - \mu)$ where:  
&nbsp;&nbsp;&nbsp;&nbsp;$\sigma$ = (StdDevCorr - StdDevInd) / Exposure ; and  
&nbsp;&nbsp;&nbsp;&nbsp;$\mu$ = PerspectiveMean / Exposure  
Loss distribution defaults to Bernoulli i.e. when $Beta\_P \leqslant 1 - \mu$ then return $0$ loss, else return $Exposure$ as loss
- `[Changed]` Hazard analyses will now run after all exposure summaries have been retrieved
- `[Changed]` When getting files from folder, it will only try once (rather than default of 4 times), if folder not found, no files will be shown.

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.1.8

__Release Date:__ 2020-07-31

__Environment:__ Test

__Front-end:__ 

- `[Added]` Ability to load files separately in a program
- `[Added]` Ability to reload files if an error occurs at any point of loading or analysis
- `[Added]` Ability to group files by YOA - select available YOA on details page of a program
- `[Added]` Current list of programs available in MyMI - all existing analyses that match the first 6 characters will get grouped into these programs and will be available on the 'Files' tab. __N.B.__ only files loaded into a program will be available on the 'Source' tab of the program.

__Back-end:__

- `[Changed]` Getting exposure summary and hazard summary when loading an CEDE file should run in parallel now i.e. viewing exposure data for a CEDE should be available before the hazard analyses have completed. __N.B.__ Hazard analyses will run when loading in a file separately
 
__Infrastructure:__

- `[Added]` Load zip file logic app
- `[Added]` Get files from folder logic app
- `[Added]` Load file logic app

__Deployment Pipeline:__

None

---
## 1.2.0.7

__Release Date:__ 2020-07-17

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Loss set details componenent error. Broken during program updates
- `[Changed]` Increased perspective QS limit to maximum integer value (2<sup>53</sup> - 1)

__Back-end:__

- `[Added]` Additional Prime metadata item to indicate if changes to layer terms would affect losses to other layers if re-run. Item key: `followingLossDependency`
  - This metadata item will only be true if another layer has a relationship with either the ceded or net perspectives of a layer
- `[Added]` Additional options for getting file information to API - will be used for front end file selection
- `[Added]` API endpoint to expose Unzip file functionality
- `[Added]` Logic app to expose get files from folder API endpoint
- `[Added]` New file specific kickstarter logic app. Front end will call this specifically for each file selected.
 
__Infrastructure:__

- `[Added]` File kickstarter logic app
- `[Added]` Bulk file kickstarter logic app

__Deployment Pipeline:__

None

---
## 1.2.0.6

__Release Date:__ 2020-07-09

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Uploading of CLFs fixed after program updates. Missing information in request was causing a silent failure.

__Back-end:__

- `[Fixed]` ELT conversion rounding error leading to invalid Beta distribution parameters. ELT parameters now rounded to 4dp before Beta parameters are calculated. 

 
__Infrastructure:__

None

__Deployment Pipeline:__

- `[Changed]` Removed folder copy tasks for Azure Function deployment - .NET Core 3.1 builds to correct folder.

---
## 1.2.0.5

__Release Date:__ 2020-07-07

__Environment:__ Test

__Front-end:__ 

- `[Changed]` YELT download changed. Pop-up box gives all available options across layer/perspective/loss view/currency. Downloads one at a time. All loss views types available from either stochastic or deterministic results views.
- `[Changed]` Export to Prime changed. Similar to YELT download, users now select all exact exports they want for all options across layer/perspective/loss view/currency. Dependent on loss views selected, user will have to map these loss views to Prime event catalogs - __limited to a one-to-one mapping__. For RMS loss views, this should match the RMS event catalogs that the sim sets are generated from.

__Back-end:__

- `[Added]` Functionality in the Prime metadata generation to pull layer information from another node (i.e. ceded node layer information for both gross and net perspectives)
- `[Changed]` Export to Prime logic app which now only exports one layer/perspective/loss view/currency per request as selected by the user on the front end.
- `[Updated]` Moved to .NET Core 3.1 version as previous version (2.2) was removed from LTS by Microsoft
 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.0.4

__Release Date:__ 2020-06-29

__Environment:__ Test

__Front-end:__ 

- `[Added]` Layer perspectives - When a layer is added to a network this creates gross and net perspectives. Users can now select which perspective to link in relationships as well as in results view, where layers are now grouped by perspective.
- `[Added]` Applying perspectives to existing structures. When an existing structure is loaded in Stratus, perspectives will be applied if they do not already exist. Users will need to save the network and re-run the pricing analysis to view results by perspective.

__Back-end:__

- `[Added]` Additional layer properties related to perspectives
 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.0.3

__Release Date:__ 2020-06-24

__Environment:__ Test

__Front-end:__ 

- `[Added]` Ability to run new analyses, this was removed in the previous version but has been restored for better long term support. 

__Back-end:__

None
 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.0.2

__Release Date:__ 2020-06-23

__Environment:__ Test

__Front-end:__ 

- `[Added]` Users can now view analyses grouped by program reference. Please the read important points below: 
  1. Users will need to create new programs first, once this is done, the grouping will occur automatically.
  2. All existing analyses are available to view in the new files tab
  3. __No file work (i.e. loading broker files) can be done in the program view yet__ 
  4. All pricing work can be done in the program view now - any networks created in the program view will not be available in any underlying analyses views
  5. Styling of navigation buttons has been changed in this update

- `[Added]` Programs and analyses can now be searched across all parameters with new search box
- `[Added]` URL updates in program view. This includes urls to specific tabs but also loading of network (if available)
- `[Changed]` Task links will direct page to relevant account type view (program or analysis) depending on the tasks owner i.e. if a pricing analysis was set off in a program view, the task link will re-route to the task view and vice versa for tasks set off in the analysis view
- `[Removed]` Ability to create new analyses temporarily removed in favour of creating programs. Depending on progress of project, this functionality will be restored

__Back-end:__

None
 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.0.1

__Release Date:__ 2020-06-17

__Environment:__ Test

__Front-end:__ 

- `[Added]` Ability to show pricing results of multiple nodes side by side

__Back-end:__

None
 
__Infrastructure:__

- `[Added]` New stratusProgram Azure storage table

__Deployment Pipeline:__

None

---
## 1.2.1.0

__Release Date:__ 2020-07-31

__Environment:__ Production

__Front-end:__ 

- `[Fixed]` Silent error when displaying aggregate XL layer results

__Back-end:__

None
 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.2.0.0

__Release Date:__ 2020-06-16

__Environment:__ Production

__Front-end:__ 

- `[Fixed]` Task history reporting for tasks without creator defined
- `[Fixed]` Prime event catalog retrieval error reporting

__Back-end:__

- `[Fixed]` Timeout for clearing losses from application database removed
- `[Fixed]` Ceded percentage for TouchstoneRe losses fixed from 1% to 100%
 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.1.0.0

__Release Date:__ 2020-06-05

__Environment:__ Production

High level changes only covered in this release note. For more detailed information, see the respective test release notes. 

- `[Fixed]` Database pause issue - retry attempts were all finishing before the database woke `[1.0.1.10]`
- `[Fixed]` Service bus messages were reaching their delivery count under certain circumstances `[]`
- `[Added]` ELT to YELT conversion for AnalyzeRe Graphene upload `[1.0.1.1]`
- `[Added]` Ability to export losses from AnalyzeRe Graphene to Prime `[1.0.1.1]`
- `[Added]` Authentication added to all function app endpoints `[1.0.1.2]`
- `[Added]` User selection of Prime event catalogs when uploading losses to AnalyzeRe Prime `[1.0.1.2]`
- `[Added]` Page to allow users to update exchange rates in AnalyzeRe Graphene `[1.0.1.2]`
- `[Changed]` Move to using TouchstoneRe over Catradar `[1.0.1.1]`
- `[Changed]` Touchstone(Re) losses output by line of business including user mappings on front end `[1.0.1.2]`
- `[Changed]` Run AnalyzeRe Graphene loss analyses for all currencies used in a network `[1.0.1.2]`
- `[Changed]` Delete losses from application database once upload process completes or fails `[1.0.1.3]`
- `[Changed]` Removed CLF dependency on reading in EVI file, allowing combined CLFs to be loaded into Stratus `[1.0.1.9]`
- `[Changed]` Connected to new Touchstone Treaty server TCHDBS01P & TCHAPP01P `[1.0.1.18]`

__New Infrastructure:__

Queues:
- `ts-elt-upload-sims`
- `gr-convert-elt`
- `gr-clear-appdb-losses`

Tables:
- `stratusSimulationSets`
- `stratusLobMappings`

Logic apps:
- `stratus-convertelt-elt-logicapp-prod`
- `stratus-geteventsets-elt-logicapp-prod`
- `stratus-uploadsimset-elt-logicapp-prod`
- `stratus-export-graphene-to-prime-logicapp-prod`

---
## 1.0.1.18

__Release Date:__ 2020-05-22

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

None

 
__Infrastructure:__

None

__Deployment Pipeline:__

- `[Changed]` Repointed Stratus back end to new Touchstone(Re) servers. Variables changed in 'Stratus API Test' variable group: `[TouchstoneDataSourceFilePathUNC, TouchstoneEndPoint, TouchstoneSqlServerName]`
  - App server: TCHAPP01P
  - DB server:  TCHDBS01P

---
## 1.0.1.17

__Release Date:__ 2020-05-20

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` CLF csv download had incorrect values for the selected Perspective/UDF1/UDF2
- `[Fixed]` Error when trying to download CEDE csv
- `[Fixed]` Drop down labels getting in the way of currency options in results dropdown
- `[Fixed]` Authentication token was not being refreshed correctly. Authentication scopes had been changed to Graph when we needed it to be the Client ID to ensure valid authentication.

__Back-end:__

- `[Changed]` Limit for loops in logic apps was defaulting to 60. Extended this to 500 to ensure 100k sim sets were being handled correctly
- `[Removed]` Splitting convert ELT functionality into multiple messages. This was found to slow the process down (the opposite of the desired effect). Process tested with production server specifications and found to be suitable.

 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.16

__Release Date:__ 2020-05-18

__Environment:__ Test

__Front-end:__ 

- `[Removed]` Removed simulation set generation functionality from front end. This will be included in a future release. 

__Back-end:__

- `[Changed]` Changed the handling of converting ELTs for Graphene. Process will be split into smaller, more manageable chunks.

 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.15

__Release Date:__ 2020-05-15

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` Pricing metrics that are non-currency denominational (i.e. ELoL, Exhaustion probability) have been fixed after the Graphene currency updates
- `[Changed]` Added authentication token to query parameter when downloading YELT

__Back-end:__

- `[Fixed]` Clicking the "Upload to Prime" button on CLF and CEDE analyses was attempting to upload to Graphene
- `[Changed]` Added ability to authenticate requests via a token in the query url
- `[Changed]` Changed the interaction with service bus queues to complete messages as soon as they are received. Previously, we were getting unexpected behaviour when running long-running tasks in the function apps where the message lock tokens were not being renewed within the settings time limit.

 
__Infrastructure:__

None

__Deployment Pipeline:__


---
## 1.0.1.14

__Release Date:__ 2020-05-14

__Environment:__ Test

__Front-end:__ 

None 

__Back-end:__

- `[Changed]` Graphene outputs will now be calculated in currencies across all nodes in a network. Previously this was only true for layers.
- `[Fixed]` Missing currency information on loss set network input node added.

 
__Infrastructure:__

None

__Deployment Pipeline:__

None


---
## 1.0.1.13

__Release Date:__ 2020-05-12

__Environment:__ Test

__Front-end:__ 

- `[Changed]` Model AALs under CLF analyses are now ordered by model 

__Back-end:__

- `[Changed]` Added manual definition of `AppliesToArea` for each layer when creating programs in TouchstoneRe. This is after discussion with AIR and follows the same settings for the default Worldwide settings generated by the UI.
  - See tables `[AIRUserSetting].[dbo].[tDefaultAppliesToArea]` and `[AIRUserSetting].[dbo].[tDefaultAppliesToAreaGeoXref]` where `AppliesToAreaSID = 3` for included `GeographySIDs` 
- `[Changed]` Manual currency manipulation for losses generated by TouchstoneRe as all outputs will be in USD. this is following discussions with AIR.
- `[Fixed]` Potential fix for threading issues when generating simulation set
- `[Fixed]` Change settings on Graphene function app to extend function timeout & renew service bus message locks before they expire

 
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.12

__Release Date:__ 2020-05-11

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` CEDE line of business mappings were not showing after mapping perils. Front end process updated to ensure this is handled correctly.
- `[Fixed]` CEDE run summaries will now display correctly after issue parsing results by line of business where no AAL information available for a line of business in an exposure set.

__Back-end:__

- `[Fixed]` Keying of CEDE run summaries in Azure tables meant that results weren't storing all run lines of business. Keys have been updated.
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.11

__Release Date:__ 2020-05-07

__Environment:__ Test

__Front-end:__ 

- `[Fixed]` CLF analysis displaying loss analysis data by line of business.

__Back-end:__

- `[Fixed]` Getting loss analysis details and YELTs by line of business. Fixes implemented for both Touchstone & TouchstoneRe
  
__Infrastructure:__

None

__Deployment Pipeline:__

None


---
## 1.0.1.10

__Release Date:__ 2020-05-06

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` Ambiguous `LOBCode` error. The updated stored procedure getting details and losses for clfs by line of business didn't specify which table property to filter on as `LOBCode` existed in two tables in join.
- `[Fixed]` Lines of business extracted in `ExposureSummary` were not being saved to the azure table and as such were not visible on the front end.
- `[Changed]` Updated retry policies for logic app tasks that connect to the application DB. Documentation says that serverless SQL databases need up to a minute to unpause. Default retry policy was completing all attempts within ~40 seconds.
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.9

__Release Date:__ 2020-05-05

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Added]` Removed dependency on reading EVI file for running CLFs. Now when the EVI is unreadable (i.e. currently combined CLF EVI files cannot be read), defaults are used.
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.8

__Release Date:__ 2020-05-05

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` Corrected usage of line of business filter string generator when getting Touchstone(Re) run details and loss extraction.
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.7

__Release Date:__ 2020-05-05

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` EVI file path was not being passed into the new TouchstoneRe `CreateProgram` endpoint. This has been fixed.
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.6

__Release Date:__ 2020-05-05

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` Dependency injection fix. Moved `ITaskService` and `ITaskCheckerService` to "Instance per lifetime scope" as the latter is now dependent on the former
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.5

__Release Date:__ 2020-05-05

__Environment:__ Test

__Front-end:__ 

None

__Back-end:__

- `[Fixed]` `GET` task requests from VM now include `Bearer` token in function requests. Refactored code to make service purposes clearer.
- `[Changed]` Refactored static helper classes in functions to interfaces to allow for easier future unit testing.
  - `SettingsHelper` -> `ISettingHelper`
  - `BlobStorageHelper` -> `IBlobStorageHelper`
  
__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.4

__Release Date:__ 2020-04-30

__Environment:__ Test

__Front-end:__

- `[Fixed]` Numbers on loss view pages updated to be formatted consistently with numbers elsewhere on site - with commas i.e. 10,000
- `[Fixed]` On first load, the access token was being provided as null when the user had successfully logged in. Found to be known behaviour when using ClientID as scope in request
  - Github issue: [#736 acquireTokensilent return null accessToken randomly](https://github.com/AzureAD/microsoft-authentication-library-for-js/issues/736)

__Back-end:__

- `[Added]` Additional metadata in Graphene to Prime export. This includes:
  - Network ID (Prime metadata key: `networkId`)
  - Network revision (`networkRevision`)
  - Node ID (`nodeId`)
  - Loss view information (`lossView.{property name}`)
- `[Fixed]` Potential fix added for dead-letter message bug on `gr-upload-yelt` queue (though would have affected other queues if they had similar traffic)
  - Removed manual completion of messages

__Infrastructure:__

None

__Deployment Pipeline:__

None

---
## 1.0.1.3

__Release Date:__ 2020-04-27

__Environment:__ Test

__Front-end:__

None

__Back-end:__

- `[Added]` Losses are now cleared from the application database whenever uploading to AnalyzeRe (Prime or Graphene)
  - Regardless of success or error in the upload process
- `[Fixed]` Currency handling when exporting losses from Graphene to Prime
- `[Fixed]` Description of Prime loss set when exporting from Graphene to Prime was previously not being picked up from metadata provided

__Infrastructure:__

- `[Added]` New queue in service bus for data deletion: `gr-clear-appdb-losses`

__Deployment Pipeline:__

None

---
## 1.0.1.2

__Release Date:__ 2020-04-24

__Environment:__ Test

__Front-end:__

- `[Added]` Select Prime event catalogs on front end when uploading to AnalyzeRe Prime
- `[Added]` Map user lines of business in CEDE database to Brit lines of business __NB.__ this must by done before perils can be mapped or loss/geospatial analyses can be run. 
- `[Added]` Currency selection in Graphene results output. Currencies are determined by the distinct list of currencies of layers in the network. 
- `[Added]` Download current exchange rates as a template file
  - __NB. Care must be taken when dealing with exchange rates as they are linked to each analysis. _I.e._ changing the rates for one analysis will change them for _ALL_ analyses.__ 
  - Speak to __@David Mell__ before making any changes on this page. 
- `[Changed]` Line of business columns included in tables on CLF and CEDE result pages
- `[Fixed]` Graphene outputs limit and attachment probabilities correctly now showing return periods rather than the # of simulated years in which the attachment point/limit was reached
- `[Removed]` No longer able to export a loss set directly from Graphene to Prime, to do this you must add it to a network first. This is due to the way we are indexing the event catalogs 

__Back-end:__

- `[Added]` All Azure function application HTTP endpoints now require authentication. 
  - For requests directly from the front end, these use the token retrieved when users login as normal.
  - It is possible that users will experience some slightly different behaviour relative to existing functionality, if a user token times out (after 1hr), a pop-up will briefly appear which refreshes the users login. The user typically shouldn'te be required to enter anything on this pop-up and it will disappear shortly after appearing. If your user credentials are requested again, users should input these.
- `[Changed]` All TouchstoneRe loss analyses are now output by line of business code
- `[Changed]` All Touchstone & TouchstoneRe loss run details are now split by line of business
  - For TouchstoneRe, this mapping is predetermined and stored in the `StratusTools` database
  - For Touchstone, users are required to save a mapping from the user lines of business included in the exposure database. These are stored in Azure tables
- `[Changed]` Uploads losses from CLFs, CEDEs and Graphene exports in 'ELT' format to AnalyzeRe Prime. This consists of dropping the TrialID and Sequence columns from the `select`. Other than this all existing queries to retrieve this data remain the same.
 - `[Fixed]` When creating a program in the application database, when there is an error (generally due to the SQL server being in sleep mode), now an error is thrown. This should cause the logic app to retry up to 5 times. This is time, the database should be brought out of sleep mode
 - `[Fixed]` CLF & CEDE uploads to AnalyzeRe Prime are now uploaded in 'ELT' format. 
   - This is done by dropping the `TrialID` and `Sequence` columns so is not true ELT format but it is what is done manually by the team now to get data into Prime

__Infrastructure:__

- `[Added]` Line of business mapping Azure table
- `[Changed]` System assigned identities given do:
  - `stratus-vm`
  - All logic apps
- `[Changed]` Authentication settings on both azure function apps

__Deployment Pipeline:__

- `[Added]` `[Variable]` Added 'AadAudience' variable relating to ClientId of app registration
- `[Changed]` `[stratus-test]` Linked 'Stratus API Test' variable group to `[stratus-test]` pipeline
- `[Changed]` `[stratus-test]` Passed in `-aadAudience` parameter into function app powershell command

---

## Template:

## _Version number_

__Release Date:__ 

__Environment:__ 

__Front-end:__

- `[Tag]`

__Back-end:__

- `[Tag]`

__Infrastructure:__

- `[Tag]`

__Deployment Pipeline:__

- `[Tag]`