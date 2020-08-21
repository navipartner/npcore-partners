page 6151461 "Magento Customer Mapping"
{
    // MAG2.22/MHA /20190710  CASE 360098 Object created
    // MAG2.26/MHA /20200429  CASE 402247 Added field 30 "Fixed Customer No."

    Caption = 'Magento Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Magento Customer Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = City;
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
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
                field("Customer Template Code"; "Customer Template Code")
                {
                    ApplicationArea = All;
                }
                field("Config. Template Code"; "Config. Template Code")
                {
                    ApplicationArea = All;
                }
                field("Fixed Customer No."; "Fixed Customer No.")
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

