page 6151461 "NPR Magento Customer Mapping"
{
    Caption = 'Magento Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Customer Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = City;
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field("Country/Region Name"; Rec."Country/Region Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Template Code field';
                }
                field("Config. Template Code"; Rec."Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Config. Template Code field';
                }
                field("Fixed Customer No."; Rec."Fixed Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Customer No. field';
                }
            }
        }
    }
}