page 6014527 "NPR TouchScreen: G/L Accounts"
{
    Caption = 'Touch Screen - Lookup G/L Account';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "G/L Account";
    SourceTableView = SORTING("Search Name")
                      ORDER(Ascending)
                      WHERE("No." = FILTER(<> ''),
                            Blocked = CONST(false),
                            "NPR Is Retail Payment" = CONST(true));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}