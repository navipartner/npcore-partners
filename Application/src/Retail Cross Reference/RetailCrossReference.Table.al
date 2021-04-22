table 6151180 "NPR Retail Cross Reference"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created
    // NPR5.54/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization
    // NPR5.55/ALPO/20200424 CASE 401611 Remove dummy fields needed for 5.54 upgrade performace optimization

    Caption = 'Retail Cross Reference';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Retail Cross References";
    LookupPageID = "NPR Retail Cross References";
    ObsoleteState = Pending;
    ObsoleteReason = 'Use systemID instead. (For POS sales, the same systemID is transferred from active sale header/lines to finished pos entry header/lines).';

    fields
    {
        field(1; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
        }
        field(5; "Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(10; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(15; "Record Value"; Text[100])
        {
            Caption = 'Record Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Retail ID")
        {
        }
        key(Key2; "Reference No.", "Table ID")
        {
        }
    }

    fieldgroups
    {
    }
}

