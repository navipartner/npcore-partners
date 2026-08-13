tableextension 6150613 "NPR RS Inventory Posting Setup" extends "Inventory Posting Setup"
{
    fields
    {
        field(6150613; "NPR RS Calc. VAT Account"; Code[20])
        {
            Caption = 'RS Calc. VAT Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(6150614; "NPR RS Calc. Margin Account"; Code[20])
        {
            Caption = 'RS Calc. Margin Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
    }
}
