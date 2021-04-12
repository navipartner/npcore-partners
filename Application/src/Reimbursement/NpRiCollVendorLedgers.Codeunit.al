codeunit 6151103 "NPR NpRi Coll. Vendor Ledgers"
{
    var
        Text000: Label 'Vendor Ledger Entries (Invoice and Credit Memo)';
        Text001: Label 'Collecting Vendor Ledger Entries: @1@@@@@@@@@@@@@@@@@@';

    //Discover

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'DiscoverModules', '', true, true)]
    local procedure DiscoverVendorLedgers(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(VendorLedgerCode()) then
            exit;

        NpRiModule.Init();
        NpRiModule.Code := VendorLedgerCode();
        NpRiModule.Description := Text000;
        NpRiModule.Type := NpRiModule.Type::"Data Collection";
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure VendorLedgerCode(): Code[20]
    begin
        exit('VEND_LEDGERS');
    end;

    //Setup Filters

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'HasTemplateFilters', '', true, true)]
    procedure HasTemplateFilters(NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ."; var HasFilters: Boolean)
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> VendorLedgerCode() then
            exit;

        HasFilters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'SetupTemplateFilters', '', true, true)]
    procedure SetupTemplateFilters(var NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.")
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        TempField: Record "Field" temporary;
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> VendorLedgerCode() then
            exit;

        RecRef.GetTable(VendorLedgEntry);
        NpRiDataCollectionMgt.AddRequestField(RecRef, VendorLedgEntry.FieldNo("Posting Date"), TempField);

        NpRiDataCollectionMgt.RunRequestPage(NpRiReimbursementTemplate, RecRef, RecRef2, TempField);
    end;

    //Party Mgt.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'SetupPartyTypeTableNoLookup', '', true, true)]
    local procedure OnSetupPartyTypeTableNoLookup(var TempTableMetadata: Record "Table Metadata" temporary)
    var
        TableMetadata: Record "Table Metadata";
    begin
        if TempTableMetadata.Get(DATABASE::Vendor) then
            exit;

        TableMetadata.Get(DATABASE::Vendor);

        TempTableMetadata.Init();
        TempTableMetadata := TableMetadata;
        TempTableMetadata.Insert();
    end;

    //Data Collect
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'OnRunDataCollection', '', true, true)]
    local procedure OnRunDataCollection(var Sender: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var Handled: Boolean)
    begin
        if NpRiReimbursement."Data Collection Module" <> VendorLedgerCode() then
            exit;
        if Handled then
            exit;

        Handled := true;

        CollectVendLedgEntries(Sender, NpRiReimbursement);
    end;

    local procedure CollectVendLedgEntries(var NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement")
    var
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Counter: Integer;
        Total: Integer;
    begin
        if not FindVendLedgEntries(NpRiReimbursement, VendLedgEntry) then
            exit;

        Total := VendLedgEntry.Count();
        NpRiDataCollectionMgt.OpenWindow(Text001);

        VendLedgEntry.FindSet();
        repeat
            Counter += 1;
            NpRiDataCollectionMgt.UpdateWindow(1, Round((Counter / Total) * 10000, 1));

            if NpRiDataCollectionMgt.InsertEntry(NpRiReimbursement, VendLedgEntry."Purchase (LCY)", VendLedgEntry, NpRiReimbursementEntry) then
                UpdateEntry(VendLedgEntry, NpRiReimbursementEntry);
        until VendLedgEntry.Next() = 0;

        NpRiDataCollectionMgt.CloseWindow();
    end;

    local procedure FindVendLedgEntries(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var VendLedgEntry: Record "Vendor Ledger Entry"): Boolean
    var
        NpRiParty: Record "NPR NpRi Party";
        NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.";
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        TableView: Text;
        TableViewName: Text;
        DataCollectionDatefilter: Text;
    begin
        Clear(VendLedgEntry);

        if (NpRiReimbursement."Data Collection Company" <> '') and (NpRiReimbursement."Data Collection Company" <> CompanyName) then
            VendLedgEntry.ChangeCompany(NpRiReimbursement."Data Collection Company");

        TableViewName := NpRiDataCollectionMgt.GetTableViewName(VendLedgEntry);
        NpRiReimbursementTemplate.Get(NpRiReimbursement."Template Code");
        if NpRiDataCollectionMgt.GetTableView(TableViewName, NpRiReimbursementTemplate, TableView) then
            VendLedgEntry.SetView(TableView);

        VendLedgEntry.FilterGroup(40);
        VendLedgEntry.SetFilter("Document Type", '%1|%2', VendLedgEntry."Document Type"::Invoice, VendLedgEntry."Document Type"::"Credit Memo");
        VendLedgEntry.FilterGroup(41);
        VendLedgEntry.SetFilter("Entry No.", '>%1', NpRiReimbursement."Last Data Collect Entry No.");
        if NpRiReimbursement."From Date" <> 0D then
            DataCollectionDatefilter := Format(NpRiReimbursement."From Date") + '..';

        if NpRiReimbursement."To Date" <> 0D then begin
            if DataCollectionDatefilter <> '' then
                DataCollectionDatefilter := DataCollectionDatefilter + Format(NpRiReimbursement."To Date")
            else
                DataCollectionDatefilter := '..' + Format(NpRiReimbursement."To Date")

        end;
        if DataCollectionDatefilter <> '' then
            VendLedgEntry.SetFilter("Posting Date", DataCollectionDatefilter);

        if NpRiParty.Get(NpRiReimbursement."Party Type", NpRiReimbursement."Party No.") then begin
            NpRiParty.CalcFields("Table No.");
            if NpRiParty."Table No." = DATABASE::Vendor then begin
                VendLedgEntry.FilterGroup(42);
                VendLedgEntry.SetRange("Vendor No.", NpRiReimbursement."Party No.");
            end;
        end;
        VendLedgEntry.FilterGroup(0);

        exit(VendLedgEntry.FindFirst());
    end;

    local procedure UpdateEntry(VendLedgEntry: Record "Vendor Ledger Entry"; var NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntry."Document Type" := VendLedgEntry."Document Type";
        NpRiReimbursementEntry."Document No." := VendLedgEntry."Document No.";
        NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::Vendor;
        NpRiReimbursementEntry."Account No." := VendLedgEntry."Vendor No.";
        NpRiReimbursementEntry.Modify(true);
    end;
    //Aux
    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRi Coll. Vendor Ledgers");
    end;
}

