table 6059931 "NPR Doc. Exch. Setup"
{
    Access = Internal;
    Caption = 'Doc. Exch. Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Document Exchange functionality removed';

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "File Import Enabled"; Boolean)
        {
            Caption = 'File Import Enabled';
            DataClassification = CustomerContent;
        }
        field(30; "Import File Location"; Text[250])
        {
            Caption = 'Import File Location';
            DataClassification = CustomerContent;
        }
        field(40; "Import Local"; Boolean)
        {
            Caption = 'Import Local';
            DataClassification = CustomerContent;
        }
        field(50; "Archive File Location"; Text[250])
        {
            Caption = 'Archive File Location';
            DataClassification = CustomerContent;
        }
        field(60; "Archive Local"; Boolean)
        {
            Caption = 'Archive Local';
            DataClassification = CustomerContent;
        }
        field(100; "Create Document"; Boolean)
        {
            Caption = 'Create Document';
            DataClassification = CustomerContent;
        }
        field(110; "File Export Enabled"; Boolean)
        {
            Caption = 'File Export Enabled';
            DataClassification = CustomerContent;
        }
        field(150; "Unmatched Items Wsht. Template"; Code[10])
        {
            Caption = 'Unmatched Items Wsht. Template';
            DataClassification = CustomerContent;
        }
        field(151; "Unmatched Items Wsht. Name"; Code[10])
        {
            Caption = 'Unmatched Items Wsht. Name';
            DataClassification = CustomerContent;
        }
        field(155; "Autom. Create Unmatched Items"; Boolean)
        {
            Caption = 'Autom. Create Unmatched Items';
            DataClassification = CustomerContent;
        }
        field(160; "Autom. Query Item Information"; Boolean)
        {
            Caption = 'Autom. Query Item Information';
            DataClassification = CustomerContent;
        }
        field(190; "FTP Import Enabled"; Boolean)
        {
            Caption = 'FTP Import Enabled';
            DataClassification = CustomerContent;
        }
        field(200; "Import FTP Server"; Text[150])
        {
            Caption = 'Import FTP Server';
            DataClassification = CustomerContent;
        }
        field(210; "Import FTP Username"; Text[50])
        {
            Caption = 'Import FTP Username';
            DataClassification = CustomerContent;
        }
        field(220; "Import FTP Password"; Text[50])
        {
            Caption = 'Import FTP Password';
            DataClassification = CustomerContent;
        }
        field(230; "Import FTP Folder"; Text[150])
        {
            Caption = 'Import FTP Folder';
            DataClassification = CustomerContent;
        }
        field(240; "Archive FTP Folder"; Text[150])
        {
            Caption = 'Archive FTP Folder';
            DataClassification = CustomerContent;
        }
        field(250; "Import FTP File Mask"; Text[50])
        {
            Caption = 'Import FTP File Mask';
            DataClassification = CustomerContent;
        }
        field(260; "Import FTP Using Passive"; Boolean)
        {
            Caption = 'Import FTP Using Passive';
            DataClassification = CustomerContent;
        }
        field(300; "Export File Location"; Text[250])
        {
            Caption = 'Export File Location';
            DataClassification = CustomerContent;
        }
        field(310; "Export Local"; Boolean)
        {
            Caption = 'Export Local';
            DataClassification = CustomerContent;
        }
        field(350; "FTP Export Enabled"; Boolean)
        {
            Caption = 'FTP Export Enabled';
            DataClassification = CustomerContent;
        }
        field(360; "Export FTP Server"; Text[150])
        {
            Caption = 'Export FTP Server';
            DataClassification = CustomerContent;
        }
        field(370; "Export FTP Username"; Text[50])
        {
            Caption = 'Export FTP Username';
            DataClassification = CustomerContent;
        }
        field(380; "Export FTP Password"; Text[50])
        {
            Caption = 'Export FTP Password';
            DataClassification = CustomerContent;
        }
        field(390; "Export FTP Folder"; Text[150])
        {
            Caption = 'Export FTP Folder';
            DataClassification = CustomerContent;
        }
        field(400; "Export FTP Using Passive"; Boolean)
        {
            Caption = 'Export FTP Using Passive';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

