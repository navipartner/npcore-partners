page 6151305 "NPR NpEc Customer Mapping"
{
    Extensible = False;
    Caption = 'Np E-commerce Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpEc Customer Mapping";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies E-Commerce Store Code.';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the customer''s country/region.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the postal code.';
                    ApplicationArea = NPRRetail;
                }
                field("Config. Template Code"; Rec."Config. Template Code")
                {

                    ToolTip = 'Specifies Configuration Template Code.';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Name"; Rec."Country/Region Name")
                {

                    ToolTip = 'Specifies the country or region name.';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the city of the customer.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
