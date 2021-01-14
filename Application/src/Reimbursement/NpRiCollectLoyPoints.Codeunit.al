codeunit 6151108 "NPR NpRi Collect Loy. Points"
{

    var
        Text000: Label 'Membership Point Entries';
        Text001: Label 'Collecting Point Entries: @1@@@@@@@@@@@@@@@@@@';

    //Discover

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'DiscoverModules', '', true, true)]
    local procedure DiscoverMemberLoyaltyPoints(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(MemberLoyaltyPointsCode()) then
            exit;

        NpRiModule.Init;
        NpRiModule.Code := MemberLoyaltyPointsCode();
        NpRiModule.Description := Text000;
        NpRiModule.Type := NpRiModule.Type::"Data Collection";
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure MemberLoyaltyPointsCode(): Code[20]
    begin
        exit('POINT_ENTRIES');
    end;

    //Setup Filters

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'HasTemplateFilters', '', true, true)]
    procedure HasTemplateFilters(NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ."; var HasFilters: Boolean)
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> MemberLoyaltyPointsCode() then
            exit;

        HasFilters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'SetupTemplateFilters', '', true, true)]
    procedure SetupTemplateFilters(var NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.")
    var
        MMMembershipPointsEntry: Record "NPR MM Members. Points Entry";
        TempField: Record "Field" temporary;
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> MemberLoyaltyPointsCode() then
            exit;

        RecRef.GetTable(MMMembershipPointsEntry);
        NpRiDataCollectionMgt.AddRequestField(RecRef, MMMembershipPointsEntry.FieldNo("Posting Date"), TempField);

        NpRiDataCollectionMgt.RunRequestPage(NpRiReimbursementTemplate, RecRef, RecRef2, TempField);
    end;

    //Party Mgt.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'SetupPartyTypeTableNoLookup', '', true, true)]
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

    //Data Collect
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Data Collection Mgt.", 'OnRunDataCollection', '', true, true)]
    local procedure OnRunDataCollection(var Sender: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var Handled: Boolean)
    begin
        if NpRiReimbursement."Data Collection Module" <> MemberLoyaltyPointsCode() then
            exit;
        if Handled then
            exit;

        Handled := true;

        CollectMemberLoyaltyPoints(Sender, NpRiReimbursement);
    end;

    local procedure CollectMemberLoyaltyPoints(var NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt."; var NpRiReimbursement: Record "NPR NpRi Reimbursement")
    var
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
        MMMembershipPointsEntry: Record "NPR MM Members. Points Entry";
        Counter: Integer;
        Total: Integer;
    begin
        if not FindMemberLoyaltyPoints(NpRiReimbursement, MMMembershipPointsEntry) then
            exit;

        Total := MMMembershipPointsEntry.Count;
        NpRiDataCollectionMgt.OpenWindow(Text001);

        MMMembershipPointsEntry.FindSet;
        repeat
            Counter += 1;
            NpRiDataCollectionMgt.UpdateWindow(1, Round((Counter / Total) * 10000, 1));

            if NpRiDataCollectionMgt.InsertEntry(NpRiReimbursement, MMMembershipPointsEntry.Points, MMMembershipPointsEntry, NpRiReimbursementEntry) then
                UpdateEntry(MMMembershipPointsEntry, NpRiReimbursementEntry);
        until MMMembershipPointsEntry.Next = 0;

        NpRiDataCollectionMgt.CloseWindow();
    end;

    local procedure FindMemberLoyaltyPoints(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var MMMembershipPointsEntry: Record "NPR MM Members. Points Entry"): Boolean
    var
        NpRiParty: Record "NPR NpRi Party";
        NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.";
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
        TableView: Text;
        TableViewName: Text;
    begin
        Clear(MMMembershipPointsEntry);

        if (NpRiReimbursement."Data Collection Company" <> '') and (NpRiReimbursement."Data Collection Company" <> CompanyName) then
            MMMembershipPointsEntry.ChangeCompany(NpRiReimbursement."Data Collection Company");

        TableViewName := NpRiDataCollectionMgt.GetTableViewName(MMMembershipPointsEntry);
        NpRiReimbursementTemplate.Get(NpRiReimbursement."Template Code");
        if NpRiDataCollectionMgt.GetTableView(TableViewName, NpRiReimbursementTemplate, TableView) then
            MMMembershipPointsEntry.SetView(TableView);

        exit(MMMembershipPointsEntry.FindFirst);
    end;

    local procedure UpdateEntry(MMMembershipPointsEntry: Record "NPR MM Members. Points Entry"; var NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntry."Document No." := MMMembershipPointsEntry."Document No.";
        NpRiReimbursementEntry."Document Type" := NpRiReimbursementEntry."Document Type"::" ";
        NpRiReimbursementEntry."Account No." := Format(MMMembershipPointsEntry."Membership Entry No.");
        NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::Membership;
        NpRiReimbursementEntry.Modify(true);
    end;

    //Aux
    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRi Collect Loy. Points");
    end;
}

