page 6151490 "NPR Salesperson List"
{
    Caption = 'Salesperson List';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Selected; Selected)
                {

                    Caption = 'Selected';
                    Editable = true;
                    Visible = IsMultiSelectionMode;
                    ToolTip = 'Specifies the value of the Selected field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.Mark(Selected);
                    end;
                }
                field("Code"; Rec.Code)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
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

