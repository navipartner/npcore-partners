codeunit 6150798 "NPR POS Action: Rev. Dir. Sale"
{
    Access = Internal;
    Description = 'POS Action: Reverse Direct Sale';

    var
        ActionDescription: Label 'Refund / Reverse Sale. This action will prompt for a receipt no and recreate the sales with reversed quantity.';
        Title: Label 'Reverse Sale';
        ReceiptPrompt: Label 'Receipt Number';
        ReasonPrompt: Label 'Return Reason';
        ReasonRequired: Label 'You must choose a return reason.';
        NotFound: Label 'Return receipt reference number %1 not found.';
        NOTHING_TO_RETURN: Label 'All items sold on ticket %1  has already been returned. ';
        MAX_TO_RETURN: Label 'Maximum number of items to return is %1.';
        COPIED_RECEIPT: Label 'This sales is copied from %1 and new return items can''t be added to the return sales.';
        QTY_ADJUSTED: Label 'Quantity was adjusted due to previous return sales.';
        POSEntryMgt: Codeunit "NPR POS Entry Management";
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('REVERSE_DIRECT_SALE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('receipt', 'input(labels.title, labels.receiptprompt).respond().cancel(abort);');
            Sender.RegisterWorkflowStep('reason', 'context.PromptForReason && respond();');
            Sender.RegisterWorkflowStep('handle', 'respond();');
            Sender.RegisterWorkflow(true);

            Sender.RegisterOptionParameter('ItemCondition', 'Mint,Used,Not Suitable for Resale', 'Used');
            Sender.RegisterOptionParameter('ObfucationMethod', 'None,MI', 'None');
            Sender.RegisterBooleanParameter('CopyHeaderDimensions', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Setup: Codeunit "NPR POS Setup";
        Context: Codeunit "NPR POS JSON Management";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        POSSession.GetSetup(Setup);

        POSSession.GetSession(POSSession, true);
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        Context.SetContext('PromptForReason', POSAuditProfile."Require Item Return Reason");

        FrontEnd.SetActionContext(ActionCode(), Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ReturnReasonCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'receipt':
                begin
                end;
            'reason':
                begin
                    ReturnReasonCode := SelectReturnReason();
                    JSON.SetContext('ReturnReasonCode', ReturnReasonCode);
                    FrontEnd.SetActionContext(ActionCode(), JSON);
                end;
            'handle':
                begin
                    VerifyReceiptForReversal(Context, FrontEnd);
                    CopySalesReceiptForReversal(Context, POSSession, FrontEnd);
                    POSSession.ChangeViewSale();
                    POSSession.RequestRefreshData();
                end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'receiptprompt', ReceiptPrompt);
        Captions.AddActionCaption(ActionCode(), 'reasonprompt', ReasonPrompt);
    end;

    local procedure VerifyReceiptForReversal(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSEntry: Record "NPR POS Entry";
        SalesTicketNo: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScopeRoot();
        JSON.SetScope('$receipt', StrSubstNo(SettingScopeErr, ActionCode()));
        SalesTicketNo := CopyStr(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(SalesTicketNo));
        if (SalesTicketNo = '') then
            Error('That receipt is not valid for sales reversal.');

        POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfucationMethod'), SalesTicketNo);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Document No.", SalesTicketNo);
        if (not POSEntry.FindFirst()) then
            Error(NotFound, JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())));

        if (IsCompleteReversal(SalesTicketNo)) then
            Error(NOTHING_TO_RETURN, SalesTicketNo);

        OnBeforeReverseSalesTicket(POSEntry."Document No.");
    end;

    local procedure CopySalesReceiptForReversal(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesTicketNo: Code[20];
        ReturnReasonCode: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScopeRoot();
        JSON.SetScope('$receipt', StrSubstNo(SettingScopeErr, ActionCode()));
        SalesTicketNo := CopyStr(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(SalesTicketNo));

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);

        POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfucationMethod'), SalesTicketNo);

        SetCustomerOnReverseSale(SalePOS, SalesTicketNo);

        JSON.SetScopeRoot();

        ReturnReasonCode := CopyStr(JSON.GetString('ReturnReasonCode'), 1, MaxStrLen(ReturnReasonCode));
        ReverseSalesTicket(SalePOS, SalesTicketNo, ReturnReasonCode);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        if not SaleLinePOS.IsEmpty then
            POSSaleLine.SetLast();

        if (ApplyMaxReturnQty(SalePOS, SalesTicketNo)) then
            Message(QTY_ADJUSTED);

        if JSON.GetBooleanParameter('CopyHeaderDimensions') then
            if CopyDimensions(SalePOS, SalesTicketNo) then begin
                POSSale.Refresh(SalePOS);
                POSSale.SetModified();
            end;

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();

        POSSale.RefreshCurrent();
    end;

    procedure ReverseSalesTicket(var SalePOS: Record "NPR POS Sale"; SalesTicketNo: Code[20]; ReturnReasonCode: Code[20])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        SaleLinePOSLineNo: Integer;
    begin
        POSSalesLine.SetRange("Document No.", SalesTicketNo);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);

        SaleLinePOS2.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS2.FindLast() then
            SaleLinePOSLineNo := SaleLinePOS2."Line No." + 10000;

        if POSSalesLine.FindSet(false, false) then
            repeat
                SaleLinePOS.Init();
                SaleLinePOS."Register No." := SalePOS."Register No.";
                SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
                SaleLinePOS.Date := SalePOS.Date;
                SaleLinePOS.Type := SaleLinePOS.Type::Item;
                SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                SaleLinePOS."Line No." := SaleLinePOSLineNo;
                SaleLinePOS.Insert(true);
                SaleLinePOSLineNo := SaleLinePOSLineNo + 10000;

                ReverseAuditInfoToSalesLine(SaleLinePOS, POSSalesLine);

                if ReturnReasonCode <> '' then
                    SaleLinePOS.Validate("Return Reason Code", ReturnReasonCode);
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS."Return Sale Sales Ticket No." := SalesTicketNo;
                SaleLinePOS.Modify(true);
            until POSSalesLine.Next() = 0;
    end;

    procedure ReverseAuditInfoToSalesLine(var SaleLinePOS: Record "NPR POS Sale Line"; POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSSalesLine."POS Entry No.");

        SaleLinePOS.SetSkipUpdateDependantQuantity(true);
        SaleLinePOS.Validate("No.", POSSalesLine."No.");
        SaleLinePOS.Description := POSSalesLine.Description;

        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale then
            SaleLinePOS.Validate(Quantity, -POSSalesLine.Quantity);

        SaleLinePOS."VAT %" := POSSalesLine."VAT %";
        SaleLinePOS."Discount %" := Abs(POSSalesLine."Line Discount %");
        SaleLinePOS."Discount Amount" := -POSSalesLine."Line Discount Amount Excl. VAT";
        SaleLinePOS.Amount := -POSSalesLine."Amount Excl. VAT";
        SaleLinePOS."Currency Amount" := -POSSalesLine."Amount Excl. VAT";
        SaleLinePOS."Amount Including VAT" := -POSSalesLine."Amount Incl. VAT";
        SaleLinePOS."Serial No." := POSSalesLine."Serial No.";
        SaleLinePOS."Discount Type" := POSSalesLine."Discount Type";
        SaleLinePOS."Discount Code" := CopyStr(POSSalesLine."Discount Code", 1, MaxStrLen(SaleLinePOS."Discount Code"));
        SaleLinePOS."Gen. Bus. Posting Group" := POSSalesLine."Gen. Bus. Posting Group";
        SaleLinePOS."Gen. Prod. Posting Group" := POSSalesLine."Gen. Prod. Posting Group";
        SaleLinePOS."VAT Bus. Posting Group" := POSSalesLine."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := POSSalesLine."VAT Prod. Posting Group";
        SaleLinePOS."Unit Cost (LCY)" := POSSalesLine."Unit Cost (LCY)";
        SaleLinePOS.Cost := -(POSSalesLine."Unit Cost" * POSSalesLine.Quantity);
        SaleLinePOS."Unit Cost" := POSSalesLine."Unit Cost";
        SaleLinePOS."Unit Price" := POSSalesLine."Unit Price";
        SaleLinePOS."VAT Base Amount" := -POSSalesLine."VAT Base Amount";
        SaleLinePOS."Variant Code" := POSSalesLine."Variant Code";
        SaleLinePOS."Shortcut Dimension 1 Code" := POSSalesLine."Shortcut Dimension 1 Code";
        SaleLinePOS."Shortcut Dimension 2 Code" := POSSalesLine."Shortcut Dimension 2 Code";
        SaleLinePOS."Dimension Set ID" := POSSalesLine."Dimension Set ID";
    end;

    local procedure SelectReturnReason(): Code[20]
    var
        ReturnReason: Record "Return Reason";
    begin
        if (PAGE.RunModal(PAGE::"NPR TouchScreen: Ret. Reasons", ReturnReason) = ACTION::LookupOK) then
            exit(ReturnReason.Code);

        Error(ReasonRequired);
    end;

    local procedure SetCustomerOnReverseSale(var SalePOS: Record "NPR POS Sale"; SalesTicketNo: Code[20])
    var
        CustomerNo: Code[20];
        POSSale: Codeunit "NPR POS Sale";
        Customer: Record Customer;
        Contact: Record Contact;
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Document No.", SalesTicketNo);
        if POSEntry.IsEmpty then exit;

        POSEntry.SetFilter("Customer No.", '<>%1', '');
        if POSEntry.FindFirst() then
            CustomerNo := POSEntry."Customer No."
        else
            exit;

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
        POSSalesLine: Record "NPR POS Entry Sales Line";
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

    local procedure ApplyMaxReturnQty(CurrentSalePOS: Record "NPR POS Sale"; OriginalSalesTicketNo: Code[20]): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
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
        POSSalesLine: Record "NPR POS Entry Sales Line";
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

    local procedure CopyDimensions(var CurrentSalePOS: Record "NPR POS Sale"; OriginalSalesTicketNo: Code[20]): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        OldDimSetID: Integer;
    begin

        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", OriginalSalesTicketNo);
        if POSEntry.FindLast() then
            if CurrentSalePOS."Dimension Set ID" <> POSEntry."Dimension Set ID" then begin
                OldDimSetID := CurrentSalePOS."Dimension Set ID";

                CurrentSalePOS."Dimension Set ID" := POSEntry."Dimension Set ID";
                CurrentSalePOS."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
                CurrentSalePOS."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
                CurrentSalePOS.Modify();

                if CurrentSalePOS.SalesLinesExist() then
                    CurrentSalePOS.UpdateAllLineDim(CurrentSalePOS."Dimension Set ID", OldDimSetID);

                exit(true);
            end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantityOnReverseSales(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        PosRmaLine: Record "NPR POS RMA Line";
        SaleLinePOSCopy: Record "NPR POS Sale Line";
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
