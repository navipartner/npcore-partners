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
    // NPR5.51/TSA /20190708 CASE 360453 Added seperate option for re-printing last balancing receipt
    // NPR5.53/ALPO/20191112 CASE 362878 Parameters to control view and additional filter of POS Entries to choose receipt from
    //                                    - Function ChooseReceiptPOSEntry() additional call paramenters: ListTableView:Text, FilterOn:Option, FilterEntityCode:Code[20]
    // NPR5.53/ALPO/20191218 CASE 382911 New options to print tax free voucher and manually specify receipt to be printed
    // NPR5.53/ALPO/20200107 CASE 380319 Print retail vouchers just as old credit vouchers


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for printing a receipt for the current or selected transaction.';
        TxtNoReceiptFound: Label 'No receipts has been printed from this register today.';
        NPRetailSetup: Record "NP Retail Setup";
        CurrentRegisterNo: Code[10];
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        EnterReceiptNoLbl: Label 'Enter Receipt Number';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_RECEIPT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.7');  //NPR5.53 [382911]
        //EXIT('1.6');  //NPR5.53 [362878]
        //EXIT('1.4');  //NPR5.51 [360453]
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
            //-NPR5.53 [382911]
            RegisterWorkflowStep('ManualReceiptNo',
              'if ((param.SelectionDialogType == param.SelectionDialogType["TextField"]) && ' +
              '    ((param.Setting == param.Setting["Choose Receipt"]) || (param.Setting == param.Setting["Choose Receipt Large"])))' +
              '{input({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);}');
            RegisterWorkflowStep('FinishWorkflow','respond();');
            //+NPR5.53 [382911]
            RegisterWorkflow(false);

            //-NPR5.50
            //RegisterOptionParameter('Setting','Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,'Last Receipt');
            //-NPR5.51 [360453]
            // RegisterOptionParameter('Setting','Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,Last Receipt and Balance,Last Receipt and Balance Large','Last Receipt');
            RegisterOptionParameter('Setting','Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,Last Receipt and Balance,Last Receipt and Balance Large,Last Balance,Last Balance Large','Last Receipt');
            //+NPR5.50
            //+NPR5.51 [360453]

            //-NPR5.43 [319257]
            RegisterBooleanParameter('Print Tickets',false);
            RegisterBooleanParameter('Print Memberships',false);
            RegisterBooleanParameter('Print Credit Voucher',false);
            RegisterBooleanParameter('Print Terminal Receipt',false);
            //+NPR5.43 [319257]
            //-NPR5.53 [362878]
            RegisterOptionParameter('ReceiptListFilter','None,Current POS Store,Current POS Unit,Current Salesperson','None');
            RegisterTextParameter('ReceiptListView','SORTING(Entry No.) ORDER(Descending)');
            //+NPR5.53 [362878]
            //-NPR5.53 [382911]
            RegisterOptionParameter('SelectionDialogType','TextField,List','List');
            RegisterOptionParameter('ObfuscationMethod','None,MI','None');
            RegisterBooleanParameter('Print Tax Free Voucher',false);
            //+NPR5.53 [382911]
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        //-NPR5.53 [382911]
        Captions.AddActionCaption(ActionCode(),'Title',EnterReceiptNoLbl);
        //+NPR5.53 [382911]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSEntryMgt: Codeunit "POS Entry Management";
        POSSetup: Codeunit "POS Setup";
        POSStore: Record "POS Store";
        Salesperson: Record "Salesperson/Purchaser";
        SalesTicketNo: Code[20];
        FilterEntityCode: Code[20];
        PresetTableView: Text;
        SelectionDialogType: Option TextField,List;
        Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large","Last Balance","Last Balance Large";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        Setting := JSON.GetInteger('Setting',true);
        //-NPR5.53 [362878]
        ReceiptListFilterOption := JSON.GetIntegerParameter('ReceiptListFilter',false);
        PresetTableView := JSON.GetStringParameter('ReceiptListView',false);
        //+NPR5.53 [362878]

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
        //-NPR5.53 [362878]
        if (ReceiptListFilterOption < 0) or (ReceiptListFilterOption > ReceiptListFilterOption::Salesperson) then
          ReceiptListFilterOption := ReceiptListFilterOption::"POS Unit";
        case ReceiptListFilterOption of
          ReceiptListFilterOption::"POS Store": begin
            POSSetup.GetPOSStore(POSStore);
            FilterEntityCode := POSStore.Code;
          end;
          ReceiptListFilterOption::"POS Unit":
            FilterEntityCode := CurrentRegisterNo;
          ReceiptListFilterOption::Salesperson: begin
            POSSetup.GetSalespersonRecord(Salesperson);
            FilterEntityCode := Salesperson.Code;
          end;
        end;
        //+NPR5.53 [362878]

        SalesTicketNo := '';  //NPR5.53 [382911]
        case Setting of
          Setting::"Choose Receipt",
          Setting::"Choose Receipt Large":
          //-NPR5.53 [382911]
          begin
            SelectionDialogType := JSON.GetIntegerParameter('SelectionDialogType',true);
            if not (SelectionDialogType in [SelectionDialogType::TextField,SelectionDialogType::List]) then
              SelectionDialogType := SelectionDialogType::List;
            case SelectionDialogType of
              SelectionDialogType::TextField: begin
                SalesTicketNo := CopyStr(GetInput(JSON,'ManualReceiptNo'),1,MaxStrLen(SalesTicketNo));
                POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfuscationMethod',true),SalesTicketNo);
              end;
            end;
          //+NPR5.53 [382911]
            if NPRetailSetup."Advanced Posting Activated" then
              //SalesTicketNo := ChooseReceiptPOSEntry(Setting)  //NPR5.53 [362878]-revoked
              //SalesTicketNo := ChooseReceiptPOSEntry(Setting,PresetTableView,ReceiptListFilterOption,FilterEntityCode)  //NPR5.53 [362878]  //NPR5.53 [382911]-revoked
              SalesTicketNo := ChooseReceiptPOSEntry(Setting,PresetTableView,ReceiptListFilterOption,FilterEntityCode,SalesTicketNo)  //NPR5.53 [382911]
            else
              //SalesTicketNo := ChooseReceiptAuditRoll(Setting);  //NPR5.53 [382911]-revoked
          //-NPR5.53 [382911]
              SalesTicketNo := ChooseReceiptAuditRoll(Setting,SalesTicketNo);
          end;
          //+NPR5.53 [382911]

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

          //-NPR5.51 [360453]
          Setting::"Last Balance",
          Setting::"Last Balance Large" :
            if NPRetailSetup."Advanced Posting Activated" then
              SalesTicketNo := LastBalancePOSEntry (Setting = Setting::"Last Balance Large");
          //+NPR5.51 [360453]
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

    local procedure ChooseReceiptAuditRoll(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large";SalesTicketNo: Code[20]): Code[20]
    var
        AuditRoll: Record "Audit Roll";
        AuditRollPage: Page "Audit Roll";
    begin
        AuditRoll.SetFilter(Type, '<>%1&<>%2', AuditRoll.Type::Cancelled, AuditRoll.Type::"Open/Close");
        //-NPR5.53 [382911]
        if SalesTicketNo <> '' then begin
          AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
          AuditRoll.FindFirst;
        end else begin
        //+NPR5.53 [382911]
          AuditRollPage.LookupMode(true);
          AuditRollPage.SetTableView(AuditRoll);
          if AuditRollPage.RunModal = ACTION::LookupOK then begin
            AuditRollPage.GetRecord(AuditRoll);
        //-NPR5.53 [382911]
          end else
            exit('');
        end;
        //+NPR5.53 [382911]
        AuditRoll.SetRecFilter();
        PrintReceiptAuditRoll(AuditRoll, Setting);
        //-NPR5.43 [319257]
        exit(AuditRoll."Sales Ticket No.");
        //+NPR5.43 [319257]
        //END;  //NPR5.53 [382911]-revoked
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

    local procedure ChooseReceiptPOSEntry(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large";ListTableView: Text;FilterOn: Option;FilterEntityCode: Code[20];SalesTicketNo: Code[20]): Code[20]
    var
        POSEntry: Record "POS Entry";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin
        //-NPR5.53 [362878]
        POSEntry.Reset;
        if ListTableView <> '' then
          POSEntry.SetView(ListTableView);
        case FilterOn of
          ReceiptListFilterOption::"POS Store":
            POSEntry.SetRange("POS Store Code",FilterEntityCode);
          ReceiptListFilterOption::"POS Unit":
            POSEntry.SetRange("POS Unit No.",FilterEntityCode);
          ReceiptListFilterOption::Salesperson:
            POSEntry.SetRange("Salesperson Code",FilterEntityCode);
        end;
        //+NPR5.53 [362878]
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
        //-NPR5.53 [382911]
        if SalesTicketNo <> '' then begin
          POSEntry.SetRange("Document No.",SalesTicketNo);
          POSEntry.FindFirst;
        end else begin
          if POSEntry.FindFirst then;
          if PAGE.RunModal(0,POSEntry) <> ACTION::LookupOK then
            exit('');
        end;
        POSEntryManagement.PrintEntry(POSEntry, Setting in [Setting::"Choose Receipt Large", Setting::"Last Receipt Large"]);
        exit(POSEntry."Document No.");
        //+NPR5.53 [382911]
        //-NPR5.53 [382911]-revoked
        /*IF POSEntry.FINDFIRST THEN;  //NPR5.53 [362878]
        IF PAGE.RUNMODAL(0, POSEntry) = ACTION::LookupOK THEN BEGIN
          //-NPR5.48 [318028]
          //PrintReceiptPOSEntry(POSEntry, Setting);
          POSEntryManagement.PrintEntry(POSEntry, Setting IN [Setting::"Choose Receipt Large", Setting::"Last Receipt Large"]);
          //+NPR5.48 [318028]
          EXIT(POSEntry."Document No.");
        END;*/
        //+NPR5.53 [382911]-revoked

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

          //-NPR5.51 [360453]
          // //-NPR5.50
          // IF Setting IN [Setting::"Last Receipt and Balance",Setting::"Last Receipt and Balance Large"] THEN BEGIN
          //   POSBalanceEntry.COPYFILTERS(POSEntry);
          //   POSBalanceEntry.SETRANGE("Entry Type", POSEntry."Entry Type"::Balancing);
          // IF POSBalanceEntry.FINDLAST THEN
          //   POSEntryManagement.PrintEntry(POSBalanceEntry, Setting = Setting::"Last Receipt and Balance Large");
          // END;
          // //+NPR5.50
          if (Setting in [Setting::"Last Receipt and Balance",Setting::"Last Receipt and Balance Large"]) then
            LastBalancePOSEntry (Setting = Setting::"Last Receipt and Balance Large");
          //+NPR5.51 [360453]

          exit(POSEntry."Document No.");
        end;
    end;

    local procedure LastBalancePOSEntry(LargePrint: Boolean): Code[20]
    var
        POSEntry: Record "POS Entry";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin

        //-NPR5.51 [360453]
        if (CurrentRegisterNo = '') then
          exit ('');

        POSEntry.SetFilter ("POS Unit No.", '=%1', CurrentRegisterNo);
        POSEntry.SetFilter ("System Entry", '=%1', false);
        POSEntry.SetFilter ("Entry Type", '=%1', POSEntry."Entry Type"::Balancing);

        if POSEntry.FindLast then begin

           POSEntryManagement.PrintEntry (POSEntry, LargePrint);
           exit (POSEntry."Document No.");

        end;
        //+NPR5.51 [360453]
    end;

    local procedure AdditionalPrints(RegisterNo: Code[10];SalesTicketNo: Code[20];var JSON: Codeunit "POS JSON Management")
    var
        AuditRoll: Record "Audit Roll";
        POSEntry: Record "POS Entry";
        NpRvVoucher: Record "NpRv Voucher";
        TMTicketManagement: Codeunit "TM Ticket Management";
        MMMemberRetailIntegration: Codeunit "MM Member Retail Integration";
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
        TaxFree: Codeunit "Tax Free Handler Mgt.";
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
        PrintDoc: Boolean;
    begin
        //-NPR5.43 [319257]
        if SalesTicketNo = '' then
          exit;

        //-NPR5.53 [382911]
        JSON.SetScopeRoot(false);
        JSON.SetScope('parameters',true);
        //+NPR5.53 [382911]

        if JSON.GetBoolean('Print Tickets',true) then
          TMTicketManagement.PrintTicketFromSalesTicketNo(SalesTicketNo);

        if JSON.GetBoolean('Print Memberships',true) then
          MMMemberRetailIntegration.PrintMembershipOnEndOfSales(SalesTicketNo);

        if JSON.GetBoolean('Print Credit Voucher',true) then begin
          AuditRoll.SetRange("Register No.",CurrentRegisterNo);
          AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
          if AuditRoll.FindFirst then
            StdCodeunitCode.PrintCreditGiftVoucher(AuditRoll);

          //-NPR5.53 [380319]
          NpRvVoucher.SetRange("Issue Document Type",NpRvVoucher."Issue Document Type"::"Audit Roll");
          NpRvVoucher.SetRange("Issue Document No.",SalesTicketNo);
          if NpRvVoucher.FindSet then
            repeat
              NpRvVoucherMgt.SendVoucher(NpRvVoucher);
            until NpRvVoucher.Next = 0;
          //+NPR5.53 [380319]
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

        //-NPR5.53 [382911]
        if JSON.GetBoolean('Print Tax Free Voucher',false) then begin
          if NPRetailSetup."Advanced Posting Activated" then begin
            POSEntry.Reset;
            POSEntry.SetRange("System Entry", false);
            POSEntry.SetRange("Entry Type",POSEntry."Entry Type"::"Direct Sale");
            POSEntry.SetRange("Document No.",SalesTicketNo);
            PrintDoc := not POSEntry.IsEmpty;
          end else begin
            AuditRoll.SetCurrentKey("Sales Ticket No.");
            AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
            AuditRoll.SetFilter(Type,'<>%1&<>%2',AuditRoll.Type::Cancelled,AuditRoll.Type::"Open/Close");
            PrintDoc := not AuditRoll.IsEmpty;
          end;
          if PrintDoc then
            TaxFree.VoucherIssueFromPOSSale(SalesTicketNo);
        end;
        //+NPR5.53 [382911]
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin
        //-NPR5.53 [382911]
        if not JSON.SetScopeRoot (false) then
          exit('');
        if not JSON.SetScope('$'+Path, false) then
          exit ('');
        exit(JSON.GetString('input',false));
        //+NPR5.53 [382911]
    end;
}

