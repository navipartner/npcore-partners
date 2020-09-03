codeunit 6151104 "NPR NpRi Collect Cust. Ledgers"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.54/BHR /20200306  CASE 385924 Added date filter


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Customer Ledger Entries (Invoice and Credit Memo)';
        Text001: Label 'Collecting Customer Ledger Entries: @1@@@@@@@@@@@@@@@@@@';

    local procedure "--- Discover"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151100, 'DiscoverModules', '', true, true)]
    local procedure DiscoverCustomerLedgers(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(CustomerLedgerCode()) then
            exit;

        NpRiModule.Init;
        NpRiModule.Code := CustomerLedgerCode();
        NpRiModule.Description := Text000;
        NpRiModule.Type := NpRiModule.Type::"Data Collection";
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure CustomerLedgerCode(): Code[20]
    begin
        exit('CUST_LEDGERS');
    end;

    local procedure "--- Setup Filters"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151101, 'HasTemplateFilters', '', true, true)]
    procedure HasTemplateFilters(NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ."; var HasFilters: Boolean)
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> CustomerLedgerCode() then
            exit;

        HasFilters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151101, 'SetupTemplateFilters', '', true, true)]
    procedure SetupTemplateFilters(var NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        TempField: Record "Field" temporary;
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> CustomerLedgerCode() then
            exit;

        RecRef.GetTable(CustLedgEntry);
        NpRiDataCollectionMgt.AddRequestField(RecRef, CustLedgEntry.FieldNo("Posting Date"), TempField);

        NpRiDataCollectionMgt.RunRequestPage(NpRiReimbursementTemplate, RecRef, RecRef2, TempField);
    end;

    local procedure "--- Party Mgt."()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151100, 'SetupPartyTypeTableNoLookup', '', true, true)]
    local procedure OnSetupPartyTypeTableNoLookup(var TempTableMetadata: Record "Table Metadata" temporary)
    var
        TableMetadata: Record "Table Metadata";
    begin
        if TempTableMetadata.Get(DATABASE::Customer) then
            exit;

        TableMetadata.Get(DATABASE::Customer);

        TempTableMetadata.Init;
        TempTableMetadata := TableMetadata;
        TempTableMetadata.Insert;
    end;

    local procedure "--- Data Collect"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151101, 'OnRunDataCollection', '', true, true)]
    local procedure OnRunDataCollection(var Sender: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var Handled: Boolean)
    begin
        if NpRiReimbursement."Data Collection Module" <> CustomerLedgerCode() then
            exit;
        if Handled then
            exit;

        Handled := true;

        CollectCustLedgEntries(Sender, NpRiReimbursement);
    end;

    local procedure CollectCustLedgEntries(var NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement")
    var
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Counter: Integer;
        Total: Integer;
    begin
        if not FindCustLedgEntries(NpRiReimbursement, CustLedgEntry) then
            exit;

        Total := CustLedgEntry.Count;
        NpRiDataCollectionMgt.OpenWindow(Text001);

        CustLedgEntry.FindSet;
        repeat
            Counter += 1;
            NpRiDataCollectionMgt.UpdateWindow(1, Round((Counter / Total) * 10000, 1));

            if NpRiDataCollectionMgt.InsertEntry(NpRiReimbursement, CustLedgEntry."Sales (LCY)", CustLedgEntry, NpRiReimbursementEntry) then
                UpdateEntry(CustLedgEntry, NpRiReimbursementEntry);
        until CustLedgEntry.Next = 0;

        NpRiDataCollectionMgt.CloseWindow();
    end;

    local procedure FindCustLedgEntries(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    var
        NpRiParty: Record "NPR NpRi Party";
        NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.";
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        TableView: Text;
        TableViewName: Text;
        DataCollectionDatefilter: Text;
    begin
        Clear(CustLedgEntry);

        if (NpRiReimbursement."Data Collection Company" <> '') and (NpRiReimbursement."Data Collection Company" <> CompanyName) then
            CustLedgEntry.ChangeCompany(NpRiReimbursement."Data Collection Company");

        TableViewName := NpRiDataCollectionMgt.GetTableViewName(CustLedgEntry);
        NpRiReimbursementTemplate.Get(NpRiReimbursement."Template Code");
        if NpRiDataCollectionMgt.GetTableView(TableViewName, NpRiReimbursementTemplate, TableView) then
            CustLedgEntry.SetView(TableView);

        CustLedgEntry.FilterGroup(40);
        CustLedgEntry.SetFilter("Document Type", '%1|%2', CustLedgEntry."Document Type"::Invoice, CustLedgEntry."Document Type"::"Credit Memo");
        CustLedgEntry.FilterGroup(41);
        CustLedgEntry.SetFilter("Entry No.", '>%1', NpRiReimbursement."Last Data Collect Entry No.");
        //-NPR5.54 [385924]
        if NpRiReimbursement."From Date" <> 0D then
            DataCollectionDatefilter := Format(NpRiReimbursement."From Date") + '..';

        if NpRiReimbursement."To Date" <> 0D then begin
            if DataCollectionDatefilter <> '' then
                DataCollectionDatefilter := DataCollectionDatefilter + Format(NpRiReimbursement."To Date")
            else
                DataCollectionDatefilter := '..' + Format(NpRiReimbursement."To Date")

        end;
        if DataCollectionDatefilter <> '' then
            CustLedgEntry.SetFilter("Posting Date", DataCollectionDatefilter);

        //+NPR5.54 [385924]
        if NpRiParty.Get(NpRiReimbursement."Party Type", NpRiReimbursement."Party No.") then begin
            NpRiParty.CalcFields("Table No.");
            if NpRiParty."Table No." = DATABASE::Customer then begin
                CustLedgEntry.FilterGroup(42);
                CustLedgEntry.SetRange("Customer No.", NpRiReimbursement."Party No.");
            end;
        end;
        CustLedgEntry.FilterGroup(0);

        exit(CustLedgEntry.FindFirst);
    end;

    local procedure UpdateEntry(CustLedgEntry: Record "Cust. Ledger Entry"; var NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntry."Document Type" := CustLedgEntry."Document Type";
        NpRiReimbursementEntry."Document No." := CustLedgEntry."Document No.";
        NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::Customer;
        NpRiReimbursementEntry."Account No." := CustLedgEntry."Customer No.";
        NpRiReimbursementEntry.Modify(true);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRi Collect Cust. Ledgers");
    end;
}

