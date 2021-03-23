page 6014527 "NPR TouchScreen: G/L Accounts"
{
    Caption = 'Touch Screen - Lookup G/L Account';
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "G/L Account";
    SourceTableView = SORTING("Search Name")
                      ORDER(Ascending)
                      WHERE("No." = FILTER(<> ''),
                            Blocked = CONST(false),
                            "NPR Is Retail Payment" = CONST(true));

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
            }
        }
    }
}