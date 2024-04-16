codeunit 85003 "NPR Library - POS Mock"
{
    trigger OnRun()
    begin
    end;

    procedure InitializePOSSession(POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit")
    var
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
        POSAction: Record "NPR POS Action" temporary;
        UserSetup: record "User Setup";
        POSPageStack: Codeunit "NPR POS Page Stack";
    begin
        if UserSetup.Get(UserId) then;
        UserSetup."User ID" := UserId;
        UserSetup."NPR POS Unit No." := POSUnit."No.";
        if not UserSetup.Insert() then
            UserSetup.Modify();

        POSPageStack.SetIsPOSStack(true);

        POSBackgroundTaskAPI.Initialize(_POSBackgroundTaskManager);
        POSSession.Constructor(POSBackgroundTaskAPI);

        POSSession.SetReportErrorMessage(true);

        POSSession.StartPOSSession();

        POSAction.DiscoverActions();
    end;

    procedure InitializePOSSession(var POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit"; Salesperson: Record "Salesperson/Purchaser")
    var
        POSSetup: Codeunit "NPR POS Setup";
    begin
        InitializePOSSession(POSSession, POSUnit);
        POSSession.GetSetup(POSSetup);
        POSSetup.SetSalesperson(Salesperson);
    end;

    procedure InitializePOSSessionAndStartSale(var POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit"; var POSSale: Codeunit "NPR POS Sale")
    begin
        InitializePOSSession(POSSession, POSUnit);
        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
    end;

    procedure InitializePOSSessionAndStartSale(var POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit"; Salesperson: Record "Salesperson/Purchaser"; var POSSale: Codeunit "NPR POS Sale")
    var
        POSSetup: Codeunit "NPR POS Setup";
    begin
        InitializePOSSession(POSSession, POSUnit);
        POSSession.GetSetup(POSSetup);
        POSSetup.SetSalesperson(Salesperson);
        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
    end;

    procedure InitializePOSSessionAndStartSaleWithoutActions(var POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit"; var POSSale: Codeunit "NPR POS Sale")
    var
        UserSetup: record "User Setup";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
        POSPageStack: Codeunit "NPR POS Page Stack";
    begin
        if UserSetup.Get(UserId) then;
        UserSetup."User ID" := UserId;
        UserSetup."NPR POS Unit No." := POSUnit."No.";
        if not UserSetup.Insert() then
            UserSetup.Modify();

        POSPageStack.SetIsPOSStack(true);

        POSBackgroundTaskAPI.Initialize(_POSBackgroundTaskManager);
        POSSession.Constructor(POSBackgroundTaskAPI);
        POSSession.SetReportErrorMessage(true);
        POSSession.StartPOSSession();
        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
    end;

    procedure CreateItemLineWithDiscount(POSSession: Codeunit "NPR POS Session"; ItemNo: Text; Quantity: Decimal; DiscountPct: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLineOut: Codeunit "NPR POS Sale Line";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
    begin
        CreateItemLine(POSSession, ItemNo, Quantity);

        POSSession.GetSaleLine(SaleLineOut);
        SaleLineOut.GetCurrentSaleLine(SaleLinePOS);

        POSActionDiscountB.SetLineDiscountPctABS(SaleLinePOS, DiscountPct);
    end;

    procedure CreateItemLine(POSSession: Codeunit "NPR POS Session"; ItemNo: Text; Quantity: Decimal)
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        Item.Get(ItemNo);
        POSActionInsertItem.AddItemLine(Item, ItemReference, 0, Quantity, 0, '', '', '', POSSession, FrontEnd, ''); // Insert step of item action
    end;

    procedure CreateItemLineWithSerialNo(POSSession: Codeunit "NPR POS Session"; ItemNo: Text; Quantity: Decimal; SerialNo: Text)
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        LibraryRandom: Codeunit "Library - Random";
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        Item.Get(ItemNo);
        POSActionInsertItem.AddItemLine(Item, ItemReference, 0, Quantity, 0, '', '', SerialNo, POSSession, FrontEnd, ''); // Insert step of item action
    end;

    procedure CreateItemLine(POSSession: Codeunit "NPR POS Session"; Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; Quantity: Decimal)
    var
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        POSActionInsertItem.AddItemLine(Item, ItemReference, ItemIdentifierType, Quantity, 0, '', '', '', POSSession, FrontEnd, ''); // Insert step of item action
    end;

    procedure CreateItemLine(POSSession: Codeunit "NPR POS Session"; Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitPrice: Decimal; CustomDescription: Text; CustomDescription2: Text; InputSerial: Text)
    var
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        POSActionInsertItem.AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd, ''); // Insert step of item action
    end;

    procedure LookupItem(POSSession: Codeunit "NPR POS Session"; ItemView: Text; LocationFilterOption: Integer; var Item: Record Item)
    var
        POSActionItemLookup: Codeunit "NPR POS Action: Item Lookup B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSetup(POSSetup);
        Item.Get(POSActionItemLookup.LookupItem(POSSaleLine, POSSetup, ItemView, LocationFilterOption));
    end;

    procedure EndSale(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSActionEndSale: Codeunit "NPR POS Action End Sale B";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case FeatureFlagsManagement.IsEnabled('posLifeCycleEventsWorkflowsEnabled') of
            true:
                if not POSActionEndSale.EndSale(POSSale, POSSession, false, '', false, true) then
                    exit(false);
            false:
                if not POSSale.TryEndSale(POSSession, false) then
                    exit(false);
        end;

        POSPost(SalePOS);
        exit(true);
    end;

    procedure PayAndTryEndSaleAndStartNew(POSSession: Codeunit "NPR POS Session"; PaymentMethod: Code[10]; Amount: Decimal; VoucherNo: Text): Boolean
    begin
        exit(PayAndTryEndSaleAndStartNew(POSSession, PaymentMethod, Amount, VoucherNo, True));
    end;

    procedure PayAndTryEndSaleAndStartNew(POSSession: Codeunit "NPR POS Session"; PaymentMethod: Code[10]; Amount: Decimal; VoucherNo: Text; PostSaleImmediately: Boolean): Boolean
    var
        POSActionPayment: Codeunit "NPR POS Action: Payment";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSActionEndSale: Codeunit "NPR POS Action End Sale B";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        FrontEnd: Codeunit "NPR POS Front End Management";
        Handled: Boolean;
        NewSalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(PaymentMethod);

        //Invoke the business logic of the PAYMENT action
        POSSession.ClearActionState();
        POSSession.StoreActionState('ContextId', POSSession.BeginAction(POSActionPayment.ActionCode())); //Is done at start of payment action
        POSActionPayment.CapturePayment(POSPaymentMethod, POSSession, FrontEnd, Amount, Amount, VoucherNo, Handled); //Capture step of payment action
        if VoucherNo <> '' then
            IssueReturnVoucherFromPaymentMethod(POSSession, VoucherNo);

        if not FeatureFlagsManagement.IsEnabled('posLifeCycleEventsWorkflowsEnabled') then
            POSActionPayment.TryEndSale(POSPaymentMethod, POSSession) //TryEndSale step of payment action        
        else
            POSActionEndSale.EndSale(POSSale, POSSession, true, POSPaymentMethod.Code, true, true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(NewSalePOS);
        if NewSalePOS.SystemId = SalePOS.SystemId then
            exit(false); //Sale did not end. This is not an error, it happens in prod whenever you pay less than full amount.

        if PostSaleImmediately then begin
            POSPost(SalePOS);
        end;

        if IsNullGuid(NewSalePOS.SystemId) then begin
            //Sale ended, but new one did not start automatically (depends on setup)
            POSSession.StartTransaction();
        end;

        exit(true);
    end;

    procedure CreateVoucherLine(POSSession: Codeunit "NPR POS Session"; VoucherTypeCode: Code[20]; Quantity: Decimal; VoucherAmount: Decimal; DiscountType: Text; DiscountAmount: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        QtyNotPositiveErr: Label 'You must specify a positive quantity.';
    begin
        VoucherType.Get(VoucherTypeCode);

        NpRvVoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"Issue Voucher");
        SaleLinePOS.Validate("No.", VoucherType."Account No.");
        SaleLinePOS.Description := VoucherType.Description;
        SaleLinePOS.Quantity := Quantity;
        if SaleLinePOS.Quantity < 0 then
            Error(QtyNotPositiveErr);

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Unit Price" := VoucherAmount;

        case DiscountType of
            '0':
                SaleLinePOS."Discount Amount" := DiscountAmount;
            '1':
                SaleLinePOS."Discount %" := DiscountAmount;
        end;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if SaleLinePOS."Discount Amount" > 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS.Description := TempVoucher.Description;
        SaleLinePOS.Modify(true);
        POSSession.RequestRefreshData();

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        case SalePOS."Customer Type" of
            SalePOS."Customer Type"::Ord:
                begin
                    NpRvSalesLine.Validate("Customer No.", SalePOS."Customer No.");
                end;
            SalePOS."Customer Type"::Cash:
                begin
                    NpRvSalesLine.Validate("Contact No.", SalePOS."Customer No.");
                end;
        end;

        NpRvSalesLine.Insert();

        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
            NpRvSalesLineReference.Init();
            NpRvSalesLineReference.Id := CreateGuid();
            NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
            NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
            NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
            NpRvSalesLineReference.Insert(true);
        end;
        POSSession.RequestRefreshData();
    end;

    internal procedure PayWithVoucherAndTryEndSaleAndStartNew(POSSession: Codeunit "NPR POS Session"; VoucherType: Code[20]; VoucherReferenceNo: Text[30]): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        VoucherPayment(POSSession, VoucherReferenceNo, VoucherType);
        IssueReturnVoucher(POSSession, VoucherType);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if not EndSale(POSSession, VoucherType) then
            exit(false);

        POSPost(SalePOS);

        exit(true);
    end;


    local procedure VoucherPayment(POSSession: Codeunit "NPR POS Session"; VoucherReferenceNo: Text[30]; VoucherTypeCode: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR POS Sale Line";
    begin
        if VoucherReferenceNo = '' then
            exit;

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetFrontEnd(FrontEnd, true);


        NpRvVoucherMgt.ApplyVoucherPayment(VoucherTypeCode, VoucherReferenceNo, POSLine, SalePOS, POSSession, FrontEnd, POSPaymentLine, POSLine, false);
    end;

    procedure VoucherTopUp(POSSession: Codeunit "NPR POS Session"; VoucherNo: Text; VoucherAmount: Decimal; DiscountType: Text; DiscountAmount: Decimal)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        if VoucherNo = '' then exit;

        NpRvVoucherMgt.TopUpVoucher(POSSession, VoucherNo, DiscountType, VoucherAmount, 0, 0);
    end;



    local procedure EndSale(POSSession: Codeunit "NPR POS Session"; VoucherTypeCode: Code[20]): Boolean
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        POSActionEndSale: Codeunit "NPR POS Action End Sale B";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        PaidAmount, ReturnAmount, SaleAmount, Subtotal : Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSSession.GetSetup(POSSetup);
        if Abs(Subtotal) > Abs(POSSetup.AmountRoundingPrecision) then
            exit(false);

        NpRvVoucherType.Get(VoucherTypeCode);
        if not POSPaymentMethod.Get(NpRvVoucherType."Payment Type") then
            exit(false);
        if not ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code") then
            exit(false);
        if POSPaymentLine.CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) <> 0 then
            exit(false);

        POSSession.GetSale(POSSale);
        case FeatureFlagsManagement.IsEnabled('posLifeCycleEventsWorkflowsEnabled') of
            true:
                if not POSActionEndSale.EndSale(POSSale, POSSession, true, POSPaymentMethod.Code, true, true) then
                    exit(false);
            false:
                if not POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod) then
                    exit(false);
        end;
        exit(true);
    end;

    local procedure IssueReturnVoucher(POSSession: Codeunit "NPR POS Session"; VoucherTypeCode: Code[20])
    var
        ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        VoucherType2: Record "NPR NpRv Voucher Type";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        PaidAmount, ReturnAmount, SaleAmount, Subtotal : Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if ReturnAmount = 0 then
            exit;
        ReturnAmount := ReturnAmount * (-1);
        if not ReturnVoucherType.Get(VoucherTypeCode) then
            exit;
        if VoucherType2.Get(ReturnVoucherType."Return Voucher Type") and POSPaymentMethod.Get(VoucherType2."Payment Type") then begin
            if POSPaymentMethod."Rounding Precision" > 0 then
                ReturnAmount := Round(ReturnAmount, POSPaymentMethod."Rounding Precision");
            if (POSPaymentMethod."Minimum Amount" > 0) and (Abs(ReturnAmount) < (POSPaymentMethod."Minimum Amount")) then
                exit;
            if (VoucherType2."Minimum Amount Issue" > 0) and (Abs(ReturnAmount) < VoucherType2."Minimum Amount Issue") then
                exit;
        end;

        NpRvVoucherMgt.IssueReturnVoucher(POSSession, VoucherType2.Code, ReturnAmount, '', '', false, false, false);
    end;

    local procedure IssueReturnVoucherFromPaymentMethod(POSSession: Codeunit "NPR POS Session"; VoucherNo: Text)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        NpRvVoucher.SetRange("Reference No.", VoucherNo);
        if NpRvVoucher.FindFirst() then
            IssueReturnVoucher(POSSession, NpRvVoucher."Voucher Type");
    end;

    local procedure POSPost(SalePOS: Record "NPR POS Sale")
    var
        POSPostMock: Codeunit "NPR Library - POS Post Mock";
    begin
        // Used to be triggered automatically
        Commit();
        POSPostMock.Initialize(true, true);
        POSPostMock.Run(SalePOS);
    end;


    procedure InitializeData(var Initialized: Boolean; var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Record "NPR POS Setup";
        ObjectType: Option ,,,"Report",,"Codeunit","XMLPort",,"Page";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePosMenuFilter(ObjectType::Page, 22, 'CUSDOM');
            Initialized := true;
        end;

        Commit();
    end;

    procedure InitializeData(var Initialized: Boolean; var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store"; var POSPaymentMethod: Record "NPR POS Payment Method")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Record "NPR POS Setup";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            Initialized := true;
        end;

        Commit();
    end;
}