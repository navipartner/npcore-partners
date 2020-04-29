page 6151305 "NpEc Customer Mapping"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    Caption = 'Np E-commerce Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpEc Customer Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code";"Store Code")
                {
                    ShowMandatory = true;
                }
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field("Config. Template Code";"Config. Template Code")
                {
                }
                field("Country/Region Name";"Country/Region Name")
                {
                }
                field(City;City)
                {
                }
            }
        }
    }

    actions
    {
    }
}

