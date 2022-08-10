# Data Archives
This article provides information needed to understand how NP retail exports to .xml archives, how these .xml archives are secured and how you can validate that they have not been tampered with.
## Period Archives
The automatic period archiving process is done via the job queue module in Business Central.
The exported archives are stored in an Azure Blob Storage, inside a customer specific container, that NaviPartner maintains full control over.
This means that access to an exported archive of a customer will be provided by reaching out to NaviPartner via the usual communication channels, i.e. case system, contact e-mail.

The schema file that archives adhere to can be downloaded at: 
[Archive Schema](./files/nf525_schema.xsd)

You can always manually export a monthly period manually as well by navigating to the "Workshift Summary" page and using action "Archive".

## Archive Validation
To ensure integrity of exported archives, all .xml archives are signed using the same certificate as all POS event signings.

The XMLDSIG canonicalization method is XML-C14N 1.0 and the signing is done via RSA & SHA256 as all the other POS event signings.
If you reach out to NaviPartner we can supply you with a .cer certificate file that includes the public key of the cert used by a specific customer.
NaviPartner also provides a powershell script that can be downloaded from and executed to validate both the schema of the XML file and the signature validity: 
[Archive Validation Schema](./files/nf525_validate_archive.ps1)

It takes 3 parameters:
- archivePath: The archive to be validated
- schemaPath: The XML schema file to validate it against
- certificatePath: The .cer certificate file.


Easiest way to execute the script is to place all 4 files, meaning the archive, the schema, the certificate and the script in the same folder - after which you can execute the script like this:
![Script Execution](./images/script_execution.png)
## Archive Structure
The archive contains the overall structure of:
```
<Archive>
    <GrandPeriod>
        <ArchiveSignature/>
        <SystemEntryNo/>
        <SequentialID/>
        <FromDate/>
        <ToDate/>
        <GrandTotal/>
        <PerpetualAbsoluteGrandTotal/>
        <PerpetualGrandTotal/>
        <PeriodGrandTotalSignature/>

        <Tickets/>        

        <Duplicates/>        

        <GrandTotals/>        

        <JET/>        
    </GrandPeriod>

    <Signature/>    
</Archive>
```
First a header section for the monthly grand period being archived followed by lists of all the events signed in that period.
After the GrandPeriod element is a Signature element that contains the XML signature for the file, making it tamper proof. 

See the schema file linked above for an indepth overview of all XML elements in each of the 4 event type sections (tickets, duplicates, grandtotals, jet).

## Legacy
Prior to version 11 of NPRetail, archive files were not signed and followed a different schema. The old schema can be downloaded from: 
[Old Archive Schema](./files/nf525_schema_old.xsd)