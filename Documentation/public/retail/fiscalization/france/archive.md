
## Period Archives
The automatic period archiving process is done via the job queue module in Business Central.
The exported archives are stored in an Azure Blob Storage, inside a customer specific container, that NaviPartner maintains full control over.
This means that access to an exported archive of a customer will be provided by reaching out to NaviPartner via the usual communication channels, i.e. case system, contact e-mail.

The schema file that archives adhere to can be downloaded at:
**LINK HERE**

You can always manually export a monthly period manually as well by navigating to the "Workshift Summary" page and using action "Archive".

## Archive Validation
To ensure integrity of exported archives, all xml files 
are signed using the same certificate as all POS event signings.

The XMLDSIG canonicalization method is XML-C14N 1.0 and the signing is done via RSA & SHA256 as all the other POS event signings.


NaviPartner provides a powershell script that can be downloaded from and executed to validate both the schema of the XML file and the signature validity:
**LINK HERE**

It takes 3 parameters:
- archivePath: The archive to be validated
- schemaPath: The XML schema file to validate it against
- certificatePath: The cert file including public signature that the archives are signed with.

## Archive Structure
The archive contains the overall structure of:
```
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

    <tickets>
    </tickets>

    <duplicates>
    </duplicates>

    <grandtotals>
    </grandtotals>

    <jet>
    </jet>
</GrandPeriod>

```
First a header section for the monthly grand period being archived followed by lists of all the events signed in that period.
Each event has both the comma separated signed data and the signature along with required event metadata like software version, country etc.