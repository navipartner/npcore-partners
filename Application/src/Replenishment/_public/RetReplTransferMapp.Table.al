table 6014595 "NPR Ret. Repl. Transfer Mapp."
{
    Caption = 'Retail Replenishment Transfer Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Ret. Repl. Transfer Mapp.";
    DrillDownPageId = "NPR Ret. Repl. Transfer Mapp.";

    fields
    {
        field(1; "To Location"; Code[10])
        {
            Caption = 'To Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(2; "From Location"; Code[10])
        {
            Caption = 'From Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(3; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 99;
        }
    }
    keys
    {
        key(PK; "To Location", "From Location", Priority)
        {
            Clustered = true;
        }
    }
}
