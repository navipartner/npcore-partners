codeunit 6150798 "POS Action - Reverse Sale"
{
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.38/ANEN /2017-12-11/296724 Added customer no on reverse
    // NPR5.40/MMV /20180115 Added event for acting on sale reverse and validating external integrations.
    // NPR5.49/TSA /20190218 CASE 342244 Added DeObfucation of salesticket number - fraud protection
    // NPR5.49/TSA /20190319 CASE 342090 Added first check for full return
    // NPR5.49/TSA /20190319 CASE 342090 Fixed a filtering issue
    // NPR5.50/TSA /20190502 CASE 353680 Quantity Return Management is only supported when POS Entry is enabled
    // NPR5.53/ALPO/20191218 CASE 382911 'DeObfuscateTicketNo' function moved to CU 6150629 to avoid code duplication
    // NPR5.53/ALPO/20191218 CASE 387339 The sub-total on the POS Sales screen was not updated when using the POS Action.


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
        POSEntryMgt: Codeunit "POS Entry Management";

    local procedure ActionCode(): Text
    begin
        exit ('REVERSE_SALE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep ('receipt', 'input(labels.title, labels.receiptprompt).respond().cancel(abort);');
            RegisterWorkflowStep ('reason',  'context.PromptForReason && respond();');
            RegisterWorkflowStep ('handle', 'respond();');
            RegisterWorkflow (true);

            RegisterOptionParameter ('ItemCondition', 'Mint,Used,Not Suitable for Resale', 'Used');

            //-NPR5.49 [342244]
            RegisterOptionParameter ('ObfucationMethod', 'None,MI', 'None');
            //+NPR5.49 [342244]

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Setup: Codeunit "POS Setup";
        RetailSetup: Record "Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        // TODO: Remove this verification and start the permission & security workflow instead
        POSSession.GetSetup (Setup);
        SalespersonPurchaser.Get (Setup.Salesperson);

        RetailSetup.Get ();
        Context.SetContext ('PromptForReason', RetailSetup."Reason for Return Mandatory");

        case SalespersonPurchaser."Reverse Sales Ticket" of
          SalespersonPurchaser."Reverse Sales Ticket"::No : Error (NotAllowed, SalespersonPurchaser.Name);
        end;

        FrontEnd.SetActionContext (ActionCode, Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ReturnReasonCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        case WorkflowStep of
          'receipt' :
            begin
              //FrontEnd.PauseWorkflow();
              //VerifyReceiptForReversal (Context, POSSession, FrontEnd);
              //FrontEnd.ResumeWorkflow();
            end;
          'reason'  :
            begin
              //xx FrontEnd.PauseWorkflow();
              ReturnReasonCode := SelectReturnReason (Context, POSSession, FrontEnd);
              JSON.SetContext ('ReturnReasonCode', ReturnReasonCode);
              FrontEnd.SetActionContext (ActionCode, JSON);
              //xx FrontEnd.ResumeWorkflow();
            end;
          'handle'  :
            begin
              VerifyReceiptForReversal (Context, POSSession, FrontEnd);
              CopySalesReceiptForReversal (Context, POSSession, FrontEnd);
              POSSession.ChangeViewSale ();
              POSSession.RequestRefreshData ();
            end;
        end;
        //message ('Now in workflowstep %1 have data %2', WorkflowStep, Context.ToString ());

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'receiptprompt', ReceiptPrompt);
        Captions.AddActionCaption (ActionCode, 'reasonprompt', ReasonPrompt);
    end;

    local procedure VerifyReceiptForReversal(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        AuditRoll: Record "Audit Roll";
        SalesTicketNo: Code[20];
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.SetScope ('/', true);
        JSON.SetScope ('$receipt', true);
        SalesTicketNo := JSON.GetString ('input', true);
        if (SalesTicketNo = '') then
          Error ('That receipt is not valid for sales reversal.');

        //-NPR5.49 [342244]
        // AuditRoll.SETRANGE ("Sales Ticket No.", SalesTicketNo);
        // AuditRoll.FINDFIRST ();

        POSEntryMgt.DeObfuscateTicketNo (JSON.GetIntegerParameter ('ObfucationMethod', false), SalesTicketNo);
        AuditRoll.SetRange ("Sales Ticket No.", SalesTicketNo);
        if (not AuditRoll.FindFirst ()) then
          Error (NotFound, JSON.GetString ('input', true));
        //+NPR5.49 [342244]

        //-NPR5.49 [342090]
        //Validate for duplicate reverse sales
        if (IsCompleteReversal (SalesTicketNo)) then
          Error (NOTHING_TO_RETURN, SalesTicketNo);
        //+NPR5.49 [342090]

        //-NPR5.40 [293106]
        OnBeforeReverseSalesTicket(AuditRoll."Sales Ticket No.");
        //+NPR5.40 [293106]
    end;

    local procedure CopySalesReceiptForReversal(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        RetailSalesCode: Codeunit "Retail Sales Code";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        RetailSetup: Record "Retail Setup";
        SalesTicketNo: Code[20];
        ReturnReasonCode: Code[20];
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.SetScope ('/', true);
        JSON.SetScope ('$receipt', true);
        SalesTicketNo := JSON.GetString ('input', true);

        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);
        POSSession.GetSaleLine (POSSaleLine);

        //-NPR5.49 [342244]
        POSEntryMgt.DeObfuscateTicketNo (JSON.GetIntegerParameter ('ObfucationMethod', false), SalesTicketNo);
        //+NPR5.49 [342244]

        //-NPR5.38 [296724]
        SetCustomerOnReverseSale(SalePOS, SalesTicketNo);
        //+NPR5.38 [296724]

        RetailSalesCode.ReverseSalesTicket2 (SalePOS, SalesTicketNo);

        SaleLinePOS.SetRange ("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange ("Sales Ticket No.", SalePOS."Sales Ticket No.");

        RetailSetup.Get ();
        if (RetailSetup."Reason for Return Mandatory") then begin
          JSON.SetScope ('/', true);
          ReturnReasonCode := JSON.GetString ('ReturnReasonCode', true);
          SaleLinePOS.ModifyAll("Return Reason Code", ReturnReasonCode);
        end;

        SaleLinePOS.ModifyAll("Return Sale Sales Ticket No.", SalesTicketNo);
        //-NPR5.53 [387339]
        if not SaleLinePOS.IsEmpty then
          POSSaleLine.SetLast();
        //+NPR5.53 [387339]

        //-NPR5.49 [342090]
        if (ApplyMaxReturnQty (SalePOS, SalesTicketNo)) then
          Message (QTY_ADJUSTED);
        //+NPR5.49 [342090]

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine ();

        POSSale.RefreshCurrent ();
    end;

    local procedure SelectReturnReason(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management"): Code[20]
    var
        RetailSetup: Record "Retail Setup";
        ReturnReason: Record "Return Reason";
    begin

        if (PAGE.RunModal(PAGE::"Touch Screen - Return Reasons", ReturnReason) = ACTION::LookupOK) then
          exit (ReturnReason.Code);

        Error (ReasonRequired);
    end;

    local procedure SetCustomerOnReverseSale(var SalePOS: Record "Sale POS";SalesTicketNo: Code[20])
    var
        AuditRoll: Record "Audit Roll";
        CustomerNo: Code[20];
        POSSale: Codeunit "POS Sale";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        //-NPR5.38 [296724]
        AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);

        if AuditRoll.IsEmpty then exit;
        AuditRoll.FindSet;
        repeat
          CustomerNo := AuditRoll."Customer No.";
        until ( (0 = AuditRoll.Next) or (CustomerNo <> '') );

        if Customer.Get(CustomerNo) then begin
          SalePOS.Validate("Customer No.", Customer."No.");
        end else begin
          if Contact.Get(CustomerNo) then begin
            SalePOS.Validate("Customer Type",SalePOS."Customer Type"::Cash);
            SalePOS.Validate("Customer No.",Contact."No.");
          end;
        end;


        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true,false);
    end;

    local procedure IsCompleteReversal(SalesTicketNo: Code[20]): Boolean
    var
        TmpPosRmaLine: Record "POS RMA Line";
        PosRmaLine: Record "POS RMA Line";
        POSSalesLine: Record "POS Sales Line";
        ItemQty: Decimal;
    begin

        //-NPR5.49 [342090]
        PosRmaLine.SetFilter ("Sales Ticket No.", '=%1', SalesTicketNo);
        if (PosRmaLine.IsEmpty ()) then
          exit (false); // No return sales for this register yet

        POSSalesLine.SetFilter ("Document No.", '=%1', SalesTicketNo);
        POSSalesLine.SetFilter (Type, '=%1', POSSalesLine.Type::Item);

        if (POSSalesLine.FindSet ()) then begin
          repeat
            TmpPosRmaLine."Sales Ticket No." := SalesTicketNo;
            TmpPosRmaLine."Returned Item No." := POSSalesLine."No.";
            TmpPosRmaLine.CalcFields ("FF Total Qty Sold", "FF Total Qty Returned");
            ItemQty += TmpPosRmaLine."FF Total Qty Sold" + TmpPosRmaLine."FF Total Qty Returned";
          until (POSSalesLine.Next () = 0);
        end;

        // When returned quantity is equal to (or exceeds) sold quantity, all items have been returned
        exit (ItemQty <= 0);
        //+NPR5.49 [342090]
    end;

    local procedure ApplyMaxReturnQty(CurrentSalePOS: Record "Sale POS";OriginalSalesTicketNo: Code[20]): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        AdjustedQty: Decimal;
        QtyIsAdjusted: Boolean;
    begin

        //-NPR5.49 [342090]
        SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', CurrentSalePOS."Sales Ticket No.");
        if (SaleLinePOS.FindSet ()) then begin
          repeat
            if ((SaleLinePOS.Quantity < 0) and (SaleLinePOS.Type = SaleLinePOS.Type::Item) and (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale)) then begin
              //-NPR5.50 [353680]
              // AdjustedQty := GetRemainingQtyToReturn (OriginalSalesTicketNo, SaleLinePOS."Line No.") * -1;
              AdjustedQty := GetRemainingQtyToReturn (OriginalSalesTicketNo, Abs(SaleLinePOS.Quantity), SaleLinePOS."Line No.") * -1;
              //+NPR5.50 [353680]
              if (AdjustedQty <> SaleLinePOS.Quantity) then begin
                SaleLinePOS.Validate (Quantity, AdjustedQty);
                SaleLinePOS.Modify ();
                QtyIsAdjusted := true;
              end;
            end;
          until (SaleLinePOS.Next () = 0);
        end;

        exit (QtyIsAdjusted);
        //+NPR5.49 [342090]
    end;

    local procedure GetRemainingQtyToReturn(SalesTicketNo: Code[20];OriginalQty: Decimal;LineNo: Integer) MaxQuantity: Decimal
    var
        POSSalesLine: Record "POS Sales Line";
        PosRmaLine: Record "POS RMA Line";
    begin

        //-NPR5.49 [342090]
        POSSalesLine.SetFilter ("Document No.", '=%1', SalesTicketNo);
        POSSalesLine.SetFilter ("Line No.", '=%1', LineNo);
        if (not POSSalesLine.FindFirst ()) then
          //-NPR5.50 [353680]
          // EXIT (0); // Original sales was not found, 0 is max to return
          exit (OriginalQty);
          //+NPR5.50 [353680]

        MaxQuantity := POSSalesLine.Quantity;

        // Check previous returns
        PosRmaLine.SetFilter ("Sales Ticket No.", '=%1', SalesTicketNo);
        PosRmaLine.SetFilter ("Returned Item No.", '=%1', POSSalesLine."No.");
        PosRmaLine.SetFilter ("Line No. Filter", '=%1', LineNo);

        if (PosRmaLine.FindFirst ()) then begin
          PosRmaLine.CalcFields ("FF Total Qty Sold", "FF Total Qty Returned");
          if (PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned" < MaxQuantity) then
            MaxQuantity := PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned";
        end;

        // Either sales ticket is a return order or we have over returned already.
        if (MaxQuantity < 0) then
          MaxQuantity := 0;

        //+NPR5.49 [342090]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeSetQuantity', '', true, true)]
    local procedure OnBeforeSetQuantityOnReverseSales(var Sender: Codeunit "POS Sale Line";var SaleLinePOS: Record "Sale Line POS";var NewQuantity: Decimal)
    var
        PosRmaLine: Record "POS RMA Line";
        SaleLinePOSCopy: Record "Sale Line POS";
    begin

        //-NPR5.49 [342090]
        // Publisher in Codeunit POS Sale Line
        // This subscriber is intended to prevent returning more items them originally sold
        if (NewQuantity >= 0) then
          exit;

        if (SaleLinePOS."Sale Type" <> SaleLinePOS."Sale Type"::Sale)
          then exit;

        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
          exit;

        // if this line is missing the sales ticket reference, all the other lines must also not have have a reference
        if (SaleLinePOS."Return Sale Sales Ticket No." = '') then begin
          SaleLinePOSCopy.SetFilter ("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
          SaleLinePOSCopy.SetFilter ("Sale Type", '=%1', SaleLinePOSCopy."Sale Type"::Sale);
          SaleLinePOSCopy.SetFilter (Type, '=%1', SaleLinePOSCopy.Type::Item);
          SaleLinePOSCopy.SetFilter (Quantity, '<%1', 0);
          //-NPR5.49 [342090]
          //SaleLinePOSCopy.SETFILTER ("Return Sale Sales Ticket No.", '=%1', '');
          SaleLinePOSCopy.SetFilter ("Return Sale Sales Ticket No.", '<>%1', '');
          //+NPR5.49 [342090]
          if (not SaleLinePOSCopy.IsEmpty ()) then
            Error (COPIED_RECEIPT, SaleLinePOS."Sales Ticket No.");
          exit;
        end;

        PosRmaLine.SetFilter ("Sales Ticket No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
        PosRmaLine.SetFilter ("Returned Item No.", '=%1', SaleLinePOS."No.");

        if (PosRmaLine.FindFirst ()) then begin
          PosRmaLine.CalcFields ("FF Total Qty Sold", "FF Total Qty Returned");

          if ((NewQuantity + PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned") < 0) then
            Error (MAX_TO_RETURN, PosRmaLine."FF Total Qty Sold" + PosRmaLine."FF Total Qty Returned")
        end;
        //+NPR5.49 [342090]

        // SaleLinePOS.
    end;

    local procedure "--- Event Publisher"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReverseSalesTicket(SalesTicketNo: Code[20])
    begin
        //-NPR5.40 [293106]
        //+NPR5.40 [293106]
    end;
}

