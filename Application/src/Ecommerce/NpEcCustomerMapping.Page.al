page 6151305 "NPR NpEc Customer Mapping"
{
    Caption = 'Np E-commerce Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpEc Customer Mapping";
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies E-Commerce Store Code.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s country/region.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the postal code.';
                }
                field("Config. Template Code"; Rec."Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Configuration Template Code.';
                }
                field("Country/Region Name"; Rec."Country/Region Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country or region name.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city of the customer.';
                }
            }
        }
    }
}