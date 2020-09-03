codeunit 6014637 "NPR Generic Filter Page Mgt."
{
    // NPR5.45/TJ  /20180719 CASE 318531 New object
    // NPR5.48/TJ  /20181129 CASE 318531 Recoded and additional features added
    // NPR5.53/TJ  /20190626 CASE 349301 Function AdvancedFilter changed to be global


    trigger OnRun()
    begin
    end;

    procedure AdvancedFilter(RecRef: RecordRef; var FilterStringText: Text) FilterPageOK: Boolean
    var
        FilterBuilder: FilterPageBuilder;
        FilterViewName: Text;
        GenericFilterPage: Page "NPR Generic Filter Page";
        FieldTable: Record "Field";
        FldRef: FieldRef;
        i: Integer;
    begin
        //-NPR5.48 [318531]
        GenericFilterPage.SetRawFilter(FilterStringText);
        //+NPR5.48 [318531]
        GenericFilterPage.SetRecRef(RecRef);
        GenericFilterPage.LookupMode := true;
        FilterPageOK := GenericFilterPage.RunModal = ACTION::LookupOK;
        //-NPR5.48 [318531]
        /*
        IF FilterPageOK THEN BEGIN
          GenericFilterPage.GetRecRef(RecRef);
          FilterStringText := RecRef.GETVIEW;
        END;
        */
        if FilterPageOK then
            FilterStringText := GenericFilterPage.ReturnRawFilter();
        //+NPR5.48 [318531]

    end;

    [EventSubscriber(ObjectType::Page, 6014432, 'OnAfterActionEvent', 'AdvancedFilter', true, true)]
    local procedure AuditRollAdvancedFilter(var Rec: Record "NPR Audit Roll")
    var
        FilterStringText: Text;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        if AdvancedFilter(RecRef, FilterStringText) then
            Rec.SetView(FilterStringText);
    end;

    [EventSubscriber(ObjectType::Page, 6150718, 'OnAfterActionEvent', 'GenericFilter', true, true)]
    local procedure POSMenuFilterGenericFilter(var Rec: Record "NPR POS Menu Filter")
    var
        RecRef: RecordRef;
        FilterStringText: Text;
        INS: InStream;
        OUTS: OutStream;
    begin
        //-NPR5.48 [318531]
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
        //+NPR5.48 [318531]
    end;

    [EventSubscriber(ObjectType::Page, 6150718, 'OnAfterActionEvent', 'DisplayFilter', true, true)]
    local procedure DisplayFilter(var Rec: Record "NPR POS Menu Filter")
    var
        FilterStringText: Text;
        INS: InStream;
        NoFilterText: Label 'No filters set.';
    begin
        //-NPR5.48 [318531]
        FilterStringText := NoFilterText;
        Rec.CalcFields("Table Filter");
        if Rec."Table Filter".HasValue then begin
            Rec."Table Filter".CreateInStream(INS);
            INS.Read(FilterStringText);
        end;
        Message(FilterStringText);
        //+NPR5.48 [318531]
    end;

    procedure ReadKeyString(RecRef: RecordRef; KeyIndex: Integer) SortingKey: Text
    var
        KeyRef: KeyRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        //-NPR5.48 [318531]
        KeyRef := RecRef.KeyIndex(KeyIndex);
        for i := 1 to KeyRef.FieldCount do begin
            FldRef := KeyRef.FieldIndex(i);
            if SortingKey <> '' then
                SortingKey := SortingKey + ',' + FldRef.Name
            else
                SortingKey := FldRef.Name;
        end;
        exit(SortingKey);
        //+NPR5.48 [318531]
    end;
}

