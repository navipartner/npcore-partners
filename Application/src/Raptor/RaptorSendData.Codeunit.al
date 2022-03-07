codeunit 6151494 "NPR Raptor Send Data"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Process();
    end;

    var
        RaptorSetup: Record "NPR Raptor Setup";
        IncorrectFunctionCallErr: Label 'Function call on a non-temporary variable. This is a critical programming error. Please contact system vendor.';
        TempSalesperson: Record "Salesperson/Purchaser" temporary;

    local procedure Process()
    var
        TempDataLog: Record "NPR Data Log Record" temporary;
        ItemLedger: Record "Item Ledger Entry";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RaptorMgt: Codeunit "NPR Raptor Management";
        RecRef: RecordRef;
        SessionGUID: Guid;
    begin
        if not (RaptorSetup.Get() and RaptorSetup."Send Data to Raptor") then
            exit;

        if not DataLogSubscriberMgt.GetNewRecords(RaptorMgt.RaptorDataLogSubscriber(), true, 0, TempDataLog) then
            exit;

        SessionGUID := CreateGuid();

        OnProcessDataLogEntries(TempDataLog, SessionGUID);

        TempDataLog.SetRange("Table ID", DATABASE::"Item Ledger Entry");
        TempDataLog.SetRange("Type of Change", TempDataLog."Type of Change"::Insert);
        if not TempDataLog.FindSet() then
            exit;

        repeat
            if RecRef.Get(TempDataLog."Record ID") then
                if RecRef.Number = DATABASE::"Item Ledger Entry" then begin
                    RecRef.SetTable(ItemLedger);
                    if ItemLedgerIsEligibleForSending(ItemLedger) then
                        SendItemLedgerEntry(ItemLedger, SessionGUID);
                end;
        until TempDataLog.Next() = 0;
    end;

    local procedure SendItemLedgerEntry(ItemLedger: Record "Item Ledger Entry"; SessionGUID: Guid)
    var
        TempParameters: Record "Name/Value Buffer" temporary;
        RaptorMgt: Codeunit "NPR Raptor Management";
    begin
        GenerateParameters(TempParameters, ItemLedger, SessionGUID);
        OnBeforeILESendRaptorTrackingRequest(TempParameters, ItemLedger, false);
        RaptorMgt.SendRaptorTrackingRequest(TempParameters);
    end;

    procedure Test_ShowItemLedgerRaptorParameters(ItemLedger: Record "Item Ledger Entry")
    var
        TempParameters: Record "Name/Value Buffer" temporary;
        DummySessionGUID: Guid;
    begin
        GenerateParameters(TempParameters, ItemLedger, DummySessionGUID);
        OnBeforeILESendRaptorTrackingRequest(TempParameters, ItemLedger, true);
        PAGE.RunModal(PAGE::"Name/Value Lookup", TempParameters);
    end;

    local procedure ItemLedgerIsEligibleForSending(ItemLedger: Record "Item Ledger Entry"): Boolean
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        Eligible: Boolean;
        Handled: Boolean;
    begin
        OnCheckIfItemLedgerIsEligibleForSending(ItemLedger, Eligible, Handled);
        if Handled then
            exit(Eligible);

        Eligible :=
          (ItemLedger."Entry Type" = ItemLedger."Entry Type"::Sale) and
          (ItemLedger."Source Type" = ItemLedger."Source Type"::Customer) and
          (ItemLedger."Source No." <> '');

        if not Eligible then
            exit(false);

        Eligible := not RaptorSetup."Exclude Webshop Sales" or (RaptorSetup."Webshop Salesperson Filter" = '');
        if not Eligible then begin
            TempSalesperson.Reset();
            if TempSalesperson.IsEmpty then
                CreateTmpSalespersonList(TempSalesperson);
            TempSalesperson.SetFilter(Code, RaptorSetup."Webshop Salesperson Filter");
            AuxItemLedgerEntry.Get(ItemLedger."Entry No.");
            TempSalesperson.Code := AuxItemLedgerEntry."Salespers./Purch. Code";
            Eligible := not TempSalesperson.Find();
        end;

        exit(Eligible);
    end;

    procedure CreateTmpSalespersonList(var SalespersonTmp: Record "Salesperson/Purchaser")
    var
        Salesperson: Record "Salesperson/Purchaser";
        EmptyNameML: Label '<w/out salesperson>';
    begin
        if not SalespersonTmp.IsTemporary then
            Error(IncorrectFunctionCallErr);

        Clear(SalespersonTmp);
        SalespersonTmp.DeleteAll();
        if Salesperson.FindSet() then
            repeat
                SalespersonTmp := Salesperson;
                SalespersonTmp.Insert();
            until Salesperson.Next() = 0;
        SalespersonTmp.Init();
        SalespersonTmp.Code := '';
        SalespersonTmp.Name := CopyStr(EmptyNameML, 1, MaxStrLen(SalespersonTmp.Name));
        if not SalespersonTmp.Find() then
            SalespersonTmp.Insert();
    end;

    local procedure GenerateParameters(var Parameters: Record "Name/Value Buffer"; ItemLedger: Record "Item Ledger Entry"; SessionGUID: Guid)
    var
        POSUnit: Record "NPR POS Unit";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        Item: Record Item;
    begin
        /*
        -=List Of Raptor Parameters=-
        p1: EventType. Possible values: visit, basket or buy
        p2: ProductId (Item No.)
        p3: ProductName (Item Description)
        p4: CategoryPath
        p5: Subtotal
        p6: Currency
        p7: UserId (Customer No.)
        p8: BrandId
        p9: ContentId
        p10: BasketContent
        p11: BasketId
        p12: ShopId
        p21: OrderId
        
        -> session parameters - aren't mandatory
        sid: Session Id (GUID)
        coid: Cookie Id (GUID)
        ruid: User Id (Base64 encoded)
        
        Use parameters with names starting with low line (underscore) character "_" to pass data between NAV modules/subscribers. Those are not sent to Raptor.
        */

        AuxItemLedgerEntry.Get(ItemLedger."Entry No.");
        if not POSUnit.Get(AuxItemLedgerEntry."POS Unit No.") then
            POSUnit.Init();

        if not Item.Get(ItemLedger."Item No.") then
            Item.Init();
        Parameters.DeleteAll();
        //Tracking
        AddParameter(Parameters, 1001, 'p1', 'buy');
        AddParameter(Parameters, 1002, 'p2', ItemLedger."Item No.");
        AddParameter(Parameters, 1003, 'p3', Item.Description);
        AddParameter(Parameters, 1007, 'p7', ItemLedger."Source No.");
        AddParameter(Parameters, 1012, 'p12', POSUnit."POS Store Code");
        AddParameter(Parameters, 1021, 'p21', ItemLedger."Document No.");

        AddParameter(Parameters, 5000, 'sid', SessionGUID);

    end;

    procedure AddParameter(var Parameters: Record "Name/Value Buffer"; ID: Integer; Name: Text; "Value": Text)
    begin
        Parameters.ID := ID;
        Parameters.Name := CopyStr(Name, 1, MaxStrLen(Parameters.Name));
        Parameters."Value" := CopyStr("Value", 1, MaxStrLen(Parameters."Value"));
        Parameters.Insert();
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeILESendRaptorTrackingRequest(var Parameters: Record "Name/Value Buffer"; ItemLedger: Record "Item Ledger Entry"; IsMock: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnProcessDataLogEntries(var TempDataLog: Record "NPR Data Log Record"; SessionGUID: Guid)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnCheckIfItemLedgerIsEligibleForSending(ItemLedger: Record "Item Ledger Entry"; var Eligible: Boolean; var Handled: Boolean)
    begin
    end;
}
