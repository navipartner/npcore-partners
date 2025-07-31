codeunit 6060086 "NPR POS Action: Print Rcpt.-B"
{
    Access = Internal;

    internal procedure GetDigitalReceiptQRCodeLink(SalesTicketNo: Code[20]) DigitalReceiptQRCodeLink: Text;
    var
        POSSaleDigitalReceiptEntry: Record "NPR POSSale Dig. Receipt Entry";
        POSActionIssueDigRcptB: Codeunit "NPR POS Action: IssueDigRcpt B";
        FooterText: Text;
    begin
        if SalesTicketNo = '' then
            exit;

        POSSaleDigitalReceiptEntry.Reset();
        POSSaleDigitalReceiptEntry.SetCurrentKey("Sales Ticket No.");
        POSSaleDigitalReceiptEntry.SetRange("Sales Ticket No.", SalesTicketNo);
        POSSaleDigitalReceiptEntry.SetLoadFields("Sales Ticket No.", "QR Code Link");
        if not POSSaleDigitalReceiptEntry.FindFirst() then
            POSActionIssueDigRcptB.CheckIfGlobalSetupEnabledAndCreateReceipt(SalesTicketNo, DigitalReceiptQRCodeLink, FooterText)
        else
            DigitalReceiptQRCodeLink := POSSaleDigitalReceiptEntry."QR Code Link";
    end;

    internal procedure GetSalesTicketNoAndPrintReceipt(POSSetup: Codeunit "NPR POS Setup"; POSUnit: Record "NPR POS Unit"; SettingOption: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large","Last Balance","Last Balance Large"; ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson; PresetTableView: Text; SelectionDialogType: Option TextField,List; ManualReceiptNo: Code[20]; ObfuscationMethod: Option None,MI; PrintPhysicalReceipts: Boolean; PrintTickets: Boolean; PrintMemberships: Boolean; PrintRetailVoucher: Boolean; PrintTerminalReceipt: Boolean; PrintTaxFreeVoucher: Boolean) SalesTicketNo: Code[20];
    var
        Salesperson: Record "Salesperson/Purchaser";
        POSStore: Record "NPR POS Store";
        POSEntryMgt: Codeunit "NPR POS Entry Management";
        FilterEntityCode: Code[20];
    begin
        if (ReceiptListFilterOption < 0) or (ReceiptListFilterOption > ReceiptListFilterOption::Salesperson) then
            ReceiptListFilterOption := ReceiptListFilterOption::"POS Unit";
        case ReceiptListFilterOption of
            ReceiptListFilterOption::"POS Store":
                begin
                    POSSetup.GetPOSStore(POSStore);
                    FilterEntityCode := POSStore.Code;
                end;
            ReceiptListFilterOption::"POS Unit":
                FilterEntityCode := POSUnit."No.";
            ReceiptListFilterOption::Salesperson:
                begin
                    POSSetup.GetSalespersonRecord(Salesperson);
                    FilterEntityCode := Salesperson.Code;
                end;
        end;

        SalesTicketNo := '';
        case SettingOption of
            SettingOption::"Choose Receipt",
            SettingOption::"Choose Receipt Large":
                begin

                    if not (SelectionDialogType in [SelectionDialogType::TextField, SelectionDialogType::List]) then
                        SelectionDialogType := SelectionDialogType::List;
                    case SelectionDialogType of
                        SelectionDialogType::TextField:
                            begin
                                SalesTicketNo := ManualReceiptNo;
                                POSEntryMgt.DeObfuscateTicketNo(ObfuscationMethod, SalesTicketNo);
                            end;
                    end;
                    SalesTicketNo := ChooseReceiptPOSEntry(SettingOption, ReceiptListFilterOption, PresetTableView, ReceiptListFilterOption, FilterEntityCode, SalesTicketNo, PrintPhysicalReceipts)
                end;

            SettingOption::"Last Receipt",
            SettingOption::"Last Receipt Large":
                SalesTicketNo := LastReceiptPOSEntry(POSUnit, SettingOption, PrintPhysicalReceipts);

            SettingOption::"Last Receipt and Balance",
            SettingOption::"Last Receipt and Balance Large":
                SalesTicketNo := LastReceiptPOSEntry(POSUnit, SettingOption, PrintPhysicalReceipts);

            SettingOption::"Last Balance",
            SettingOption::"Last Balance Large":
                SalesTicketNo := LastBalancePOSEntry(POSUnit, SettingOption = SettingOption::"Last Balance Large");
        end;

        if (SalesTicketNo <> '') and PrintPhysicalReceipts then
            AdditionalPrints(POSUnit."No.", SalesTicketNo, PrintTickets, PrintMemberships, PrintRetailVoucher, PrintTerminalReceipt, PrintTaxFreeVoucher);
    end;

    local procedure ChooseReceiptPOSEntry(SettingOption: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large"; ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson; ListTableView: Text; FilterOn: Option; FilterEntityCode: Code[20]; SalesTicketNo: Code[20]; PrintPhysicalReceipts: Boolean): Code[20]
    var
        POSEntry: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        IsPrimaryKey: Boolean;
    begin
        POSEntry.Reset();
        if ListTableView <> '' then
            POSEntry.SetView(ListTableView);
        IsPrimaryKey := POSEntry.CurrentKey() = POSEntry2.CurrentKey();
        case FilterOn of
            ReceiptListFilterOption::"POS Store":
                begin
                    if IsPrimaryKey then
                        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
                    POSEntry.SetRange("POS Store Code", FilterEntityCode);
                end;
            ReceiptListFilterOption::"POS Unit":
                begin
                    if IsPrimaryKey then begin
                        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
                        POSUnit.Get(FilterEntityCode);
                        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
                    end;
                    POSEntry.SetRange("POS Unit No.", FilterEntityCode);
                end;
            ReceiptListFilterOption::Salesperson:
                begin
                    if IsPrimaryKey then
                        if POSEntry.SetCurrentKey("Salesperson Code") then;
                    POSEntry.SetRange("Salesperson Code", FilterEntityCode);
                end;
        end;
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
        if SalesTicketNo <> '' then begin
            POSEntry.SetCurrentKey("Document No.");
            POSEntry.SetRange("Document No.", SalesTicketNo);
            POSEntry.FindFirst();
        end else begin
            if POSEntry.Ascending() then
                POSEntry.Ascending(false);
            if POSEntry.FindFirst() then;
            if PAGE.RunModal(0, POSEntry) <> ACTION::LookupOK then
                exit('');

        end;
        if PrintPhysicalReceipts then
            POSEntryManagement.PrintEntry(POSEntry, SettingOption in [SettingOption::"Choose Receipt Large", SettingOption::"Last Receipt Large"]);
        exit(POSEntry."Document No.");
    end;

    local procedure LastReceiptPOSEntry(POSUnit: Record "NPR POS Unit"; SettingOption: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large"; PrintPhysicalReceipts: Boolean) SalesTicketNo: Code[20]
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        FilterPOSEntries(POSUnit, POSEntry);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");

        if POSEntry.FindLast() then begin
            SalesTicketNo := POSEntry."Document No.";
            if PrintPhysicalReceipts then begin
                POSEntryManagement.PrintEntry(POSEntry, SettingOption in [SettingOption::"Choose Receipt Large", SettingOption::"Last Receipt Large"]);
                if (SettingOption in [SettingOption::"Last Receipt and Balance", SettingOption::"Last Receipt and Balance Large"]) then
                    LastBalancePOSEntry(POSUnit, SettingOption = SettingOption::"Last Receipt and Balance Large");
            end;
        end;
    end;

    local procedure LastBalancePOSEntry(POSUnit: Record "NPR POS Unit"; LargePrint: Boolean): Code[20]
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        if not FilterPOSEntries(POSUnit, POSEntry) then
            exit('');
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::Balancing);

        if POSEntry.FindLast() then begin
            POSEntryManagement.PrintEntry(POSEntry, LargePrint);
            exit(POSEntry."Document No.");
        end;
    end;

    local procedure FilterPOSEntries(POSUnit: Record "NPR POS Unit"; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        if POSUnit."No." = '' then
            exit(false);

        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
        POSEntry.SetRange("POS Store Code", POSUnit."POS Store Code");
        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.SetRange("System Entry", false);
        exit(true);
    end;

    local procedure AdditionalPrints(RegisterNo: Code[10]; SalesTicketNo: Code[20]; PrintTickets: Boolean; PrintMemberships: Boolean; PrintRetailVoucher: Boolean; PrintTerminalReceipt: Boolean; PrintTaxFreeVoucher: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
        MMMemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PrintDoc: Boolean;
    begin
        if SalesTicketNo = '' then
            exit;

        if PrintTickets then
            TMTicketManagement.PrintTicketFromSalesTicketNo(SalesTicketNo);

        if PrintMemberships then
            MMMemberRetailIntegration.PrintMembershipOnEndOfSales(SalesTicketNo);

        if PrintRetailVoucher then begin
            NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.", "Document Line No.");
            NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2', NpRvVoucherEntry."Entry Type"::"Issue Voucher", NpRvVoucherEntry."Entry Type"::"Partner Issue Voucher");
            NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::"POS Entry");
            NpRvVoucherEntry.SetRange("Document No.", SalesTicketNo);
            if NpRvVoucherEntry.FindSet() then
                repeat
                    if NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.") then
                        Codeunit.Run(codeunit::"NPR NpRv Voucher Mgt.", NpRvVoucher);
                until NpRvVoucherEntry.Next() = 0;
        end;

        if PrintTerminalReceipt then begin
            EFTTransactionRequest.SetCurrentKey("Sales Ticket No.");
            EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
            EFTTransactionRequest.SetRange("Register No.", RegisterNo);
            if EFTTransactionRequest.FindSet() then
                repeat
                    EFTTransactionRequest.PrintReceipts(true);
                until EFTTransactionRequest.Next() = 0;
        end;

        if PrintTaxFreeVoucher then begin
            POSEntry.Reset();
            POSEntry.SetCurrentKey("Document No.");
            POSEntry.SetRange("Document No.", SalesTicketNo);
            POSEntry.SetRange("System Entry", false);
            POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
            PrintDoc := not POSEntry.IsEmpty();

            if PrintDoc then
                TaxFree.VoucherIssueFromPOSSale(SalesTicketNo);
        end;
    end;
}
