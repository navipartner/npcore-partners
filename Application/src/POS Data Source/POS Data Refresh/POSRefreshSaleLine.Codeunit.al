codeunit 6150693 "NPR POS Refresh Sale Line"
{

    Access = internal;
    EventSubscriberInstance = Manual;

    var
        _rows: Dictionary of [Text, Text]; //Rec.SystemId, SerializedRowJsonObject
        _rowsNewInsert: Dictionary of [Text, Boolean]; //Rec.SystemId, InsertedInThisStack

    procedure GetDeltaData() Data: JsonObject
    var
        RowArray: JsonArray;
        TotalsObject: JsonObject;
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
        ItemCount: Decimal;
        EmptyObject: JsonObject;
        RowObjectText: Text;
        RowObject: JsonObject;
        POSDataManagement: Codeunit "NPR POS Data Management";
    begin
        //TODO: Fix frontend to support keyed SystemId objects instead of keyless array, so we can delete the restructuring below.
        //TODO: Fix frontend to support leaving out the legacy fields from the refresh JSON.
        //TODO: Add support in frontend for delta totals so we do not need to re-loop all lines on every refresh just for fresh totals

        Data.Add('Content', EmptyObject);
        Data.Add('isDelta', true);
        Data.Add('dataSource', POSDataManagement.POSDataSource_BuiltInSaleLine());

        foreach RowObjectText in _rows.Values do begin
            RowObject.ReadFrom(RowObjectText);
            RowArray.Add(RowObject);
        end;
        Data.Add('rows', RowArray);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, TotalAmount, ItemCount);
        TotalsObject.Add('AmountExclVAT', AmountExclVAT);
        TotalsObject.Add('VATAmount', VATAmount);
        TotalsObject.Add('TotalAmount', TotalAmount);
        TotalsObject.Add('ItemCount', ItemCount);
        Data.Add('totals', TotalsObject);
        Data.Add('currentPosition', POSSaleLine.GetPosition(true));

        exit(Data);
    end;

    procedure GetFullDataInCurrentSale(): JsonObject
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSSaleRec: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        FullData: JsonObject;
    begin
        Clear(_rows);
        Clear(_rowsNewInsert);

        if not POSSession.IsInitialized() then
            exit;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);

        if (POSSaleRec."Sales Ticket No." <> '') and (POSSaleRec."Register No." <> '') then begin
            POSSaleLine.SetRange("Register No.", POSSaleRec."Register No.");
            POSSaleLine.SetRange("Sales Ticket No.", POSSaleRec."Sales Ticket No.");
            if POSSaleLine.FindSet() then
                repeat
                    POSSaleLineOnAfterInsert(POSSaleLine);
                until POSSaleLine.Next() = 0;
        end;

        FullData := GetDeltaData();

        exit(FullData);
    end;

    local procedure Insert(var Rec: record "NPR POS Sale Line")
    var
        RowObject: JsonObject;
        RowObjectText: Text;
    begin
        RowObject := CreateRow(Rec, false);
        RowObject.Add('deleted', false);
        RowObject.WriteTo(RowObjectText);
        _rowsNewInsert.Set(Format(Rec.SystemId), true);
        _rows.Set(Format(Rec.SystemId), RowObjectText);
    end;

    local procedure Delete(var Rec: Record "NPR POS Sale Line")
    var
        RowObject: JsonObject;
        RowObjectText: Text;
        NewInsert: Boolean;
    begin
        if _rows.Get(Format(Rec.SystemId), RowObjectText) then begin
            if _rowsNewInsert.Get(Format(Rec.Systemid), NewInsert) then begin
                if NewInsert then begin
                    _rows.Remove(Format(Rec.SystemId));
                    _rowsNewInsert.Remove(Format(Rec.SystemId));
                    exit;
                end;
            end;

            _rows.Remove(Format(Rec.SystemId));
        end;

        RowObject := CreateRow(Rec, true);
        RowObject.Add('deleted', true);
        RowObject.WriteTo(RowObjectText);
        _rows.Add(Format(Rec.SystemId), RowObjectText);
    end;

    local procedure Modify(var Rec: Record "NPR POS Sale Line")
    var
        RowObject: JsonObject;
        RowObjectText: Text;
    begin
        if _rows.Remove(Format(Rec.SystemId)) then;

        RowObject := CreateRow(Rec, false);
        RowObject.Add('deleted', false);
        RowObject.WriteTo(RowObjectText);

        _rows.Set(Format(Rec.SystemId), RowObjectText);
    end;

    local procedure Rename(var Rec: Record "NPR POS Sale Line"; var xRec: Record "NPR POS Sale Line")
    begin
        Delete(xRec);
        Insert(Rec);
    end;

    local procedure CreateRow(var Rec: Record "NPR POS Sale Line"; SkipContent: Boolean) RowObject: JsonObject
    var
        FieldsObject: JsonObject;
        POSDataManagement: Codeunit "NPR POS Data Management";
        Extensions: List of [Text];
        Extension: Text;
        RecRef: RecordRef;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        DataRow: Codeunit "NPR Data Row";
        ExtensionKeys: List of [Text];
        ExtensionKey: Text;
        Handled: Boolean;
        MissingSubscriberErr: Label 'Extension "%1" for data source "%2" did not respond to %3 event.';
        DataRowLbl: Label '%1.%2', Locked = true;
    begin
        if not SkipContent then begin
            FieldsObject.Add(Format(Rec.FieldNo("No.")), Rec."No.");
            FieldsObject.Add(Format(Rec.FieldNo("Line Type")), Rec."Line Type".AsInteger());
            FieldsObject.Add(Format(Rec.FieldNo(Description)), Rec.Description);
            FieldsObject.Add(Format(Rec.FieldNo("Description 2")), Rec."Description 2");
            FieldsObject.Add(Format(Rec.FieldNo("Variant Code")), Rec."Variant Code");
            FieldsObject.Add(Format(Rec.FieldNo(Quantity)), Rec.Quantity);
            FieldsObject.Add(Format(Rec.FieldNo("Unit of Measure Code")), Rec."Unit of Measure Code");
            FieldsObject.Add(Format(Rec.FieldNo("Unit Price")), Rec."Unit Price");
            FieldsObject.Add(Format(Rec.FieldNo("Unit Cost")), Rec."Unit Cost");
            FieldsObject.Add(Format(Rec.FieldNo("Discount %")), Rec."Discount %");
            FieldsObject.Add(Format(Rec.FieldNo("Discount Amount")), Rec."Discount Amount");
            FieldsObject.Add(Format(Rec.FieldNo(Amount)), Rec.Amount);
            FieldsObject.Add(Format(Rec.FieldNo("Amount Including VAT")), Rec."Amount Including VAT");
            FieldsObject.Add(Format(Rec.FieldNo("Location Code")), Rec."Location Code");
            FieldsObject.Add(Format(Rec.FieldNo("Bin Code")), Rec."Bin Code");
            FieldsObject.Add(Format(Rec.FieldNo("Serial No.")), Rec."Serial No.");

            POSSession.GetFrontEnd(POSFrontEnd, true);
            POSDataManagement.OnDiscoverDataSourceExtensions(POSDataManagement.POSDataSource_BuiltInSaleLine(), Extensions);
            foreach Extension in Extensions do begin
                Clear(DataRow);
                DataRow.Constructor(Rec.GetPosition(false));
                RecRef.GetTable(Rec);
                POSDataManagement.OnDataSourceExtensionReadData(POSDataManagement.POSDataSource_BuiltInSaleLine(), Extension, RecRef, DataRow, POSSession, POSFrontEnd, Handled);
                if not Handled then
                    POSFrontEnd.ReportBugAndThrowError(StrSubstNo(MissingSubscriberErr, Extension, POSDataManagement.POSDataSource_BuiltInSaleLine(), 'OnDataSourceExtensionReadData'));

                ExtensionKeys := DataRow.Fields().Keys();
                foreach ExtensionKey in ExtensionKeys do
                    FieldsObject.Add(StrSubstNo(DataRowLbl, Extension, ExtensionKey), DataRow.Field(ExtensionKey));

                RecRef.Close();
            end;
        end;

        RowObject.Add('position', Rec.GetPosition(true));
        RowObject.Add('negative', Rec.Quantity < 0);
        RowObject.Add('class', '');
        RowObject.Add('style', '');
        RowObject.Add('fields', FieldsObject);
    end;

    #region POS Table Subscribers
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure POSSaleLineOnAfterInsert(var Rec: Record "NPR POS Sale Line")
    begin
        if Rec.IsTemporary then
            exit;
        if (Rec."Line Type" = Rec."Line Type"::"POS Payment") then
            exit;

        Insert(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure POSSaleLineOnAfterDelete(var Rec: Record "NPR POS Sale Line")
    begin
        if Rec.IsTemporary then
            exit;
        if (Rec."Line Type" = Rec."Line Type"::"POS Payment") then
            exit;

        Delete(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure POSSaleLineOnAfterModify(var Rec: Record "NPR POS Sale Line")
    begin
        if Rec.IsTemporary then
            exit;
        if (Rec."Line Type" = Rec."Line Type"::"POS Payment") then
            exit;

        Modify(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterRenameEvent', '', false, false)]
    local procedure POSSaleLineOnAfterRename(var Rec: Record "NPR POS Sale Line"; var xRec: Record "NPR POS Sale Line")
    begin
        if Rec.IsTemporary then
            exit;
        if (Rec."Line Type" = Rec."Line Type"::"POS Payment") then
            exit;

        Rename(Rec, xRec);
    end;
    #endregion
}