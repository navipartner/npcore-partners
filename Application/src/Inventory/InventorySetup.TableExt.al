tableextension 6014404 "NPR Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        field(6014400; "NPR Scanner Provider"; Enum "NPR Scanner Provider")
        {
            Caption = 'Scanner Provider';
            DataClassification = CustomerContent;
        }
    }
}