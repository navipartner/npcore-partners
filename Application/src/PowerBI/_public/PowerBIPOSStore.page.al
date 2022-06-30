page 6184618 NPRPowerBIPOSStore
{
    PageType = List;
    Caption = 'PowerBI POS Store';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR POS Store";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = All;
                }
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                }
                field(Contact; Rec.Contact)
                {
                    ToolTip = 'Specifies the value of the Contact field';
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = All;
                }
                field("Opening Date"; Rec."Opening Date")
                {
                    ToolTip = 'Specifies the value of the Opening Date field';
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = All;
                }
                field("Store Size"; Rec."Store Size")
                {
                    ToolTip = 'Specifies the value of the Store Size field';
                    ApplicationArea = All;
                }
            }
        }
    }
}