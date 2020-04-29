table 6014447 "Scanner - Setup"
{
    // NPR5.27/TJ  /20160826  CASE 248276 Removing unused variables and fields, renaming fields and variables to use standard naming procedures
    // NPR5.29/CLVA/20161122  CASE 252352 Added fields: "FTP Download to Server Folder","FTP Site address","FTP Filename","FTP Username","FTP Password"
    // NPR5.38/MHA /20171222  CASE 299271 Added field 24 "Backup Filename"
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 40

    Caption = 'Scanner - Setup';
    LookupPageID = "Scanner - List";

    fields
    {
        field(1;ID;Code[20])
        {
            Caption = 'Scanner ID';
            Description = 'Skanner ID';
        }
        field(2;Port;Option)
        {
            Caption = 'Connected on port';
            Description = 'Skanneren er tilsluttet port';
            OptionCaption = 'USB,COM1,COM2,COM3,COM4,COM5,LPT1,WiFi,Keyboard';
            OptionMembers = USB,COM1,COM2,COM3,COM4,COM5,LPT1,WiFi,Keyboard;
        }
        field(3;"Path - EXE / DLL Directory";Text[250])
        {
            Caption = 'Path - EXE / DLL directory';
        }
        field(4;"Path - Drop Directory";Text[250])
        {
            Caption = 'Path - Drop directory';
        }
        field(5;"Path - Pickup Directory";Text[250])
        {
            Caption = 'Path - Pickup directory';
        }
        field(6;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(7;Type;Option)
        {
            Caption = 'Communication I/O';
            Description = 'Indl�sningsform til/fra Navision';
            OptionCaption = 'Direct Cable,File,WiFi,Weight';
            OptionMembers = "Direct Cable",File,WiFi,Weight;
        }
        field(8;"Field Type";Option)
        {
            Caption = 'Field Length Type';
            OptionCaption = 'Fixed,Dynamic';
            OptionMembers = "Fixed",Dynamic;
        }
        field(9;"Scanning End String";Code[10])
        {
            Caption = 'End scanning string';
            Description = 'f.eks. E = End';
        }
        field(10;"EXE - In";Text[30])
        {
            Caption = 'Executing file for reading from scanner';
        }
        field(11;"EXE - Out";Text[30])
        {
            Caption = 'Executing file for writing to scanner';
        }
        field(12;"File - In Record Sep. Type";Option)
        {
            Caption = 'File - In Record Sep Type';
            OptionCaption = 'New Line,Char';
            OptionMembers = "New Line",Char;
        }
        field(16;"Line Type";Option)
        {
            Caption = 'Line Type';
            Description = 'Record: 1 linie indholder alt info om rec. Field: hver linie er et felt i en record';
            OptionCaption = 'Record,Field';
            OptionMembers = "Record","Field";
        }
        field(17;"Prefix Length";Integer)
        {
            Caption = 'Prefix length';
        }
        field(18;"Clear Scanner Option";Text[5])
        {
            Caption = 'Empty scanner option';
            Description = 'parameter som sletter indholdet i skanneren';
        }
        field(19;"Decimal Point";Text[1])
        {
            Caption = 'Decimal point';
            Description = 'seperator mellem heltal og decimaler. hvis ingen = ''''';
        }
        field(20;"Leading Decimals";Integer)
        {
            Caption = 'Number of decimals';
            Description = 'antal decimaler efter kommaet.';
        }
        field(22;"File - After";Option)
        {
            Caption = 'File after reading';
            OptionCaption = ' ,Backup,Delete,Backup+Delete';
            OptionMembers = " ",Backup,Delete,"Backup+Delete";
        }
        field(23;"File - Backup Directory";Text[250])
        {
            Caption = 'Path to backup files';
        }
        field(24;"Backup Filename";Text[100])
        {
            Caption = 'Backup Filename';
            Description = 'NPR5.38';
        }
        field(25;"Record Field Sep.";Text[3])
        {
            Caption = 'Field separator string';
            Description = 'hvis Line Type = Record then evt komma separeret';
        }
        field(26;"File - Name Type";Option)
        {
            Caption = 'File - Name Type';
            OptionCaption = 'GUID32,DateTime,Prefix,Fixed filename,Ask';
            OptionMembers = GUID,DateTime,Prefix,"Fixed",FixedAsk;
        }
        field(27;"File - Name/Prefix";Text[30])
        {
            Caption = 'File - Name/Prefix';
        }
        field(28;"File - Line Skip Pre";Integer)
        {
            Caption = 'Skip lines before reading data';
        }
        field(30;"Placement Popup";Boolean)
        {
            Caption = 'Ask: Counting position';
        }
        field(31;"EXE - Update Scanner";Text[30])
        {
            Caption = 'Executing file for writing to scanner';
        }
        field(33;"EXE - Update Scanner Param.";Text[30])
        {
            Caption = 'EXE - Update Scanner Parameters';
        }
        field(37;"Weight - No. of MA Samples";Integer)
        {
            Caption = 'Weight - No. of MA Samples';
        }
        field(38;Debug;Boolean)
        {
            Caption = 'Debug';
        }
        field(40;"Alt. Import Codeunit";Integer)
        {
            Caption = 'Alt. import codeunit';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(41;"Import to Server Folder First";Text[250])
        {
            Caption = 'Import to server first';
        }
        field(42;"Local Client Scanner Folder";Text[250])
        {
            Caption = 'Local Client scanner folder';
        }
        field(43;"FTP Download to Server Folder";Boolean)
        {
            Caption = 'FTP Download to Server Folder';
        }
        field(44;"FTP Site address";Text[250])
        {
            Caption = 'FTP Site address';
        }
        field(45;"FTP Filename";Text[50])
        {
            Caption = 'FTP Filename';
        }
        field(46;"FTP Username";Text[50])
        {
            Caption = 'FTP Username';
        }
        field(47;"FTP Password";Text[50])
        {
            Caption = 'FTP Password';
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }
}

