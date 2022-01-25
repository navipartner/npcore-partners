page 6014660 "NPR Generic Key List"
{
    Caption = 'Select sorting key';
    Editable = false;
    PageType = List;
    SourceTable = "Integer";
    UsageCategory = None;

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
                    ToolTip = 'Specifies the value of the Sorting Key field.';
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
            Error(Text001);
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
        SortingKey: Text;
        SortingKeyArr: array[40] of Text;
        Text001: Label 'You must use function SetParameters before running the page.';
        CurrSortingKey: Text;
        CurrSortingKeyIndex: Integer;
        KeyCount: Integer;

    procedure SetParameters(RecRefHere: RecordRef; CurrSortingKeyHere: Text)
    begin
        RecRef := RecRefHere;
        RecRefSet := true;
        CurrSortingKey := CurrSortingKeyHere;
    end;

    local procedure BuildKeyList()
    var
        i: Integer;
        GenericFilterPageMgt: Codeunit "NPR Generic Filter Page Mgt.";
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

