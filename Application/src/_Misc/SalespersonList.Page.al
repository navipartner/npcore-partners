page 6151490 "NPR Salesperson List"
{
    Caption = 'Salesperson List';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                        Rec.Mark(Selected);
                    end;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Selected := Rec.Mark();
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
        Rec.Copy(Salesperson, true);
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

