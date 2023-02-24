# Data archive

The Data Archive provides means of backing up and compressing old records. When compression, all entries for which the specified retention period has expired are consolidated into a single entry, while the originals are deleted. However, rather than being deleted, this data can be archived for later use. The archived file format can be opened with Microsoft Excel or as a CSV file.

Some of the main benefits of Data Archive include:

- *Extensive storage costs are avoided* - The archived data is stored in the **Tenant Media** table, which serves the purpose of file storage. 
- *Backup/restore performance is enhanced* - Archiving removes data from backups, reducing their size and eliminating restoration of unnecessary files.
- *Report generation is streamlined* - Report execution and record locking takes longer to be completed, which affects both user and customer experience.
- *The security is increased* - Archiving removes documents from circulation, limiting the chance of a cyber attacks and malware infection. 

> [!Note]
> Make sure you consider the impact that the retrieval times and methods have on your business. 


## Implementation

The overall implementation process consists of four major steps:

  1. Selecting the exact tables that will be included in the process after establishing what the customers' business needs are.
  2. Designing the process, creation of retention policies, and testing the process before actual implementation.
  3. Assigning special archiving permissions to a few select users.
  4. Educating customers on the functionality specifics.

> [!Tip]
> Archives retain the minimum quantity of data necessary for reducing liability risks, the use of resources, as well as the effort and time required to find data. You simply need to configure retention policies and select tables to be archived. 

### Related links

- [Manually create Data archive](../howto/create_data_archive.md)