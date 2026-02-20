tableextension 6014526 "NPR Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(6059981; "NPR Inc Ecom Sales Line Id"; Guid)
        {
            Caption = 'Incoming Ecommerce Sales Line Id';
            DataClassification = CustomerContent;
        }
        field(6059982; "NPR Loyalty Discount"; Boolean)
        {
            Caption = 'Loyalty Discount';
            DataClassification = CustomerContent;
        }
        field(6059983; "NPR CreatedfrmPointsPmntLineId"; Guid)
        {
            Caption = 'Created from Points Payment Line Id';
            DataClassification = CustomerContent;
        }
    }
}