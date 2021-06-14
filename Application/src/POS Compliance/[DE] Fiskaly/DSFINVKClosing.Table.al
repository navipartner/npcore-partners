table 6014573 "NPR DSFINVK Closing"
{
    Caption = 'DSFINVK Closing';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "DSFINVK Closing No."; Integer)
        {
            Caption = 'DSFINVK Closing No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(20; "Closing ID"; Guid)
        {
            Caption = 'Closing ID';
            Description = 'Cash Point Closing ID for DE Fiskaly';
            DataClassification = CustomerContent;
        }
        field(30; "Closing Date"; Date)
        {
            Caption = 'Closing Date';
            DataClassification = CustomerContent;
        }
        field(40; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry No.";
        }
        field(50; "Workshift Entry No."; Integer)
        {
            Caption = 'Workshift Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Workshift Checkpoint"."Entry No.";
        }
        field(60; "Error Message"; Blob)
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(70; "Has Error"; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
        }
        field(80; State; Enum "NPR DSFINVK State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            InitValue = " ";
        }
        field(90; "Trigged Export"; Boolean)
        {
            Caption = 'Trigged Export';
            DataClassification = CustomerContent;
        }
        field(100; "Export ID"; Guid)
        {
            Caption = 'Export ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "DSFINVK Closing No.", "POS Unit No.")
        {
            Clustered = true;
        }
    }
}