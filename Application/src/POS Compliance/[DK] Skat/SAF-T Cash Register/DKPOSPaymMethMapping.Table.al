table 6060011 "NPR DK POS Paym. Meth. Mapping"
{
    Access = Internal;
    Caption = 'DK POS Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DK POS Paym. Meth. Mapping";
    LookupPageId = "NPR DK POS Paym. Meth. Mapping";

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(2; "SAF-T Payment Type"; Enum "NPR DK SAF-T Payment Type")
        {
            Caption = 'SAF-T Payment Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code")
        {
            Clustered = true;
        }
    }
}
