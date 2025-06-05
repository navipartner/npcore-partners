page 6151461 "NPR Magento Customer Mapping"
{
    Extensible = False;
    Caption = 'Magento Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Customer Mapping";
    UsageCategory = Administration;
    ApplicationArea = NPRMagento;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = City;
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Country/Region Name"; Rec."Country/Region Name")
                {

                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRMagento;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRMagento;
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Template Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Config. Template Code"; Rec."Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Config. Template Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Fixed Customer No."; Rec."Fixed Customer No.")
                {

                    ToolTip = 'Specifies the value of the Fixed Customer No. field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
