codeunit 6150749 "NPR POS Refresh Sale"
{
    Access = internal;
    EventSubscriberInstance = Manual;

    var
        _rows: Dictionary of [Text, Text]; //Rec.SystemId, SerializedRowJsonObject
        _rowsNewInsert: Dictionary of [Text, Boolean]; //Rec.SystemId, InsertedInThisStack
        UseLanguageAgnosticDataKeysFeatureTok: Label 'useLanguageAgnosticDataKeys', Locked = true;

    procedure GetDeltaData() Data: JsonObject
    var
        RowArray: JsonArray;
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        EmptyObject: JsonObject;
        RowObjectText: Text;
        RowObject: JsonObject;
        POSDataManagement: Codeunit "NPR POS Data Management";
        TempSale: Record "NPR POS Sale" temporary;
        POSSetup: Codeunit "NPR POS Setup";
        POSSaleRec: Record "NPR POS Sale";
        UseLanguageAgnosticDataKeys, PositionWithNames : Boolean;
        FeatureFlag: Codeunit "NPR Feature Flags Management";
    begin
        //TODO: Fix frontend to support keyed SystemId objects instead of keyless array, so we can delete the restructuring below.
        //TODO: Fix frontend to support leaving out the legacy fields from the refresh JSON.
        //TODO: Add support in frontend for delta totals so we do not need to re-loop all lines on every refresh just for fresh totals

        Data.Add('Content', EmptyObject);
        Data.Add('isDelta', true);
        Data.Add('dataSource', POSDataManagement.POSDataSource_BuiltInSale());

        foreach RowObjectText in _rows.Values do begin
            RowObject.ReadFrom(RowObjectText);
            RowArray.Add(RowObject);
        end;
        Data.Add('rows', RowArray);
        Data.Add('totals', EmptyObject);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);

        UseLanguageAgnosticDataKeys := FeatureFlag.IsEnabled(UseLanguageAgnosticDataKeysFeatureTok);
        PositionWithNames := (not UseLanguageAgnosticDataKeys);

        if POSSaleRec."Register No." <> '' then begin
            Data.Add('currentPosition', POSSaleRec.GetPosition(PositionWithNames));
        end else begin
            //For backwards compatibility reasons we support refreshing the POS sale record even if no sale is currently active.
            //This is because values like LastSaleTotals are implemented via data extensions on BUILTIN_SALE and are shown on the login screen even when no new sale is started yet.
            POSSession.GetSetup(POSSetup);
            TempSale."Register No." := POSSetup.GetPOSUnitNo();
            TempSale.Date := Today();
            TempSale.Insert();
            Data.Add('currentPosition', TempSale.GetPosition(PositionWithNames));
        end;

        exit(Data);
    end;

    procedure GetFullDataInCurrentSale(): JsonObject
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSSaleRec: Record "NPR POS Sale";
        FullData: JsonObject;
        TempSale: Record "NPR POS Sale" temporary;
        POSSetup: Codeunit "NPR POS Setup";
    begin
        Clear(_rows);
        Clear(_rowsNewInsert);

        if not POSSession.IsInitialized() then
            exit;

        POSSession.GetSetup(POSSetup);
        POSSaleRec."Register No." := POSSetup.GetxPOSUnitNo();
        if (POSSaleRec."Register No." <> POSSetup.GetPOSUnitNo()) and (POSSaleRec."Register No." <> '') then begin
            POSSaleRec.SystemId := CreateGuid();
            Delete(POSSaleRec);
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);

        if POSSaleRec."Register No." <> '' then begin
            Insert(POSSaleRec);
        end else begin
            //For backwards compatibility reasons we support refreshing the POS sale record even if no sale is currently active.
            //This is because values like LastSaleTotals are implemented via data extensions on BUILTIN_SALE and are shown on the login screen even when no new sale is started yet.
            TempSale."Register No." := POSSetup.GetPOSUnitNo();
            TempSale.Date := Today();
            TempSale.Insert();
            Insert(TempSale);
        end;

        FullData := GetDeltaData();

        exit(FullData);
    end;

    local procedure Insert(var Rec: record "NPR POS Sale")
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

    local procedure Delete(var Rec: Record "NPR POS Sale")
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

    local procedure Modify(var Rec: Record "NPR POS Sale")
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

    local procedure Rename(var Rec: Record "NPR POS Sale"; var xRec: Record "NPR POS Sale")
    begin
        Delete(xRec);
        Insert(Rec);
    end;

    local procedure CreateRow(var Rec: Record "NPR POS Sale"; SkipContent: Boolean) RowObject: JsonObject
    var
        FieldsObject: JsonObject;
        POSSession: Codeunit "NPR POS Session";
        Sale: Codeunit "NPR POS Sale";
        LastSaleTotal: Decimal;
        LastSalePayment: Decimal;
        LastSaleDateText: Text;
        LastSaleReturnAmount: Decimal;
        LastReceiptNo: Text;
        SalePOS: Record "NPR POS Sale";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        Contact: Record Contact;
        POSUnit: Record "NPR POS Unit";
        ContactBusinessRelation: Record "Contact Business Relation";
        POSDataManagement: Codeunit "NPR POS Data Management";
        Extensions: List of [Text];
        Extension: Text;
        RecRef: RecordRef;
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        DataRow: Codeunit "NPR Data Row";
        ExtensionKeys: List of [Text];
        ExtensionKey: Text;
        Handled: Boolean;
        MissingSubscriberErr: Label 'Extension "%1" for data source "%2" did not respond to %3 event.';
        DataRowLbl: Label '%1.%2', Locked = true;
        UseLanguageAgnosticDataKeys, PositionWithNames : Boolean;
        FeatureFlag: Codeunit "NPR Feature Flags Management";
    begin
        UseLanguageAgnosticDataKeys := FeatureFlag.IsEnabled(UseLanguageAgnosticDataKeysFeatureTok);
        PositionWithNames := (not UseLanguageAgnosticDataKeys);

        if not SkipContent then begin
            FieldsObject.Add(Format(Rec.FieldNo("Register No.")), Rec."Register No.");
            FieldsObject.Add(Format(Rec.FieldNo("Sales Ticket No.")), Rec."Sales Ticket No.");
            FieldsObject.Add(Format(Rec.FieldNo("Salesperson Code")), Rec."Salesperson Code");
            FieldsObject.Add(Format(Rec.FieldNo("Customer No.")), Rec."Customer No.");
            FieldsObject.Add(Format(Rec.FieldNo(Name)), Rec.Name);
            FieldsObject.Add(Format(Rec.FieldNo(Date)), Rec.Date);
            FieldsObject.Add(Format(Rec.FieldNo("Contact No.")), Rec."Contact No.");
            FieldsObject.Add(Format(Rec.FieldNo("Customer Price Group")), Rec."Customer Price Group");
            FieldsObject.Add(Format(Rec.FieldNo("Customer Disc. Group")), Rec."Customer Disc. Group");

            POSSession.GetSale(Sale);
            Sale.GetLastSaleInfo(LastSaleTotal, LastSalePayment, LastSaleDateText, LastSaleReturnAmount, LastReceiptNo);

            FieldsObject.Add('LastSaleNo', LastReceiptNo);
            FieldsObject.Add('LastSaleTotal', LastSaleTotal);
            FieldsObject.Add('LastSalePaid', LastSalePayment);
            FieldsObject.Add('LastSaleChange', LastSaleReturnAmount);
            FieldsObject.Add('LastSaleDate', LastSaleDateText);
            FieldsObject.Add('CompanyName', GetCompanyDisplayName());

            Sale.GetCurrentSale(SalePOS);

            SalespersonPurchaser.SetLoadFields(Name);
            if not SalespersonPurchaser.Get(SalePOS."Salesperson Code") then
                Clear(SalespersonPurchaser);

            POSUnit.SetLoadFields(Name);
            if not POSUnit.Get(SalePOS."Register No.") then
                clear(POSUnit);

            if SalePOS."Customer No." <> '' then begin
                Customer.SetLoadFields(Name, "Customer Posting Group");
                if not Customer.Get(SalePOS."Customer No.") then
                    Clear(Customer);
            end;

            if SalePOS."Contact No." <> '' then begin
                Contact.SetLoadFields(Name);
                if not Contact.Get(SalePOS."Contact No.") then
                    if Customer."No." <> '' then begin
                        ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("No.", Customer."No.");
                        if ContactBusinessRelation.FindFirst() then
                            if Contact.Get(ContactBusinessRelation."Contact No.") then;
                    end;
            end;

            FieldsObject.Add('SalespersonName', SalespersonPurchaser.Name);
            FieldsObject.Add('RegisterName', POSUnit.Name);
            FieldsObject.Add('CustomerName', Customer.Name);
            FieldsObject.Add('CustomerPostingGroup', Customer."Customer Posting Group");
            FieldsObject.Add('ContactName', Contact.Name);

            POSSession.GetFrontEnd(POSFrontEnd, true);
            POSDataManagement.OnDiscoverDataSourceExtensions(POSDataManagement.POSDataSource_BuiltInSale(), Extensions);
            foreach Extension in Extensions do begin
                Clear(DataRow);
                DataRow.Constructor(Rec.GetPosition(false));
                RecRef.GetTable(Rec);
                POSDataManagement.OnDataSourceExtensionReadData(POSDataManagement.POSDataSource_BuiltInSale(), Extension, RecRef, DataRow, POSSession, POSFrontEnd, Handled);
                if not Handled then
                    POSFrontEnd.ReportBugAndThrowError(StrSubstNo(MissingSubscriberErr, Extension, POSDataManagement.POSDataSource_BuiltInSale(), 'OnDataSourceExtensionReadData'));

                ExtensionKeys := DataRow.Fields().Keys();
                foreach ExtensionKey in ExtensionKeys do
                    FieldsObject.Add(StrSubstNo(DataRowLbl, Extension, ExtensionKey), DataRow.Field(ExtensionKey));

                RecRef.Close();
            end;
        end;

        RowObject.Add('position', Rec.GetPosition(PositionWithNames));
        RowObject.Add('negative', false);
        RowObject.Add('class', '');
        RowObject.Add('style', '');
        RowObject.Add('fields', FieldsObject);
    end;

    local procedure GetCompanyDisplayName(): Text
    var
        Company: Record Company;
    begin
        if Company.Get(CompanyName()) and (Company."Display Name" <> '') then
            exit(Company."Display Name");
        exit(CompanyName());
    end;
    #region POS Table Subscribers

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterInsertEvent', '', false, false)]
    local procedure POSSaleOnAfterInsert(var Rec: Record "NPR POS Sale")
    begin
        if Rec.IsTemporary then
            exit;

        Insert(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterDeleteEvent', '', false, false)]
    local procedure POSSaleOnAfterDelete(var Rec: Record "NPR POS Sale")
    begin
        if Rec.IsTemporary then
            exit;

        Delete(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterModifyEvent', '', false, false)]
    local procedure POSSaleOnAfterModify(var Rec: Record "NPR POS Sale")
    begin
        if Rec.IsTemporary then
            exit;

        Modify(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterRenameEvent', '', false, false)]
    local procedure POSSaleOnAfterRename(var Rec: Record "NPR POS Sale"; var xRec: Record "NPR POS Sale")
    begin
        if Rec.IsTemporary then
            exit;

        Rename(Rec, xRec);
    end;
    #endregion
}