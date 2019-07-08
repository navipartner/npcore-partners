page 6014623 "Generic Key List"
{
    // NPR5.48/TJ  /20181129 CASE 318531 New object

    Caption = 'Select sorting key';
    Editable = false;
    PageType = List;
    SourceTable = "Integer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SortingKey;SortingKey)
                {
                    Caption = 'Sorting Key';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SortingKey := SortingKeyArr[Number];
    end;

    trigger OnOpenPage()
    begin
        if not RecRefSet then
          Error(Text001);
        KeyCount := RecRef.KeyCount;
        FilterGroup := 2;
        SetRange(Number,1,KeyCount);
        FilterGroup := 0;
        BuildKeyList();
        SetPosition(Rec.FieldName(Number) + '=CONST(' + Format(CurrSortingKeyIndex) + ')');
    end;

    var
        RecRef: RecordRef;
        RecRefSet: Boolean;
        SortingKey: Text;
        SortingKeyArr: array [40] of Text;
        Text001: Label 'You must use function SetParameters before running the page.';
        CurrSortingKey: Text;
        CurrSortingKeyIndex: Integer;
        KeyCount: Integer;

    procedure SetParameters(RecRefHere: RecordRef;CurrSortingKeyHere: Text)
    begin
        RecRef := RecRefHere;
        RecRefSet := true;
        CurrSortingKey := CurrSortingKeyHere;
    end;

    local procedure BuildKeyList()
    var
        i: Integer;
        GenericFilterPageMgt: Codeunit "Generic Filter Page Mgt.";
    begin
        for i := 1 to KeyCount do begin
          SortingKeyArr[i] := GenericFilterPageMgt.ReadKeyString(RecRef,i);
          if SortingKeyArr[i] = CurrSortingKey then
            CurrSortingKeyIndex := i;
        end;
    end;

    procedure GetSortingKey(KeyIndexHere: Integer): Text
    begin
        exit(SortingKeyArr[KeyIndexHere]);
    end;
}

