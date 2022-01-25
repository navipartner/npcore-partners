codeunit 6059775 "NPR Generic Filter Page Mgt."
{
    procedure AdvancedFilter(RecRef: RecordRef;var FilterStringText: Text) FilterPageOK: Boolean
    var
        GenericFilterPage: Page "NPR Generic Filter Page";
    begin
        GenericFilterPage.SetRawFilter(FilterStringText);
        GenericFilterPage.SetRecRef(RecRef);
        GenericFilterPage.LookupMode := true;
        FilterPageOK := GenericFilterPage.RunModal() = Action::LookupOK;
        if FilterPageOK then
          FilterStringText := GenericFilterPage.ReturnRawFilter();

    end;

    procedure GenericFilter(var POSMenuFilter: Record "NPR POS Menu Filter")
    var
        RecRef: RecordRef;
        FilterStringText: Text;
        INS: InStream;
        OUTS: OutStream;
    begin
        POSMenuFilter.TestField("Table No.");
        RecRef.Open(POSMenuFilter."Table No.");

        POSMenuFilter.CalcFields("Table Filter");
        if POSMenuFilter."Table Filter".HasValue() then begin
          POSMenuFilter."Table Filter".CreateInStream(INS);
          INS.Read(FilterStringText);
        end;

        if AdvancedFilter(RecRef,FilterStringText) then begin
          POSMenuFilter."Table Filter".CreateOutStream(OUTS);
          OUTS.Write(FilterStringText);
          POSMenuFilter.Modify();
        end;

        RecRef.Close();
    end;

    procedure DisplayFilter(var POSMenuFilter: Record "NPR POS Menu Filter")
    var
        FilterStringText: Text;
        INS: InStream;
        NoFilterText: Label 'No filters set.';
    begin
        FilterStringText := NoFilterText;
        POSMenuFilter.CalcFields("Table Filter");
        if POSMenuFilter."Table Filter".HasValue() then begin
          POSMenuFilter."Table Filter".CreateInStream(INS);
          INS.Read(FilterStringText);
        end;
        Message(FilterStringText);
    end;

    procedure ReadKeyString(RecRef: RecordRef;KeyIndex: Integer) SortingKey: Text
    var
        KeyRef: KeyRef;
        FldRef: FieldRef;
        i: Integer;
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

