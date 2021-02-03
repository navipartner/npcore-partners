codeunit 6014637 "NPR Generic Filter Page Mgt."
{
    procedure AdvancedFilter(RecRef: RecordRef; var FilterStringText: Text) FilterPageOK: Boolean
    var
        FieldTable: Record "Field";
        GenericFilterPage: Page "NPR Generic Filter Page";
        FldRef: FieldRef;
        FilterBuilder: FilterPageBuilder;
        i: Integer;
        FilterViewName: Text;
    begin
        GenericFilterPage.SetRawFilter(FilterStringText);
        GenericFilterPage.SetRecRef(RecRef);
        GenericFilterPage.LookupMode := true;
        FilterPageOK := GenericFilterPage.RunModal = ACTION::LookupOK;
        if FilterPageOK then
            FilterStringText := GenericFilterPage.ReturnRawFilter();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Audit Roll", 'OnAfterActionEvent', 'AdvancedFilter', true, true)]
    local procedure AuditRollAdvancedFilter(var Rec: Record "NPR Audit Roll")
    var
        RecRef: RecordRef;
        FilterStringText: Text;
        o: page 6150718;
    begin
        RecRef.GetTable(Rec);
        if AdvancedFilter(RecRef, FilterStringText) then
            Rec.SetView(FilterStringText);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Menu Filter", 'OnAfterActionEvent', 'GenericFilter', true, true)]
    local procedure POSMenuFilterGenericFilter(var Rec: Record "NPR POS Menu Filter")
    var
        RecRef: RecordRef;
        INS: InStream;
        OUTS: OutStream;
        FilterStringText: Text;
    begin
        Rec.TestField("Table No.");
        RecRef.Open(Rec."Table No.");

        Rec.CalcFields("Table Filter");
        if Rec."Table Filter".HasValue then begin
            Rec."Table Filter".CreateInStream(INS);
            INS.Read(FilterStringText);
        end;

        if AdvancedFilter(RecRef, FilterStringText) then begin
            Rec."Table Filter".CreateOutStream(OUTS);
            OUTS.Write(FilterStringText);
            Rec.Modify;
        end;

        RecRef.Close;
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Menu Filter", 'OnAfterActionEvent', 'DisplayFilter', true, true)]
    local procedure DisplayFilter(var Rec: Record "NPR POS Menu Filter")
    var
        INS: InStream;
        NoFilterLbl: Label 'No filters set.';
        FilterStringText: Text;
    begin
        FilterStringText := NoFilterLbl;
        Rec.CalcFields("Table Filter");
        if Rec."Table Filter".HasValue then begin
            Rec."Table Filter".CreateInStream(INS);
            INS.Read(FilterStringText);
        end;
        Message(FilterStringText);
    end;

    procedure ReadKeyString(RecRef: RecordRef; KeyIndex: Integer) SortingKey: Text
    var
        FldRef: FieldRef;
        i: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(KeyIndex);
        for i := 1 to KeyRef.FieldCount do begin
            FldRef := KeyRef.FieldIndex(i);
            if SortingKey <> '' then
                SortingKey := SortingKey + ',' + FldRef.Name
            else
                SortingKey := FldRef.Name;
        end;
        exit(SortingKey);
    end;
}

