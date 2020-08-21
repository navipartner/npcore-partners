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
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field("Config. Template Code"; "Config. Template Code")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Name"; "Country/Region Name")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

