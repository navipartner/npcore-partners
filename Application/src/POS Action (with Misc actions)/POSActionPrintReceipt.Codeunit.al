codeunit 6150787 "NPR POS Action: Print Receipt"
{
    var
        ActionDescription: Label 'This is a built-in action for printing a receipt for the current or selected transaction.';
        TxtNoReceiptFound: Label 'No receipts has been printed from this register today.';
        CurrentRegisterNo: Code[10];
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        EnterReceiptNoLbl: Label 'Enter Receipt Number';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_RECEIPT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.7');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('ManualReceiptNo',
                  'if ((param.SelectionDialogType == param.SelectionDialogType["TextField"]) && ' +
                  '    ((param.Setting == param.Setting["Choose Receipt"]) || (param.Setting == param.Setting["Choose Receipt Large"])))' +
                  '{input({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);}');
                RegisterWorkflowStep('FinishWorkflow', 'respond();');
                RegisterWorkflow(false);

                RegisterOptionParameter('Setting', 'Last Receipt,Last Receipt Large,Choose Receipt,Choose Receipt Large,Last Receipt and Balance,Last Receipt and Balance Large,Last Balance,Last Balance Large', 'Last Receipt');
                RegisterBooleanParameter('Print Tickets', false);
                RegisterBooleanParameter('Print Memberships', false);
                RegisterBooleanParameter('Print Terminal Receipt', false);
                RegisterOptionParameter('ReceiptListFilter', 'None,Current POS Store,Current POS Unit,Current Salesperson', 'None');
                RegisterTextParameter('ReceiptListView', 'SORTING(Entry No.) ORDER(Descending)');
                RegisterOptionParameter('SelectionDialogType', 'TextField,List', 'List');
                RegisterOptionParameter('ObfuscationMethod', 'None,MI', 'None');
                RegisterBooleanParameter('Print Tax Free Voucher', false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', EnterReceiptNoLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSEntryMgt: Codeunit "NPR POS Entry Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        Salesperson: Record "Salesperson/Purchaser";
        SalesTicketNo: Code[20];
        FilterEntityCode: Code[20];
        PresetTableView: Text;
        SelectionDialogType: Option TextField,List;
        Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large","Last Balance","Last Balance Large";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        Setting := JSON.GetInteger('Setting', true);
        ReceiptListFilterOption := JSON.GetIntegerParameter('ReceiptListFilter', false);
        PresetTableView := JSON.GetStringParameter('ReceiptListView', false);

        POSSession.GetSetup(POSSetup);
        CurrentRegisterNo := POSSetup.Register();

        if (ReceiptListFilterOption < 0) or (ReceiptListFilterOption > ReceiptListFilterOption::Salesperson) then
            ReceiptListFilterOption := ReceiptListFilterOption::"POS Unit";
        case ReceiptListFilterOption of
            ReceiptListFilterOption::"POS Store":
                begin
                    POSSetup.GetPOSStore(POSStore);
                    FilterEntityCode := POSStore.Code;
                end;
            ReceiptListFilterOption::"POS Unit":
                FilterEntityCode := CurrentRegisterNo;
            ReceiptListFilterOption::Salesperson:
                begin
                    POSSetup.GetSalespersonRecord(Salesperson);
                    FilterEntityCode := Salesperson.Code;
                end;
        end;

        SalesTicketNo := '';
        case Setting of
            Setting::"Choose Receipt",
            Setting::"Choose Receipt Large":
                begin
                    SelectionDialogType := JSON.GetIntegerParameter('SelectionDialogType', true);
                    if not (SelectionDialogType in [SelectionDialogType::TextField, SelectionDialogType::List]) then
                        SelectionDialogType := SelectionDialogType::List;
                    case SelectionDialogType of
                        SelectionDialogType::TextField:
                            begin
                                SalesTicketNo := CopyStr(GetInput(JSON, 'ManualReceiptNo'), 1, MaxStrLen(SalesTicketNo));
                                POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfuscationMethod', true), SalesTicketNo);
                            end;
                    end;
                    SalesTicketNo := ChooseReceiptPOSEntry(Setting, PresetTableView, ReceiptListFilterOption, FilterEntityCode, SalesTicketNo)
                end;

            Setting::"Last Receipt",
            Setting::"Last Receipt Large":
                SalesTicketNo := LastReceiptPOSEntry(Setting);

            Setting::"Last Receipt and Balance",
            Setting::"Last Receipt and Balance Large":
                SalesTicketNo := LastReceiptPOSEntry(Setting);

            Setting::"Last Balance",
            Setting::"Last Balance Large":
                SalesTicketNo := LastBalancePOSEntry(Setting = Setting::"Last Balance Large");
        end;
        if SalesTicketNo <> '' then
            AdditionalPrints(CurrentRegisterNo, SalesTicketNo, JSON);

        Handled := true;
    end;

    local procedure ChooseReceiptPOSEntry(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large"; ListTableView: Text; FilterOn: Option; FilterEntityCode: Code[20]; SalesTicketNo: Code[20]): Code[20]
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        POSEntry.Reset;
        if ListTableView <> '' then
            POSEntry.SetView(ListTableView);
        case FilterOn of
            ReceiptListFilterOption::"POS Store":
                POSEntry.SetRange("POS Store Code", FilterEntityCode);
            ReceiptListFilterOption::"POS Unit":
                POSEntry.SetRange("POS Unit No.", FilterEntityCode);
            ReceiptListFilterOption::Salesperson:
                POSEntry.SetRange("Salesperson Code", FilterEntityCode);
        end;
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
        if SalesTicketNo <> '' then begin
            POSEntry.SetRange("Document No.", SalesTicketNo);
            POSEntry.FindFirst;
        end else begin
            if POSEntry.FindFirst then;
            if PAGE.RunModal(0, POSEntry) <> ACTION::LookupOK then
                exit('');
        end;
        POSEntryManagement.PrintEntry(POSEntry, Setting in [Setting::"Choose Receipt Large", Setting::"Last Receipt Large"]);
        exit(POSEntry."Document No.");
    end;

    local procedure LastReceiptPOSEntry(Setting: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large"): Code[20]
    var
        POSEntry: Record "NPR POS Entry";
        POSBalanceEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        POSEntry.SetRange("POS Unit No.", CurrentRegisterNo);
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");

        if POSEntry.FindLast then begin
            POSEntryManagement.PrintEntry(POSEntry, Setting in [Setting::"Choose Receipt Large", Setting::"Last Receipt Large"]);
            if (Setting in [Setting::"Last Receipt and Balance", Setting::"Last Receipt and Balance Large"]) then
                LastBalancePOSEntry(Setting = Setting::"Last Receipt and Balance Large");
            exit(POSEntry."Document No.");
        end;
    end;

    local procedure LastBalancePOSEntry(LargePrint: Boolean): Code[20]
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        if (CurrentRegisterNo = '') then
            exit('');

        POSEntry.SetFilter("POS Unit No.", '=%1', CurrentRegisterNo);
        POSEntry.SetFilter("System Entry", '=%1', false);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::Balancing);

        if POSEntry.FindLast then begin
            POSEntryManagement.PrintEntry(POSEntry, LargePrint);
            exit(POSEntry."Document No.");
        end;
    end;

    local procedure AdditionalPrints(RegisterNo: Code[10]; SalesTicketNo: Code[20]; var JSON: Codeunit "NPR POS JSON Management")
    var
        POSEntry: Record "NPR POS Entry";
        NpRvVoucher: Record "NPR NpRv Voucher";
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
        MMMemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PrintDoc: Boolean;
    begin
        if SalesTicketNo = '' then
            exit;

        JSON.SetScopeRoot(false);
        JSON.SetScope('parameters', true);

        if JSON.GetBoolean('Print Tickets', true) then
            TMTicketManagement.PrintTicketFromSalesTicketNo(SalesTicketNo);

        if JSON.GetBoolean('Print Memberships', true) then
            MMMemberRetailIntegration.PrintMembershipOnEndOfSales(SalesTicketNo);

        if JSON.GetBoolean('Print Credit Voucher', true) then begin
            NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
            NpRvVoucher.SetRange("Issue Document No.", SalesTicketNo);
            if NpRvVoucher.FindSet then
                repeat
                    Codeunit.Run(codeunit::"NPR NpRv Voucher Mgt.", NpRvVoucher);
                until NpRvVoucher.Next = 0;
        end;

        if JSON.GetBoolean('Print Terminal Receipt', true) then begin
            EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
            EFTTransactionRequest.SetRange("Register No.", RegisterNo);
            if EFTTransactionRequest.FindSet then
                repeat
                    EFTTransactionRequest.PrintReceipts(true);
                until EFTTransactionRequest.Next = 0;
        end;

        if JSON.GetBoolean('Print Tax Free Voucher', false) then begin
            POSEntry.Reset;
            POSEntry.SetRange("System Entry", false);
            POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
            POSEntry.SetRange("Document No.", SalesTicketNo);
            PrintDoc := not POSEntry.IsEmpty;

            if PrintDoc then
                TaxFree.VoucherIssueFromPOSSale(SalesTicketNo);
        end;
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        if not JSON.SetScopeRoot(false) then
            exit('');
        if not JSON.SetScope('$' + Path, false) then
            exit('');
        exit(JSON.GetString('input', false));
    end;
}