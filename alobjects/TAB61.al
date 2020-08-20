tableextension 6014448 tableextension6014448 extends "Electronic Document Format"
{
    // NPR5.55/THRO/20200504 CASE 380787 Added field 6059942 "Delivery Endpoint"
    fields
    {
        field(6059942; "Delivery Endpoint"; Code[20])
        {
            Caption = 'Delivery Endpoint';
            DataClassification = CustomerContent;
            TableRelation = "Nc Endpoint";
        }
    }
}

