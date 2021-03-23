tableextension 6014448 "NPR Electronic Document Format" extends "Electronic Document Format"
{
    fields
    {
        field(6059942; "NPR Delivery Endpoint"; Code[20])
        {
            Caption = 'Delivery Endpoint';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Endpoint";
        }
    }
}