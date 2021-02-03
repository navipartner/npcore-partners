page 6014623 "NPR Generic Key List"
{
    Caption = 'Select sorting key';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Integer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SortingKey; SortingKey)
                {
                    ApplicationArea = All;
                    Caption = 'Sorting Key';
                    ToolTip = 'Specifies the value of the Sorting Key field';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SortingKey := SortingKeyArr[Rec.Number];
    end;

    trigger OnOpenPage()
    begin
        if not RecRefSet then
            Error(SetParametersErr);
        KeyCount := RecRef.KeyCount;
        Rec.FilterGroup := 2;
        Rec.SetRange(Number, 1, KeyCount);
        Rec.FilterGroup := 0;
        BuildKeyList();
        Rec.SetPosition(Rec.FieldName(Number) + '=CONST(' + Format(CurrSortingKeyIndex) + ')');
    end;

    var
        RecRef: RecordRef;
        RecRefSet: Boolean;
        CurrSortingKeyIndex: Integer;
        KeyCount: Integer;
        SetParametersErr: Label 'You must use function SetParameters before running the page.';
        CurrSortingKey: Text;
        SortingKey: Text;
        SortingKeyArr: array[40] of Text;

    procedure SetParameters(RecRefHere: RecordRef; CurrSortingKeyHere: Text)
    begin
        RecRef := RecRefHere;
        RecRefSet := true;
        CurrSortingKey := CurrSortingKeyHere;
    end;

    local procedure BuildKeyList()
    var
        GenericFilterPageMgt: Codeunit "NPR Generic Filter Page Mgt.";
        i: Integer;
    begin
        for i := 1 to KeyCount do begin
            SortingKeyArr[i] := GenericFilterPageMgt.ReadKeyString(RecRef, i);
            if SortingKeyArr[i] = CurrSortingKey then
                CurrSortingKeyIndex := i;
        end;
    end;

    procedure GetSortingKey(KeyIndexHere: Integer): Text
    begin
        exit(SortingKeyArr[KeyIndexHere]);
    end;
}

