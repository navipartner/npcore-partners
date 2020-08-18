codeunit 6151494 "Raptor Send Data"
{
    // NPR5.53/ALPO/20191128 CASE 379012 Raptor tracking integration: send info about sold products to Raptor
    // NPR5.55/ALPO/20200422 CASE 400925 Exclude webshop sales from data sent to Raptor

    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Process(Rec);
    end;

    var
        RaptorSetup: Record "Raptor Setup";
        IncorrectFunctionCallErr: Label 'Function call on a non-temporary variable. This is a critical programming error. Please contact system vendor.';
        SalespersonTmp: Record "Salesperson/Purchaser" temporary;

    local procedure Process(var JobQueueEntry: Record "Job Queue Entry")
    var
        TempDataLog: Record "Data Log Record" temporary;
        ItemLedger: Record "Item Ledger Entry";
        DataLogSubscriberMgt: Codeunit "Data Log Subscriber Mgt.";
        RaptorMgt: Codeunit "Raptor Management";
        RecRef: RecordRef;
        SessionGUID: Guid;
    begin
        if not (RaptorSetup.Get and RaptorSetup."Send Data to Raptor") then
          exit;

        if not DataLogSubscriberMgt.GetNewRecords(RaptorMgt.RaptorDataLogSubscriber,true,0,TempDataLog) then
          exit;

        SessionGUID := CreateGuid;

        OnProcessDataLogEntries(TempDataLog,SessionGUID);

        TempDataLog.SetRange("Table ID",DATABASE::"Item Ledger Entry");
        TempDataLog.SetRange("Type of Change",TempDataLog."Type of Change"::Insert);
        if not TempDataLog.FindSet then
          exit;

        repeat
          if RecRef.Get(TempDataLog."Record ID") then
            if RecRef.Number = DATABASE::"Item Ledger Entry" then begin
              RecRef.SetTable(ItemLedger);
              //-NPR5.55 [400925]-revoked
              //IF (ItemLedger."Entry Type" = ItemLedger."Entry Type"::Sale) AND
              //   (ItemLedger."Source Type" = ItemLedger."Source Type"::Customer) AND
              //   (ItemLedger."Source No." <> '')
              //THEN
              //+NPR5.55 [400925]-revoked
              if ItemLedgerIsEligibleForSending(ItemLedger) then
                SendItemLedgerEntry(ItemLedger,SessionGUID);
            end;
        until TempDataLog.Next = 0;
    end;

    local procedure SendItemLedgerEntry(ItemLedger: Record "Item Ledger Entry";SessionGUID: Guid)
    var
        Parameters: Record "Name/Value Buffer" temporary;
        RaptorMgt: Codeunit "Raptor Management";
    begin
        GenerateParameters(Parameters,ItemLedger,SessionGUID);
        OnBeforeILESendRaptorTrackingRequest(Parameters,ItemLedger,false);
        RaptorMgt.SendRaptorTrackingRequest(Parameters);
    end;

    procedure Test_ShowItemLedgerRaptorParameters(ItemLedger: Record "Item Ledger Entry")
    var
        Parameters: Record "Name/Value Buffer" temporary;
        DummySessionGUID: Guid;
    begin
        //-NPR5.55 [400925]
        GenerateParameters(Parameters,ItemLedger,DummySessionGUID);
        OnBeforeILESendRaptorTrackingRequest(Parameters,ItemLedger,true);
        PAGE.RunModal(PAGE::"Name/Value Lookup",Parameters);
        //+NPR5.55 [400925]
    end;

    local procedure ItemLedgerIsEligibleForSending(ItemLedger: Record "Item Ledger Entry"): Boolean
    var
        Eligible: Boolean;
        Handled: Boolean;
    begin
        //-NPR5.55 [400925]
        OnCheckIfItemLedgerIsEligibleForSending(ItemLedger,Eligible,Handled);
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
          SalespersonTmp.Reset;
          if SalespersonTmp.IsEmpty then
            CreateTmpSalespersonList(SalespersonTmp);
          SalespersonTmp.SetFilter(Code,RaptorSetup."Webshop Salesperson Filter");
          SalespersonTmp.Code := ItemLedger."Salesperson Code";
          Eligible := not SalespersonTmp.Find;
        end;

        exit(Eligible);
        //+NPR5.55 [400925]
    end;

    procedure CreateTmpSalespersonList(var SalespersonTmp: Record "Salesperson/Purchaser")
    var
        Salesperson: Record "Salesperson/Purchaser";
        EmptyNameML: Label '<w/out salesperson>';
    begin
        //-NPR5.55 [400925]
        if not SalespersonTmp.IsTemporary then
          Error(IncorrectFunctionCallErr);

        Clear(SalespersonTmp);
        SalespersonTmp.DeleteAll;
        if Salesperson.FindSet then
          repeat
            SalespersonTmp := Salesperson;
            SalespersonTmp.Insert;
          until Salesperson.Next = 0;
        SalespersonTmp.Init;
        SalespersonTmp.Code := '';
        SalespersonTmp.Name := CopyStr(EmptyNameML,1,MaxStrLen(SalespersonTmp.Name));
        if not SalespersonTmp.Find then
          SalespersonTmp.Insert;
        //+NPR5.55 [400925]
    end;

    local procedure GenerateParameters(var Parameters: Record "Name/Value Buffer";ItemLedger: Record "Item Ledger Entry";SessionGUID: Guid)
    var
        CashRegister: Record Register;
        Item: Record Item;
        RaptorMgt: Codeunit "Raptor Management";
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
        
        Use parameters, which name starts with low line (underscore) character "_", to pass data between NAV
        modules/subscribers. Those are not sent to Raptor.
        */
        
        if not CashRegister.Get(ItemLedger."Register Number") then
          CashRegister.Init;
        if not Item.Get(ItemLedger."Item No.") then
          Item.Init;
        Parameters.DeleteAll;
        //Tracking
        AddParameter(Parameters,1001,'p1','buy');
        AddParameter(Parameters,1002,'p2',ItemLedger."Item No.");
        AddParameter(Parameters,1003,'p3',Item.Description);
        AddParameter(Parameters,1007,'p7',ItemLedger."Source No.");
        AddParameter(Parameters,1012,'p12',CashRegister."Shop id");
        AddParameter(Parameters,1021,'p21',ItemLedger."Document No.");
        
        AddParameter(Parameters,5000,'sid',SessionGUID);

    end;

    procedure AddParameter(var Parameters: Record "Name/Value Buffer";ID: Integer;Name: Text;Value: Text)
    begin
        Parameters.ID := ID;
        Parameters.Name := Name;
        Parameters.Value := Value;
        Parameters.Insert;
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeILESendRaptorTrackingRequest(var Parameters: Record "Name/Value Buffer";ItemLedger: Record "Item Ledger Entry";IsMock: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnProcessDataLogEntries(var TempDataLog: Record "Data Log Record";SessionGUID: Guid)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnCheckIfItemLedgerIsEligibleForSending(ItemLedger: Record "Item Ledger Entry";var Eligible: Boolean;var Handled: Boolean)
    begin
    end;
}

