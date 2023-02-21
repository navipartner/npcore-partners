codeunit 6150654 "NPR POS Action: Send Rcpt.-B"
{
    Access = Internal;

    procedure SendReceipt(EmailTemplateCode: Code[20]; ReceiptEmail: text[80]; POSEntryNo: Integer): Text
    var
        POSEntry: Record "NPR POS Entry";
        RecRef: RecordRef;
        EmailManagement: Codeunit "NPR E-mail Management";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        MailErrorMessage: Text;
    begin
        POSEntry.Get(POSEntryNo);

        RecRef.GetTable(POSEntry);
        RecRef.SetRecFilter();
        EmailTemplateHeader.Get(EmailTemplateCode);
        EmailTemplateHeader.SetRecFilter();

        if EmailTemplateHeader."Report ID" > 0 then
            MailErrorMessage := EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, ReceiptEmail, true)
        else
            MailErrorMessage := EmailManagement.SendEmailTemplate(RecRef, EmailTemplateHeader, ReceiptEmail, true);

        exit(MailErrorMessage);
    end;

    procedure SetReceipt(var POSEntry: Record "NPR POS Entry"; SettingOption: Option "Last Receipt","Choose Receipt"; ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
                        PresetTableView: Text; SelectionDialogType: Option TextField,List; ManualReceiptNo: Code[20]; ObfuscationMethod: Option None,MI)
    var
        Salesperson: Record "Salesperson/Purchaser";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSEntryMgt: Codeunit "NPR POS Entry Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        FilterEntityCode: Code[20];
        SalesTicketNo: Code[20];
        NoSendEmailErr: Label 'Sales Ticket No. is blank';
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

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
            SettingOption::"Choose Receipt":
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
                    SalesTicketNo := ChooseReceiptPOSEntry(ReceiptListFilterOption, PresetTableView, ReceiptListFilterOption, FilterEntityCode, SalesTicketNo, POSEntry);

                end;

            SettingOption::"Last Receipt":
                SalesTicketNo := LastReceiptPOSEntry(POSUnit, POSEntry);
        end;
        if SalesTicketNo = '' then
            Error(NoSendEmailErr);
    end;

    local procedure ChooseReceiptPOSEntry(ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson; ListTableView: Text; FilterOn: Option; FilterEntityCode: Code[20]; SalesTicketNo: Code[20]; var POSEntry: Record "NPR POS Entry"): Code[20]
    var
        POSEntry2: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
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
        exit(POSEntry."Document No.");
    end;

    local procedure LastReceiptPOSEntry(POSUnit: Record "NPR POS Unit"; var POSEntry: Record "NPR POS Entry"): Code[20]
    begin
        FilterPOSEntries(POSUnit, POSEntry);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");

        if POSEntry.FindLast() then begin
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
}
