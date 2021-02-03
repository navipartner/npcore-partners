page 6151072 "NPR Purchase Price Factbox"
{
    Caption = 'Purchase Prices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Price";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Quantity field';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Unit Cost field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
            }
        }
    }
}

