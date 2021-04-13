page 6059792 "NPR E-mail Field List"
{
    Caption = 'E-mail Field List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Field";
    SourceTableView = SORTING(TableNo, "No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    ToolTip = 'Specifies the value of the Field Name field';
                }
            }
        }
    }
}

