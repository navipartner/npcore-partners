page 6151461 "NPR Magento Customer Mapping"
{
    // MAG2.22/MHA /20190710  CASE 360098 Object created
    // MAG2.26/MHA /20200429  CASE 402247 Added field 30 "Fixed Customer No."

    Caption = 'Magento Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Customer Mapping";
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
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field("Country/Region Name"; "Country/Region Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Customer Template Code"; "Customer Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Template Code field';
                }
                field("Config. Template Code"; "Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Config. Template Code field';
                }
                field("Fixed Customer No."; "Fixed Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Customer No. field';
                }
            }
        }
    }

    actions
    {
    }
}

