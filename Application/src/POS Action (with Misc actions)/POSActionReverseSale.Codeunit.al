codeunit 6150798 "NPR POS Action: Reverse Sale"
{
    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Refund / Reverse Sale. This action will prompt for a receipt no and recreate the sales with reversed quantity.';
        Title: Label 'Reverse Sale';
        ReceiptPrompt: Label 'Receipt Number';
        ReasonPrompt: Label 'Return Reason';
        ResellablePrompt: Label 'Are the returned items resellable?';
        NotAllowed: Label '%1 does not have the rights to return sales ticket. Make a return sale instead.';
        ReasonRequired: Label 'You must choose a return reason.';
        NotFound: Label 'Return receipt reference number %1 not found.';
        NOTHING_TO_RETURN: Label 'All items sold on ticket %1  has already been returned. ';
        MAX_TO_RETURN: Label 'Maximum number of items to return is %1.';
        COPIED_RECEIPT: Label 'This sales is copied from %1 and new return items can''t be added to the return sales.';
        QTY_ADJUSTED: Label 'Quantity was adjusted due to previous return sales.';
        POSEntryMgt: Codeunit "NPR POS Entry Management";
        DimsNotCopied: Label 'Dimension copy is only supported, when Advanced Posting is activated.\Dimensions were not copied from the original sale.';

    local procedure ActionCode(): Text
    begin
        exit('REVERSE_SALE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('receipt', 'input(labels.title, labels.receiptprompt).respond().cancel(abort);');
                RegisterWorkflowStep('reason', 'context.PromptForReason && respond();');
                RegisterWorkflowStep('handle', 'respond();');
                RegisterWorkflow(true);

                RegisterOptionParameter('ItemCondition', 'Mint,Used,Not Suitable for Resale', 'Used');
                RegisterOptionParameter('ObfucationMethod', 'None,MI', 'None');
                RegisterBooleanParameter('CopyHeaderDimensions', false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Setup: Codeunit "NPR POS Setup";
        RetailSetup: Record "NPR Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        // TODO: Remove this verification and start the permission & security workflow instead
        POSSession.GetSetup(Setup);
        SalespersonPurchaser.Get(Setup.Salesperson);

        RetailSetup.Get();
        Context.SetContext('PromptForReason', RetailSetup."Reason for Return Mandatory");

        case SalespersonPurchaser."NPR Reverse Sales Ticket" of
            SalespersonPurchaser."NPR Reverse Sales Ticket"::No:
                Error(NotAllowed, SalespersonPurchaser.Name);
        end;

        FrontEnd.SetActionContext(ActionCode, Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ReturnReasonCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'receipt':
                begin
                end;
            'reason':
                begin
                    ReturnReasonCode := SelectReturnReason(Context, POSSession, FrontEnd);
                    JSON.SetContext('ReturnReasonCode', ReturnReasonCode);
                    FrontEnd.SetActionContext(ActionCode, JSON);
                end;
            'handle':
                begin
                    Error('Needs to be updated from audit roll to POS entry');
                    VerifyReceiptForReversal(Context, POSSession, FrontEnd);
                    CopySalesReceiptForReversal(Context, POSSession, FrontEnd);
                    POSSession.ChangeViewSale();
                    POSSession.RequestRefreshData();
                end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'receiptprompt', ReceiptPrompt);
        Captions.AddActionCaption(ActionCode, 'reasonprompt', ReasonPrompt);
    end;

    local procedure VerifyReceiptForReversal(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        AuditRoll: Record "NPR Audit Roll";
        SalesTicketNo: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScope('/', true);
        JSON.SetScope('$receipt', true);
        SalesTicketNo := JSON.GetString('input', true);
        if (SalesTicketNo = '') then
            Error('That receipt is not valid for sales reversal.');

        POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfucationMethod', false), SalesTicketNo);
        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        if (not AuditRoll.FindFirst()) then
            Error(NotFound, JSON.GetString('input', true));

        if (IsCompleteReversal(SalesTicketNo)) then
            Error(NOTHING_TO_RETURN, SalesTicketNo);

        OnBeforeReverseSalesTicket(AuditRoll."Sales Ticket No.");
    end;

    local procedure CopySalesReceiptForReversal(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        RetailSetup: Record "NPR Retail Setup";
        SalesTicketNo: Code[20];
        ReturnReasonCode: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScope('/', true);
        JSON.SetScope('$receipt', true);
        SalesTicketNo := JSON.GetString('input', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);

        POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfucationMethod', false), SalesTicketNo);

        SetCustomerOnReverseSale(SalePOS, SalesTicketNo);

        RetailSetup.Get();
        JSON.SetScope('/', true);
        ReturnReasonCode := JSON.GetString('ReturnReasonCode', RetailSetup."Reason for Return Mandatory");

        //This function heavily used audit roll and tried to do too much. It should just reverse the simple types like Item, GL. Any aux module needs to subscribe and handle itself like retail voucher etc.
        //RetailSalesCode.ReverseSalesTicket2(SalePOS, SalesTicketNo, ReturnReasonCode);     

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        SaleLinePOS.ModifyAll("Return Sale Sales Ticket No.", SalesTicketNo);
        if not SaleLinePOS.IsEmpty then
            POSSaleLine.SetLast();

        if (ApplyMaxReturnQty(SalePOS, SalesTicketNo)) then
            Message(QTY_ADJUSTED);

        if JSON.GetBooleanParameter('CopyHeaderDimensions', false) then
            if CopyDimensions(SalePOS, SalesTicketNo) then begin
                POSSale.Refresh(SalePOS);
                POSSale.SetModified();
            end;

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();

        POSSale.RefreshCurrent();
    end;

    local procedure SelectReturnReason(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Code[20]
    var
        RetailSetup: Record "NPR Retail Setup";
        ReturnReason: Record "Return Reason";
    begin

        if (PAGE.RunModal(PAGE::"NPR TouchScreen: Ret. Reasons", ReturnReason) = ACTION::LookupOK) then
            exit(ReturnReason.Code);

        Error(ReasonRequired);
    end;

    local procedure SetCustomerOnReverseSale(var SalePOS: Record "NPR Sale POS"; SalesTicketNo: Code[20])
    var
        AuditRoll: Record "NPR Audit Roll";
        CustomerNo: Code[20];
        POSSale: Codeunit "NPR POS Sale";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);

        if AuditRoll.IsEmpty then exit;
        AuditRoll.FindSet;
        repeat
            CustomerNo := AuditRoll."Customer No.";
        until ((0 = AuditRoll.Next) or (CustomerNo <> ''));

        if Customer.Get(CustomerNo) then begin
            SalePOS.Validate("Customer No.", Customer."No.");
        end else begin
            if Contact.Get(CustomerNo) then begin
                SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
                SalePOS.Validate("Customer No.", Contact."No.");
            end;
        end;


        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure IsCompleteReversal(SalesTicketNo: Code[20]): Boolean
    var
        TmpPosRmaLine: Record "NPR POS RMA Line";
        PosRmaLine: Record "NPR POS RMA Line";
        POSSalesLine: Record "NPR POS Sales Line";
        ItemQty: Decimal;
    begin
        PosRmaLine.SetFilter("Sales Ticket No.", '=%1', SalesTicketNo);
        if (PosRmaLine.IsEmpty()) then
            exit(false); // No return sales for this register yet

        POSSalesLine.SetFilter("Document No.", '=%1', SalesTicketNo);
        POSSalesLine.SetFilter(Type, '=%1', POSSalesLine.Type::Item);

        if (POSSalesLine.FindSet()) then begin
            repeat
                TmpPosRmaLine."Sales Ticket No." := SalesTicketNo;
                TmpPosRmaLine."Returned Item No." := POSSalesLine."No.";
                TmpPosRmaLine.CalcFields("FF Total Qty Sold", "FF Total Qty Returned");
                ItemQty += TmpPosRmaLine."FF Total Qty Sold" + TmpPosRmaLine."FF Total Qty Returned";
            until (POSSalesLine.Next() = 0);
        end;

        // When returned quantity is equal to (or exceeds) sold quantity, all items have been returned
        exit(ItemQty <= 0);
    end;

    local procedure ApplyMaxReturnQty(CurrentSalePOS: Record "NPR Sale POS"; OriginalSalesTicketNo: Code[20]): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        AdjustedQty: Decimal;
        QtyIsAdjusted: Boolean;
    begin
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', CurrentSalePOS."Sales Ticket No.");
        if (SaleLinePOS.FindSet()) then begin
            repeat
                if ((SaleLinePOS.Quantity < 0) and (SaleLinePOS.Type = SaleLinePOS.Type::Item) and (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale)) then begin
                    AdjustedQty := GetRemainingQtyToReturn(OriginalSalesTicketNo, Abs(SaleLinePOS.Quantity), SaleLinePOS."Line No.") * -1;
                    if (AdjustedQty <> SaleLinePOS.Quantity) then begin
                        SaleLinePOS.Validate(Quantity, AdjustedQty);
                        SaleLinePOS.Modify();
                        QtyIsAdjusted := true;
                    end;
                end;
            until (SaleLinePOS.Next() = 0);
        end;

        exit(QtyIsAdjusted);
    end;

    local procedure GetRemainingQtyToReturn(SalesTicketNo: Code[20]; OriginalQty: Decimal; LineNo: Integer) MaxQuantity: Decimal
    var
        POSSalesLine: Record "NPR POS Sales Line";
        PosRmaLine: Record "NPR POS RMA Line";
    begin
        POSSalesLine.SetFilter("Document No.", '=%1', SalesTicketNo);
        POSSalesLine.SetFilter("Line No.", '=%1', LineNo);
        if (not POSSalesLine.FindFirst()) then
            exit(OriginalQty);

        MaxQuantity := POSSalesLine.Quantity;

        // Check previous returns
        PosRmaLine.SetFilter("Sales Ticket No.", '=%1', SalesTicketNo);
        PosRmaLine.SetFilter("Returned Item No.", '=%1', POSSalesLine."No.");
        PosRmaLine.SetFilter("Line No. Filter", '=%1', LineNo);

        if (PosRmaLine.FindFirst()) then begin
            PosRmaLine.CalcFields("FF Total Qty Sold", "FF Total Qty Returned");
            if (PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned" < MaxQuantity) then
                MaxQuantity := PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned";
        end;

        // Either sales ticket is a return order or we have over returned already.
        if (MaxQuantity < 0) then
            MaxQuantity := 0;
    end;

    local procedure CopyDimensions(var CurrentSalePOS: Record "NPR Sale POS"; OriginalSalesTicketNo: Code[20]): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        RetailSetup: Record "NPR NP Retail Setup";
        OldDimSetID: Integer;
    begin
        RetailSetup.Get;
        if not RetailSetup."Advanced Posting Activated" then begin
            Message(DimsNotCopied);
            exit(false);
        end;

        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", OriginalSalesTicketNo);
        if POSEntry.FindLast then
            if CurrentSalePOS."Dimension Set ID" <> POSEntry."Dimension Set ID" then begin
                OldDimSetID := CurrentSalePOS."Dimension Set ID";

                CurrentSalePOS."Dimension Set ID" := POSEntry."Dimension Set ID";
                CurrentSalePOS."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                CurrentSalePOS."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                CurrentSalePOS.Modify;

                if CurrentSalePOS.SalesLinesExist then
                    CurrentSalePOS.UpdateAllLineDim(CurrentSalePOS."Dimension Set ID", OldDimSetID);

                exit(true);
            end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantityOnReverseSales(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS"; var NewQuantity: Decimal)
    var
        PosRmaLine: Record "NPR POS RMA Line";
        SaleLinePOSCopy: Record "NPR Sale Line POS";
    begin
        // Publisher in Codeunit POS Sale Line
        // This subscriber is intended to prevent returning more items them originally sold
        if (NewQuantity >= 0) then
            exit;

        if (SaleLinePOS."Sale Type" <> SaleLinePOS."Sale Type"::Sale)
          then
            exit;

        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
            exit;

        // if this line is missing the sales ticket reference, all the other lines must also not have have a reference
        if (SaleLinePOS."Return Sale Sales Ticket No." = '') then begin
            SaleLinePOSCopy.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
            SaleLinePOSCopy.SetFilter("Sale Type", '=%1', SaleLinePOSCopy."Sale Type"::Sale);
            SaleLinePOSCopy.SetFilter(Type, '=%1', SaleLinePOSCopy.Type::Item);
            SaleLinePOSCopy.SetFilter(Quantity, '<%1', 0);
            SaleLinePOSCopy.SetFilter("Return Sale Sales Ticket No.", '<>%1', '');
            if (not SaleLinePOSCopy.IsEmpty()) then
                Error(COPIED_RECEIPT, SaleLinePOS."Sales Ticket No.");
            exit;
        end;

        PosRmaLine.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
        PosRmaLine.SetFilter("Returned Item No.", '=%1', SaleLinePOS."No.");

        if (PosRmaLine.FindFirst()) then begin
            PosRmaLine.CalcFields("FF Total Qty Sold", "FF Total Qty Returned");

            if ((NewQuantity + PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned") < 0) then
                Error(MAX_TO_RETURN, PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned")
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseSalesTicket(SalesTicketNo: Code[20])
    begin
    end;
}