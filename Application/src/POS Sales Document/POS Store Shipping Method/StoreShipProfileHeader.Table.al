table 6150895 "NPR Store Ship. Profile Header"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Store Shipment Profiles";
    LookupPageId = "NPR Store Shipment Profiles";

    Access = Internal;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}