codeunit 50004 "NPR Library - POS Mock"
{
    trigger OnRun()
    begin
    end;

    procedure InitializePOSSession(POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnitIdentity: Codeunit "NPR POS Unit Identity";
        POSUnitIdentityRec: Record "NPR POS Unit Identity";
        POSMockFramework: Codeunit "NPR POS Framework: Mock";
    begin
        POSMockFramework.Constructor();
        POSSession.Constructor(POSMockFramework, POSFrontEnd, POSSetup, POSSession);
        POSUnitIdentity.ConfigureTemporaryDevice(POSUnit."No.", POSUnitIdentityRec);
        POSSetup.InitializeUsingPosUnitIdentity(POSUnitIdentityRec);
        POSSession.StartPOSSession();
    end;

    procedure InitializePOSSessionAndStartSale(var POSSession: Codeunit "NPR POS Session"; POSUnit: Record "NPR POS Unit"; var POSSale: Codeunit "NPR POS Sale")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnitIdentity: Codeunit "NPR POS Unit Identity";
        POSUnitIdentityRec: Record "NPR POS Unit Identity";
    begin
        InitializePOSSession(POSSession, POSUnit);
        POSSession.StartTransaction();
        POSSession.GetSale(POSSale);
    end;

    procedure CreateItemLine(POSSession: Codeunit "NPR POS Session"; ItemNo: Text; Quantity: Decimal)
    var
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item";
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        ActionID: Guid;
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        Item.Get(ItemNo);

        POSActionInsertItem.AddItemLine(Item, ItemCrossReference, 0, Quantity, 0, false, '', '', false, '', POSSession, FrontEnd); //Insert step of item action
    end;

    procedure EndSale(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndSale2(POSSession, false));
    end;

    procedure PayAndTryEndSaleAndStartNew(POSSession: Codeunit "NPR POS Session"; PaymentMethod: Code[10]; Amount: Decimal; VoucherNo: Text): Boolean
    var
        POSActionPayment: Codeunit "NPR POS Action: Payment";
        PaymentTypePOS: Record "NPR Payment Type POS";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        FrontEnd: Codeunit "NPR POS Front End Management";
        Handled: Boolean;
        NewSalePOS: Record "NPR Sale POS";
        ActionID: Guid;
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        PaymentTypePOS.GetByRegister(PaymentMethod, SalePOS."Register No.");

        //Invoke the business logic of the PAYMENT action
        POSSession.ClearActionState();
        POSSession.StoreActionState('ContextId', POSSession.BeginAction(POSActionPayment.ActionCode())); //Is done at start of payment action
        POSActionPayment.CapturePayment(PaymentTypePOS, POSSession, FrontEnd, Amount, VoucherNo, Handled); //Capture step of payment action
        POSActionPayment.TryEndSale(PaymentTypePOS, POSSession); //TryEndSale step of payment action

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(NewSalePOS);
        if NewSalePOS."Retail ID" = SalePOS."Retail ID" then
            exit(false); //Sale did not end. This is not an error, it happens in prod whenever you pay less than full amount.

        if IsNullGuid(NewSalePOS."Retail ID") then begin
            //Sale ended, but new one did not start automatically (depends on setup)
            POSSession.StartTransaction();
        end;

        exit(true);
    end;
}

