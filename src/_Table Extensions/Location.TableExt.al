tableextension 6014418 "NPR Location" extends Location
{
    // NPR4.16/TJ/20151103 CASE 222281 Added new field Store Group Code
    fields
    {
        field(6014473; "NPR Store Group Code"; Code[20])
        {
            Caption = 'Store Group Code';
            DataClassification = CustomerContent;
            Description = '#222281';
            TableRelation = "NPR Store Group";
        }
    }
}

