tableextension 6014478 "NPR Country/Region" extends "Country/Region"
{
    fields
    {
        field(6014400; "NPR HL Country ID"; Code[10])
        {
            Caption = 'HeyLoyalty Country ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(HLCountryID; "NPR HL Country ID") { }
    }
}