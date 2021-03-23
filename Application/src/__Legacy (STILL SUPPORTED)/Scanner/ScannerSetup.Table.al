table 6014447 "NPR Scanner - Setup"
{
    Caption = 'Scanner - Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'Scanner ID';
            Description = 'Skanner ID';
            DataClassification = CustomerContent;
        }
        field(2; Port; Option)
        {
            Caption = 'Connected on port';
            Description = 'Skanneren er tilsluttet port';
            OptionCaption = 'USB,COM1,COM2,COM3,COM4,COM5,LPT1,WiFi,Keyboard';
            OptionMembers = USB,COM1,COM2,COM3,COM4,COM5,LPT1,WiFi,Keyboard;
            DataClassification = CustomerContent;
        }
        field(3; "Path - EXE / DLL Directory"; Text[250])
        {
            Caption = 'Path - EXE / DLL directory';
            DataClassification = CustomerContent;
        }
        field(4; "Path - Drop Directory"; Text[250])
        {
            Caption = 'Path - Drop directory';
            DataClassification = CustomerContent;
        }
        field(5; "Path - Pickup Directory"; Text[250])
        {
            Caption = 'Path - Pickup directory';
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Type; Option)
        {
            Caption = 'Communication I/O';
            Description = 'Indlæsningsform til/fra Navision';
            OptionCaption = 'Direct Cable,File,WiFi,Weight';
            OptionMembers = "Direct Cable",File,WiFi,Weight;
            DataClassification = CustomerContent;
        }
        field(8; "Field Type"; Option)
        {
            Caption = 'Field Length Type';
            OptionCaption = 'Fixed,Dynamic';
            OptionMembers = "Fixed",Dynamic;
            DataClassification = CustomerContent;
        }
        field(9; "Scanning End String"; Code[10])
        {
            Caption = 'End scanning string';
            Description = 'f.eks. E = End';
            DataClassification = CustomerContent;
        }
        field(10; "EXE - In"; Text[30])
        {
            Caption = 'Executing file for reading from scanner';
            DataClassification = CustomerContent;
        }
        field(11; "EXE - Out"; Text[30])
        {
            Caption = 'Executing file for writing to scanner';
            DataClassification = CustomerContent;
        }
        field(12; "File - In Record Sep. Type"; Option)
        {
            Caption = 'File - In Record Sep Type';
            OptionCaption = 'New Line,Char';
            OptionMembers = "New Line",Char;
            DataClassification = CustomerContent;
        }
        field(16; "Line Type"; Option)
        {
            Caption = 'Line Type';
            Description = 'Record: 1 linie indholder alt info om rec. Field: hver linie er et felt i en record';
            OptionCaption = 'Record,Field';
            OptionMembers = "Record","Field";
            DataClassification = CustomerContent;
        }
        field(17; "Prefix Length"; Integer)
        {
            Caption = 'Prefix length';
            DataClassification = CustomerContent;
        }
        field(18; "Clear Scanner Option"; Text[5])
        {
            Caption = 'Empty scanner option';
            Description = 'parameter som sletter indholdet i skanneren';
            DataClassification = CustomerContent;
        }
        field(19; "Decimal Point"; Text[1])
        {
            Caption = 'Decimal point';
            Description = 'seperator mellem heltal og decimaler. hvis ingen = ''''';
            DataClassification = CustomerContent;
        }
        field(20; "Leading Decimals"; Integer)
        {
            Caption = 'Number of decimals';
            Description = 'antal decimaler efter kommaet.';
            DataClassification = CustomerContent;
        }
        field(22; "File - After"; Option)
        {
            Caption = 'File after reading';
            OptionCaption = ' ,Backup,Delete,Backup+Delete';
            OptionMembers = " ",Backup,Delete,"Backup+Delete";
            DataClassification = CustomerContent;
        }
        field(23; "File - Backup Directory"; Text[250])
        {
            Caption = 'Path to backup files';
            DataClassification = CustomerContent;
        }
        field(24; "Backup Filename"; Text[100])
        {
            Caption = 'Backup Filename';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(25; "Record Field Sep."; Text[3])
        {
            Caption = 'Field separator string';
            Description = 'hvis Line Type = Record then evt komma separeret';
            DataClassification = CustomerContent;
        }
        field(26; "File - Name Type"; Option)
        {
            Caption = 'File - Name Type';
            OptionCaption = 'GUID32,DateTime,Prefix,Fixed filename,Ask';
            OptionMembers = GUID,DateTime,Prefix,"Fixed",FixedAsk;
            DataClassification = CustomerContent;
        }
        field(27; "File - Name/Prefix"; Text[30])
        {
            Caption = 'File - Name/Prefix';
            DataClassification = CustomerContent;
        }
        field(28; "File - Line Skip Pre"; Integer)
        {
            Caption = 'Skip lines before reading data';
            DataClassification = CustomerContent;
        }
        field(30; "Placement Popup"; Boolean)
        {
            Caption = 'Ask: Counting position';
            DataClassification = CustomerContent;
        }
        field(31; "EXE - Update Scanner"; Text[30])
        {
            Caption = 'Executing file for writing to scanner';
            DataClassification = CustomerContent;
        }
        field(33; "EXE - Update Scanner Param."; Text[30])
        {
            Caption = 'EXE - Update Scanner Parameters';
            DataClassification = CustomerContent;
        }
        field(37; "Weight - No. of MA Samples"; Integer)
        {
            Caption = 'Weight - No. of MA Samples';
            DataClassification = CustomerContent;
        }
        field(38; Debug; Boolean)
        {
            Caption = 'Debug';
            DataClassification = CustomerContent;
        }
        field(40; "Alt. Import Codeunit"; Integer)
        {
            Caption = 'Alt. import codeunit';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;
        }
        field(41; "Import to Server Folder First"; Text[250])
        {
            Caption = 'Import to server first';
            DataClassification = CustomerContent;
        }
        field(42; "Local Client Scanner Folder"; Text[250])
        {
            Caption = 'Local Client scanner folder';
            DataClassification = CustomerContent;
        }
        field(43; "FTP Download to Server Folder"; Boolean)
        {
            Caption = 'FTP Download to Server Folder';
            DataClassification = CustomerContent;
        }
        field(44; "FTP Site address"; Text[250])
        {
            Caption = 'FTP Site address';
            DataClassification = CustomerContent;
        }
        field(45; "FTP Filename"; Text[50])
        {
            Caption = 'FTP Filename';
            DataClassification = CustomerContent;
        }
        field(46; "FTP Username"; Text[50])
        {
            Caption = 'FTP Username';
            DataClassification = CustomerContent;
        }
        field(47; "FTP Password"; Text[50])
        {
            Caption = 'FTP Password';
            ExtendedDatatype = Masked;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }

    fieldgroups
    {
    }
}