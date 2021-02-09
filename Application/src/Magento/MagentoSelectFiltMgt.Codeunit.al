codeunit 6151411 "NPR Magento Select. Filt. Mgt."
{
    local procedure AddQuotes(inString: Text[1024]): Text
    begin
        exit('''' + inString + '''');
    end;

    local procedure GetSelectionFilter(var TempRecRef: RecordRef; SelectionFieldID: Integer): Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FirstRecRef: Text;
        LastRecRef: Text;
        SelectionFilter: Text;
        SavePos: Text;
        TempRecRefCount: Integer;
        More: Boolean;
    begin
        RecRef.Open(TempRecRef.Number);
        TempRecRefCount := TempRecRef.Count;
        if TempRecRefCount > 0 then begin
            TempRecRef.Find('-');
            while TempRecRefCount > 0 do begin
                TempRecRefCount := TempRecRefCount - 1;
                RecRef.SetPosition(TempRecRef.GetPosition);
                RecRef.Find;
                FieldRef := RecRef.Field(SelectionFieldID);
                FirstRecRef := Format(FieldRef.Value);
                LastRecRef := FirstRecRef;
                More := TempRecRefCount > 0;
                while More do
                    if RecRef.Next = 0 then
                        More := false
                    else begin
                        SavePos := TempRecRef.GetPosition;
                        TempRecRef.SetPosition(RecRef.GetPosition);
                        if not TempRecRef.Find then begin
                            More := false;
                            TempRecRef.SetPosition(SavePos);
                        end else begin
                            FieldRef := RecRef.Field(SelectionFieldID);
                            LastRecRef := Format(FieldRef.Value);
                            TempRecRefCount := TempRecRefCount - 1;
                            if TempRecRefCount = 0 then
                                More := false;
                        end;
                    end;
                if SelectionFilter <> '' then
                    SelectionFilter := SelectionFilter + '|';
                if FirstRecRef = LastRecRef then
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef)
                else
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef) + '..' + AddQuotes(LastRecRef);
                if TempRecRefCount > 0 then
                    TempRecRef.Next;
            end;
            exit(SelectionFilter);
        end;
    end;

    procedure GetSelectionFilterForItemGroup(var MagentoItemGroup: Record "NPR Magento Category"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(MagentoItemGroup);
        exit(GetSelectionFilter(RecRef, MagentoItemGroup.FieldNo(Id)));
    end;

    procedure GetSelectionFilterForBrand(var MagentoBrand: Record "NPR Magento Brand"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(MagentoBrand);
        exit(GetSelectionFilter(RecRef, MagentoBrand.FieldNo(Id)));
    end;
}