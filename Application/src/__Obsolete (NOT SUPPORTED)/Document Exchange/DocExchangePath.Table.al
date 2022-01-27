table 6059933 "NPR Doc. Exchange Path"
{
    Access = Internal;
    Caption = 'Doc. Exchange Path';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Document Exchange functionality removed';

    fields
    {
        field(10; Direction; Option)
        {
            Caption = 'Direction';
            OptionCaption = 'Import,Export';
            OptionMembers = Import,Export;
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'All,Customer,Vendor';
            OptionMembers = All,Customer,Vendor;
            DataClassification = CustomerContent;
        }
        field(30; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(40; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
        }
        field(50; "Archive Path"; Text[250])
        {
            Caption = 'Archive Path';
            DataClassification = CustomerContent;
        }
        field(60; Enabled; Boolean)
        {
            Caption = 'Enabled';
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
        field(170; "Electronic Format Code"; Code[20])
        {
            Caption = 'Electronic Format Code';
            DataClassification = CustomerContent;
        }
        field(180; "Localization Format Code"; Boolean)
        {
            Caption = 'Localization Format Code';
            DataClassification = CustomerContent;
        }
        field(200; "Use Export FTP Settings"; Boolean)
        {
            Caption = 'Use Export FTP Settings';
            DataClassification = CustomerContent;
        }
        field(210; "Export Locally"; Boolean)
        {
            Caption = 'Export Locally';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Direction, Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

