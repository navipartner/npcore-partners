page 6059792 "E-mail Field List"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page Contains a List of Table Fields used for Setting up E-mail Template Field Merge.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)

    Caption = 'E-mail Field List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Field";
    SourceTableView = SORTING(TableNo,"No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                    Caption = 'No.';
                }
                field("Field Caption";"Field Caption")
                {
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

