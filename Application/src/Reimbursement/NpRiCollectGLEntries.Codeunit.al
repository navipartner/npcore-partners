codeunit 6151109 "NPR NpRi Collect G/L Entries"
{
    var
        Text000: Label 'G/L Entries';
        Text001: Label 'Collecting G/L Entries: @1@@@@@@@@@@@@@@@@@@';

    //Discover

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'DiscoverModules', '', true, true)]
    local procedure DiscoverGLEntries(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(ModuleCode()) then
            exit;

        NpRiModule.Init();
        NpRiModule.Code := ModuleCode();
        NpRiModule.Description := Text000;
        NpRiModule.Type := NpRiModule.Type::"Data Collection";
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('GL_ENTRIES');
    end;

    //Setup Filters

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'HasTemplateFilters', '', true, true)]
    local procedure HasTemplateFilters(NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ."; var HasFilters: Boolean)
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> ModuleCode() then
            exit;

        HasFilters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'SetupTemplateFilters', '', true, true)]
    local procedure SetupTemplateFilters(var NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.")
    var
        GLEntry: Record "G/L Entry";
        TempField: Record "Field" temporary;
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> ModuleCode() then
            exit;

        RecRef.GetTable(GLEntry);
        NpRiDataCollectionMgt.AddRequestField(RecRef, GLEntry.FieldNo("G/L Account No."), TempField);
        NpRiDataCollectionMgt.AddRequestField(RecRef, GLEntry.FieldNo("Posting Date"), TempField);
        NpRiDataCollectionMgt.AddRequestField(RecRef, GLEntry.FieldNo("Document Type"), TempField);
        NpRiDataCollectionMgt.AddRequestField(RecRef, GLEntry.FieldNo("Credit Amount"), TempField);
        NpRiDataCollectionMgt.AddRequestField(RecRef, GLEntry.FieldNo("Debit Amount"), TempField);

        NpRiDataCollectionMgt.RunRequestPage(NpRiReimbursementTemplate, RecRef, RecRef2, TempField);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'SetupPartyTypeTableNoLookup', '', true, true)]
    local procedure OnSetupPartyTypeTableNoLookup(var TempTableMetadata: Record "Table Metadata" temporary)
    var
        TableMetadata: Record "Table Metadata";
    begin
        if not TempTableMetadata.Get(DATABASE::Customer) then begin
            TableMetadata.Get(DATABASE::Customer);

            TempTableMetadata.Init();
            TempTableMetadata := TableMetadata;
            TempTableMetadata.Insert();
        end;

        if not TempTableMetadata.Get(DATABASE::Vendor) then begin
            TableMetadata.Get(DATABASE::Customer);

            TempTableMetadata.Init();
            TempTableMetadata := TableMetadata;
            TempTableMetadata.Insert();
        end;
    end;

    //Data Collect

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'OnRunDataCollection', '', true, true)]
    local procedure OnRunDataCollection(var Sender: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var Handled: Boolean)
    begin
        if NpRiReimbursement."Data Collection Module" <> ModuleCode() then
            exit;
        if Handled then
            exit;

        Handled := true;

        CollectGLEntries(Sender, NpRiReimbursement);
    end;

    local procedure CollectGLEntries(var NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement")
    var
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
        GLEntry: Record "G/L Entry";
        Counter: Integer;
        Total: Integer;
    begin
        if not FindGLEntries(NpRiReimbursement, GLEntry) then
            exit;

        Total := GLEntry.Count();
        NpRiDataCollectionMgt.OpenWindow(Text001);

        GLEntry.FindSet();
        repeat
            Counter += 1;
            NpRiDataCollectionMgt.UpdateWindow(1, Round((Counter / Total) * 10000, 1));

            if NpRiDataCollectionMgt.InsertEntry(NpRiReimbursement, GLEntry.Amount, GLEntry, NpRiReimbursementEntry) then
                UpdateEntry(GLEntry, NpRiReimbursementEntry);
        until GLEntry.Next() = 0;

        NpRiDataCollectionMgt.CloseWindow();
    end;

    local procedure FindGLEntries(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var GLEntry: Record "G/L Entry"): Boolean
    var
        NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.";
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        TableView: Text;
        TableViewName: Text;
    begin
        Clear(GLEntry);

        if (NpRiReimbursement."Data Collection Company" <> '') and (NpRiReimbursement."Data Collection Company" <> CompanyName) then
            GLEntry.ChangeCompany(NpRiReimbursement."Data Collection Company");

        TableViewName := NpRiDataCollectionMgt.GetTableViewName(GLEntry);
        NpRiReimbursementTemplate.Get(NpRiReimbursement."Template Code");
        if NpRiDataCollectionMgt.GetTableView(TableViewName, NpRiReimbursementTemplate, TableView) then
            GLEntry.SetView(TableView);

        GLEntry.FilterGroup(40);
        GLEntry.SetFilter("Entry No.", '>%1', NpRiReimbursement."Last Data Collect Entry No.");
        GLEntry.FilterGroup(0);

        exit(GLEntry.FindFirst());
    end;

    local procedure UpdateEntry(GLEntry: Record "G/L Entry"; var NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntry."Document Type" := GLEntry."Document Type";
        NpRiReimbursementEntry."Document No." := GLEntry."Document No.";
        NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::"G/L Account";
        NpRiReimbursementEntry."Account No." := GLEntry."G/L Account No.";
        NpRiReimbursementEntry.Modify(true);
    end;

    //Aux

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRi Collect G/L Entries");
    end;
}

