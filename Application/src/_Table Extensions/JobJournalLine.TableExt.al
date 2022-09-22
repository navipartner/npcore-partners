tableextension 6014477 "NPR Job Journal Line" extends "Job Journal Line"
{
    fields
    {
        field(6014400; "NPR POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(6014401; "NPR POS Entry Sales Line No."; Integer)
        {
            Caption = 'POS Entry Sales Line No.';
            DataClassification = CustomerContent;
        }
    }
}
