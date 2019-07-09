codeunit 6150787 "POS Action - Print Receipt"
{
    // NPR5.38/MMV /20171204 CASE 298618 Invoke sales receipt function directly with Force parameter true to bypass disabled cash register print.
    // NPR5.40/MMV /20180319 CASE 304639 Support for pos entry receipt.
    //                                   Removed concept of large debit receipt reprint
    // NPR5.41/MMV /20180426 CASE 313019 Match on more robust type.
    // NPR5.43/THRO/20180620 CASE 319257 Parameters setting for printing Member Card, Ticket, Credit voucher and Terminal Receipt
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring
    // NPR5.48/MMV /20181026 CASE 318028 French certification
    // NPR5.50/ALST/20190527 CASE 353191 able to setup printing the last receipt to output the last balancing receipt as well


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for printing a receipt for the current or selected transaction.';
        TxtNoReceiptFound: Label 'No receipts has been printed from this register today.';
        CurrentRegisterNo: Code[10];

    local procedure ActionCode(): Text
    begin
        exit('PRINT_RECEIPT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3'); //-NPR5.49 [353191]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflow(false);

            //-NPR5.50
            //RegisterOptionParameter('Setting','Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,'Last Receipt');
            RegisterOptionParameter('Setting','Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,Last Receipt and Balance,Last Receipt and Balance Large','Last Receipt');
            //+NPR5.50
            //-NPR5.43 [319257]
            RegisterBooleanParameter('Print Tickets',false);
            RegisterBooleanParameter('Print Memberships',false);
            RegisterBooleanParameter('Print Credit Voucher',false);
            RegisterBooleanParameter('Print Terminal Receipt',false);
            //+NPR5.43 [319257]
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large";
        POSSetup: Codeunit "POS Setup";
        NPRetailSetup: Record "NP Retail Setup";
        SalesTicketNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        Setting := JSON.GetInteger('Setting',true);

        POSSession.GetSetup(POSSetup);
        CurrentRegisterNo := POSSetup.Register();

        //-NPR5.40 [304639]
        // CASE Setting OF
        //  Setting::"Choose Receipt",
        //  Setting::"Choose Receipt Large":
        //    ChooseReceipt(Setting);
        //  Setting::"Last Receipt",
        //  Setting::"Last Receipt Large":
        //    LastReceipt(Setting);
        // END;

        NPRetailSetup.Get;

        case Setting of
          Setting::"Choose Receipt",
          Setting::"Choose Receipt Large":
            if NPRetailSetup."Advanced Posting Activated" then
              SalesTicketNo := ChooseReceiptPOSEntry(Setting)
            else
              SalesTicketNo := ChooseReceiptAuditRoll(Setting);

          Setting::"Last Receipt",
          Setting::"Last Receipt Large":
            if NPRetailSetup."Advanced Posting Activated" then
              SalesTicketNo := LastReceiptPOSEntry(Setting)
            else
              SalesTicketNo := LastReceiptAuditRoll(Setting);
          //-NPR5.50
          Setting::"Last Receipt and Balance",
          Setting::"Last Receipt and Balance Large":
            SalesTicketNo := LastReceiptPOSEntry(Setting);
          //+NPR5.50
        end;
        //+NPR5.40 [304639]
        //-NPR5.43 [319257]
        if SalesTicketNo <> '' then
          AdditionalPrints(CurrentRegisterNo,SalesTicketNo,JSON);
        //+NPR5.43 [319257]

        Handled := true;
    end;

    local procedure PrintReceiptAuditRoll(var AuditRoll: Record "Audit Roll";Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large")
    var
        RecRef: RecordRef;
        RetailReportSelMgt: Codeunit "Retail Report Selection Mgt.";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReportSelectionRetail: Record "Report Selection Retail";
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        //-NPR5.40 [304639]
        // IF Setting IN [Setting::"Last Receipt Large", Setting::"Choose Receipt Large"] THEN BEGIN //Large format
        //  IF AuditRoll.Type = AuditRoll.Type::"Debit Sale" THEN BEGIN
        //    AuditRoll.SETRANGE( "Sales Ticket No.", AuditRoll."Sales Ticket No." );
        //    AuditRoll.SETFILTER( "Allocated No.",'<>%1','' );
        //    AuditRoll.FINDFIRST;
        //    SalesInvoiceHeader.GET(AuditRoll."Allocated No.");
        //    SalesInvoiceHeader.SETFILTER("No.",'%1',AuditRoll."Allocated No.");
        //    SalesInvoiceHeader.PrintRecords(FALSE);
        //  END ELSE
        //    AuditRoll.PrintReceiptA4(FALSE);
        // END ELSE BEGIN //Regular format
        //  IF AuditRoll.Type = AuditRoll.Type::"Debit Sale" THEN BEGIN
        //    RecRef.GETTABLE(AuditRoll);
        //    RetailReportSelMgt.SetRegisterNo(CurrentRegisterNo);
        //    RetailReportSelMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Customer Sales Receipt");
        //  END ELSE
        //    StdCodeunitCode.PrintReceipt(AuditRoll, TRUE)
        // END;

        //-NPR5.41 [313019]
        //IF AuditRoll.Type = AuditRoll.Type::"Debit Sale" THEN BEGIN
        if AuditRoll."Sale Type" = AuditRoll."Sale Type"::"Debit Sale" then begin
        //+NPR5.41 [313019]
          RecRef.GetTable(AuditRoll);
          RetailReportSelMgt.SetRegisterNo(CurrentRegisterNo);
          RetailReportSelMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Customer Sales Receipt");
          exit;
        end;

        if Setting in [Setting::"Last Receipt Large", Setting::"Choose Receipt Large"] then
          AuditRoll.PrintReceiptA4(false)
        else
          StdCodeunitCode.PrintReceipt(AuditRoll, true);
        //+NPR5.40 [304639]
    end;

    local procedure ChooseReceiptAuditRoll(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large"): Code[20]
    var
        AuditRoll: Record "Audit Roll";
        AuditRollPage: Page "Audit Roll";
    begin
        AuditRoll.SetFilter(Type, '<>%1&<>%2', AuditRoll.Type::Cancelled, AuditRoll.Type::"Open/Close");
        AuditRollPage.LookupMode(true);
        AuditRollPage.SetTableView(AuditRoll);
        if AuditRollPage.RunModal = ACTION::LookupOK then begin
          AuditRollPage.GetRecord(AuditRoll);
          AuditRoll.SetRecFilter();
          PrintReceiptAuditRoll(AuditRoll, Setting);
          //-NPR5.43 [319257]
          exit(AuditRoll."Sales Ticket No.");
          //+NPR5.43 [319257]
        end;
    end;

    local procedure LastReceiptAuditRoll(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large"): Code[20]
    var
        AuditRoll: Record "Audit Roll";
    begin
        AuditRoll.SetCurrentKey("Sales Ticket No.", Type);
        AuditRoll.SetRange("Register No.", CurrentRegisterNo);
        AuditRoll.SetRange("Sale Date", Today);
        AuditRoll.SetFilter(Type, '<>%1&<>%2', AuditRoll.Type::Cancelled, AuditRoll.Type::"Open/Close");
        if not AuditRoll.FindLast then begin
          Message(TxtNoReceiptFound);
          exit('');
        end;
        AuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        PrintReceiptAuditRoll(AuditRoll, Setting);
        //-NPR5.43 [319257]
        exit(AuditRoll."Sales Ticket No.");
        //+NPR5.43 [319257]
    end;

    local procedure PrintReceiptPOSEntry(var POSEntry: Record "POS Entry";Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large")
    begin
        //-NPR5.48 [318028]
        //-NPR5.40 [304639]
        // POSEntry.SETRECFILTER;
        // RecRef.GETTABLE(POSEntry);
        // RetailReportSelectionMgt.SetRegisterNo(POSEntry."POS Unit No.");
        //
        // IF POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale" THEN BEGIN
        //  RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
        //  EXIT;
        // END;
        //
        // IF Setting IN [Setting::"Last Receipt Large", Setting::"Choose Receipt Large"] THEN
        //  RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)")
        // ELSE
        //  RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
        //+NPR5.40 [304639]
        //+NPR5.48 [318028]
    end;

    local procedure ChooseReceiptPOSEntry(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large"): Code[20]
    var
        POSEntry: Record "POS Entry";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
        if PAGE.RunModal(0, POSEntry) = ACTION::LookupOK then begin
          //-NPR5.48 [318028]
          //PrintReceiptPOSEntry(POSEntry, Setting);
          POSEntryManagement.PrintEntry(POSEntry, Setting in [Setting::"Choose Receipt Large", Setting::"Last Receipt Large"]);
          //+NPR5.48 [318028]
          exit(POSEntry."Document No.");
        end;
    end;

    local procedure LastReceiptPOSEntry(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large"): Code[20]
    var
        POSEntry: Record "POS Entry";
        POSBalanceEntry: Record "POS Entry";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin
        POSEntry.SetRange("POS Unit No.", CurrentRegisterNo);
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");

        if POSEntry.FindLast then begin
          //-NPR5.48 [318028]
          //PrintReceiptPOSEntry(POSEntry, Setting);
          POSEntryManagement.PrintEntry(POSEntry, Setting in [Setting::"Choose Receipt Large", Setting::"Last Receipt Large"]);
          //+NPR5.48 [318028]
          //-NPR5.50
          if Setting in [Setting::"Last Receipt and Balance",Setting::"Last Receipt and Balance Large"] then begin
            POSBalanceEntry.CopyFilters(POSEntry);
            POSBalanceEntry.SetRange("Entry Type", POSEntry."Entry Type"::Balancing);
          if POSBalanceEntry.FindLast then
            POSEntryManagement.PrintEntry(POSBalanceEntry, Setting = Setting::"Last Receipt and Balance Large");
          end;
          //+NPR5.50
          exit(POSEntry."Document No.");
        end;
    end;

    local procedure AdditionalPrints(RegisterNo: Code[10];SalesTicketNo: Code[20];var JSON: Codeunit "POS JSON Management")
    var
        AuditRoll: Record "Audit Roll";
        TMTicketManagement: Codeunit "TM Ticket Management";
        MMMemberRetailIntegration: Codeunit "MM Member Retail Integration";
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        //-NPR5.43 [319257]
        if SalesTicketNo = '' then
          exit;

        if JSON.GetBoolean('Print Tickets',true) then
          TMTicketManagement.PrintTicketFromSalesTicketNo(SalesTicketNo);

        if JSON.GetBoolean('Print Memberships',true) then
          MMMemberRetailIntegration.PrintMembershipOnEndOfSales(SalesTicketNo);

        if JSON.GetBoolean('Print Credit Voucher',true) then begin
          AuditRoll.SetRange("Register No.",CurrentRegisterNo);
          AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
          if AuditRoll.FindFirst then
            StdCodeunitCode.PrintCreditGiftVoucher(AuditRoll);
        end;

        if JSON.GetBoolean('Print Terminal Receipt',true) then begin
        //-NPR5.46 [290734]
        //  CreditCardTransaction.RESET;
        //  CreditCardTransaction.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
        //  CreditCardTransaction.FILTERGROUP := 2;
        //  CreditCardTransaction.SETRANGE("Register No.",RegisterNo);
        //  CreditCardTransaction.SETRANGE("Sales Ticket No.",SalesTicketNo);
        //  CreditCardTransaction.SETRANGE(Type,0);
        //
        //  CreditCardTransaction.FILTERGROUP := 0;
        //  IF CreditCardTransaction.FIND('-') THEN
        //    CreditCardTransaction.PrintTerminalReceipt(FALSE);
          EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
          EFTTransactionRequest.SetRange("Register No.", RegisterNo);
          if EFTTransactionRequest.FindSet then
            repeat
              EFTTransactionRequest.PrintReceipts(true);
            until EFTTransactionRequest.Next = 0;
        //+NPR5.46 [290734]
        end;
        //+NPR5.43 [319257]
    end;
}

