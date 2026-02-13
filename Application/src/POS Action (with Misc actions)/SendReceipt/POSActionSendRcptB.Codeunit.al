codeunit 6150654 "NPR POS Action: Send Rcpt.-B"
{
    Access = Internal;

    procedure SendReceipt(EmailTemplateCode: Code[20]; ReceiptEmail: text[80]; POSEntryNo: Integer; SelectReceiptToSend: Integer): Text
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleDigitalReceiptEntry: Record "NPR POSSale Dig. Receipt Entry";
        RecRef: RecordRef;
        EmailManagement: Codeunit "NPR E-mail Management";
        POSActionIssueDigRcptB: Codeunit "NPR POS Action: IssueDigRcpt B";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        MailErrorMessage: Text;
        DigitalReceiptLink: Text;
        FooterText: Text;
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        // Try to send via SendGrid if new feature is enabled
        if TrySendViaSendGrid(POSEntryNo, ReceiptEmail, MailErrorMessage) then
            exit(MailErrorMessage);  // SendGrid attempted: '' = success, non-empty = error
#endif

        // Fall back to old email system
        case SelectReceiptToSend of
            0:
                begin
                    POSEntry.Get(POSEntryNo);
                    RecRef.GetTable(POSEntry);
                    RecRef.SetRecFilter();
                end;
            1:
                begin
                    POSSaleDigitalReceiptEntry.SetRange("POS Entry No.", POSEntryNo);
                    if POSSaleDigitalReceiptEntry.IsEmpty() then begin
                        if POSEntry.Get(POSEntryNo) then;
                        POSActionIssueDigRcptB.CheckIfGlobalSetupEnabledAndCreateReceipt(POSEntry."Document No.", DigitalReceiptLink, FooterText);
                    end;
                    POSSaleDigitalReceiptEntry.FindLast();
                    RecRef.GetTable(POSSaleDigitalReceiptEntry);
                    RecRef.SetRecFilter();
                end;
        end;

        EmailTemplateHeader.Get(EmailTemplateCode);
        EmailTemplateHeader.SetRecFilter();

        if EmailTemplateHeader."Report ID" > 0 then
            MailErrorMessage := EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, ReceiptEmail, true)
        else
            MailErrorMessage := EmailManagement.SendEmailTemplate(RecRef, EmailTemplateHeader, ReceiptEmail, true);

        exit(MailErrorMessage);
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    local procedure TrySendViaSendGrid(POSEntryNo: Integer; ReceiptEmail: Text[80]; var ErrorMessage: Text): Boolean
    var
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        NPEmail: Codeunit "NPR NP Email";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        Customer: Record Customer;
        LanguageCode: Code[10];
    begin
        // Returns true if SendGrid send was attempted (check ErrorMessage for result)
        // Returns false if SendGrid not enabled/configured (caller should use fallback)

        if not NewEmailExperienceFeature.IsFeatureEnabled() then
            exit(false);

        if not POSEntry.Get(POSEntryNo) then
            exit(false);

        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit(false);

        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit(false);

        if POSReceiptProfile."E-mail Template Id" = '' then
            exit(false);

        LanguageCode := '';
        if Customer.Get(POSEntry."Customer No.") then
            LanguageCode := Customer."Language Code";

        // Attempt to send via SendGrid
        if NPEmail.TrySendEmail(
            POSReceiptProfile."E-mail Template Id",
            POSEntry,
            ReceiptEmail,
            LanguageCode
        ) then
            ErrorMessage := ''  // Success
        else
            ErrorMessage := GetLastErrorText();  // Failure

        exit(true);  // Send was attempted
    end;
#endif

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
