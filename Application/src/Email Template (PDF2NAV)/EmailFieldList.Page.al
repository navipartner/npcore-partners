page 6059792 "NPR E-mail Field List"
{
    Caption = 'E-mail Field List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        tempTableNo: Integer;
    begin
    end;
}

