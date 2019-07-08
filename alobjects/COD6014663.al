codeunit 6014663 "Check POS Balancing"
{
    // NPR5.36/BR  /20170915  CASE 290506 Created object to ensure sequenciality of Sales Tickets in Balancing
    // NPR5.38/BR  /20171212  CASE 292275 Fix for case that the same ticket is used for balancing as for sales ticket


    trigger OnRun()
    begin
    end;

    var
        TextRegisterNotOpen: Label 'Register %1 is not open for sales. Please open the Register and try again.';
        TextRegisterOpen: Label 'Register %1 was opened in another session since this Sales Ticket was created. Please create a new sale or restart the application. If there are sales lines on the ticket, you can save the sale first and retrieve it to the new ticket.';
        TextRegisterClosed: Label 'Register %1 was closed since this Sales Ticket was created. Please create a new sale or restart the application. If there are sales lines on the ticket, you can save the sale first and retrieve it to the new ticket.';

    local procedure CheckBalancing(SalePOS: Record "Sale POS";IncludeTicketNo: Boolean)
    var
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
    begin
        if SalePOS."Sales Ticket No." = '' then
          exit;
        if Register.Get(SalePOS."Register No.") then begin
          if Register."Balanced on Sales Ticket" = '' then
            exit;
          //Check if the Register was balanced after the current Sales Ticket No. was determined
          //-NPR5.38 [292275]
          //IF Register."Balanced on Sales Ticket" > SalePOS."Sales Ticket No." THEN
          if Register."Opened on Sales Ticket" >= SalePOS."Sales Ticket No." then
            Error(TextRegisterOpen,Register."Register No.");
          if (IncludeTicketNo and (Register."Balanced on Sales Ticket" = SalePOS."Sales Ticket No.")) or
             (Register."Balanced on Sales Ticket" > SalePOS."Sales Ticket No.") then
          //+NPR5.38 [292275]
            Error(TextRegisterClosed,Register."Register No.",Register."Balanced on Sales Ticket");
        end;
    end;

    local procedure CheckRegisterStatus(SalePOS: Record "Sale POS")
    var
        Register: Record Register;
        AuditRoll: Record "Audit Roll";
    begin
        if SalePOS."Sales Ticket No." = '' then
          exit;
        if Register.Get(SalePOS."Register No.") then begin
          if Register."Balanced on Sales Ticket" = '' then
            exit;
          //Check if the Register is being balanced
          if Register.Status <> Register.Status::Ekspedition then
            Error(TextRegisterNotOpen,Register."Register No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014630, 'OnBeforeDebitSale', '', true, true)]
    local procedure OnBeforeDebitSaleCheckBalancingAndStatus(SalePOS: Record "Sale POS")
    begin
        //-NPR5.38 [292275]
        //CheckBalancing(SalePOS);
        CheckBalancing(SalePOS,true);
        //+NPR5.38 [292275]
        CheckRegisterStatus(SalePOS);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014630, 'OnBeforeGotoPayment', '', true, true)]
    local procedure "OnBeforeGotoPaymentCheckBalancingAnd Status"(SalePOS: Record "Sale POS")
    begin
        //-NPR5.38 [292275]
        //CheckBalancing(SalePOS);
        CheckBalancing(SalePOS,true);
        //+NPR5.38 [292275]
        CheckRegisterStatus(SalePOS);
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnBeforeValidateEvent', 'Salesperson Code', true, true)]
    local procedure OnAfterValidateSalesPersonOnSalePOSCheckBalancing(var Rec: Record "Sale POS";var xRec: Record "Sale POS";CurrFieldNo: Integer)
    begin
        if (Rec."Salesperson Code" <> '') and (xRec."Salesperson Code" = '') then
          //-NPR5.38 [292275]
          //CheckBalancing(REc);
          CheckBalancing(Rec,false);
          //+NPR5.38 [292275]
    end;
}

