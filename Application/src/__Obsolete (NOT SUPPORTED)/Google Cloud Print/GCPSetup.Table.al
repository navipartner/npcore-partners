table 6014583 "NPR GCP Setup"
{
    Access = Internal;

    Caption = 'Google Cloud Print Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Cleanup GCP Setup';

    fields
    {
        field(1; "Printer ID"; Text[50])
        {
            Caption = 'Printer ID';
            DataClassification = CustomerContent;
        }
        field(2; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Report,Codeunit';
            OptionMembers = "Report","Codeunit";
            DataClassification = CustomerContent;
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            DataClassification = CustomerContent;
        }
        field(4; "Cloud Job Ticket"; BLOB)
        {
            Caption = 'Cloud Job Ticket';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Printer ID", "Object Type", "Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}

