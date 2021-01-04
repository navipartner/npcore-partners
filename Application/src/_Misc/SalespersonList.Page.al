page 6151490 "NPR Salesperson List"
{
    // NPR5.55/ALPO/20200422 CASE 400925 User friendly salesperson selection using multi-selection mode

    Caption = 'Salesperson List';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    UsageCategory = Administration;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Selected; Selected)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    Editable = true;
                    Visible = IsMultiSelectionMode;
                    ToolTip = 'Specifies the value of the Selected field';

                    trigger OnValidate()
                    begin
                        Mark(Selected);
                    end;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Selected := Mark;
    end;

    var
        IsMultiSelectionMode: Boolean;
        Selected: Boolean;

    procedure SetMultiSelectionMode(Set: Boolean)
    begin
        IsMultiSelectionMode := Set;
    end;

    procedure SetDataset(var Salesperson: Record "Salesperson/Purchaser")
    begin
        Copy(Salesperson, true);
    end;

    procedure GetDataset(var Salesperson: Record "Salesperson/Purchaser")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        Salesperson.Copy(Rec, true);
        if Salesperson.GetFilters <> '' then begin
            RecRef.GetTable(Salesperson);
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.GetFilter <> '' then
                    FldRef.SetRange();
            end;
        end;
    end;
}

