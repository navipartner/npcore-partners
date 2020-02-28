codeunit 6151108 "NpRi Collect Loyalty Points"
{
    // NPR5.53/TSA /20191024 CASE 374363 Initial Version


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Membership Point Entries';
        Text001: Label 'Collecting Point Entries: @1@@@@@@@@@@@@@@@@@@';

    local procedure "--- Discover"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151100, 'DiscoverModules', '', true, true)]
    local procedure DiscoverMemberLoyaltyPoints(var NpRiModule: Record "NpRi Reimbursement Module")
    begin
        if NpRiModule.Get (MemberLoyaltyPointsCode()) then
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

    local procedure "--- Setup Filters"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151101, 'HasTemplateFilters', '', true, true)]
    procedure HasTemplateFilters(NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var HasFilters: Boolean)
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> MemberLoyaltyPointsCode() then
          exit;

        HasFilters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151101, 'SetupTemplateFilters', '', true, true)]
    procedure SetupTemplateFilters(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template")
    var
        MMMembershipPointsEntry: Record "MM Membership Points Entry";
        TempField: Record "Field" temporary;
        NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";
        RecRef: RecordRef;
        RecRef2: RecordRef;
    begin
        if NpRiReimbursementTemplate."Data Collection Module" <> MemberLoyaltyPointsCode() then
          exit;

        RecRef.GetTable(MMMembershipPointsEntry);
        NpRiDataCollectionMgt.AddRequestField(RecRef,MMMembershipPointsEntry.FieldNo("Posting Date"),TempField);

        NpRiDataCollectionMgt.RunRequestPage(NpRiReimbursementTemplate,RecRef,RecRef2,TempField);
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
    local procedure OnRunDataCollection(var Sender: Codeunit "NpRi Data Collection Mgt.";var NpRiReimbursement: Record "NpRi Reimbursement";var Handled: Boolean)
    begin
        if NpRiReimbursement."Data Collection Module" <> MemberLoyaltyPointsCode() then
          exit;
        if Handled then
          exit;

        Handled := true;

        CollectMemberLoyaltyPoints(Sender,NpRiReimbursement);
    end;

    local procedure CollectMemberLoyaltyPoints(var NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";var NpRiReimbursement: Record "NpRi Reimbursement")
    var
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
        MMMembershipPointsEntry: Record "MM Membership Points Entry";
        Counter: Integer;
        Total: Integer;
    begin
        if not FindMemberLoyaltyPoints(NpRiReimbursement,MMMembershipPointsEntry) then
          exit;

        Total := MMMembershipPointsEntry.Count;
        NpRiDataCollectionMgt.OpenWindow(Text001);

        MMMembershipPointsEntry.FindSet;
        repeat
          Counter += 1;
          NpRiDataCollectionMgt.UpdateWindow(1,Round((Counter / Total) * 10000,1));

          if NpRiDataCollectionMgt.InsertEntry(NpRiReimbursement,MMMembershipPointsEntry.Points,MMMembershipPointsEntry,NpRiReimbursementEntry) then
            UpdateEntry(MMMembershipPointsEntry,NpRiReimbursementEntry);
        until MMMembershipPointsEntry.Next = 0;

        NpRiDataCollectionMgt.CloseWindow();
    end;

    local procedure FindMemberLoyaltyPoints(NpRiReimbursement: Record "NpRi Reimbursement";var MMMembershipPointsEntry: Record "MM Membership Points Entry"): Boolean
    var
        NpRiParty: Record "NpRi Party";
        NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";
        NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";
        TableView: Text;
        TableViewName: Text;
    begin
        Clear(MMMembershipPointsEntry);

        if (NpRiReimbursement."Data Collection Company" <> '') and (NpRiReimbursement."Data Collection Company" <> CompanyName) then
          MMMembershipPointsEntry.ChangeCompany(NpRiReimbursement."Data Collection Company");

        TableViewName := NpRiDataCollectionMgt.GetTableViewName(MMMembershipPointsEntry);
        NpRiReimbursementTemplate.Get(NpRiReimbursement."Template Code");
        if NpRiDataCollectionMgt.GetTableView(TableViewName,NpRiReimbursementTemplate,TableView) then
          MMMembershipPointsEntry.SetView(TableView);

        exit(MMMembershipPointsEntry.FindFirst);
    end;

    local procedure UpdateEntry(MMMembershipPointsEntry: Record "MM Membership Points Entry";var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntry."Document No." := MMMembershipPointsEntry."Document No.";
        NpRiReimbursementEntry."Document Type" := NpRiReimbursementEntry."Document Type"::" ";
        NpRiReimbursementEntry."Account No." := Format(MMMembershipPointsEntry."Membership Entry No.");
        NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::Membership;
        NpRiReimbursementEntry.Modify(true);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRi Collect Loyalty Points");
    end;
}

