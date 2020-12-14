codeunit 6014474 "NPR E-mail Retail Mgt."
{
    var
        RecRef: RecordRef;
        NothingToPrintErr: Label 'Nothing to print';

    [EventSubscriber(ObjectType::Codeunit, 6014450, 'GetEmailAddressEvent', '', false, false)]
    local procedure OnGetEmailAddressEvent(var RecRef: RecordRef; var EmailAddress: Text; var Handled: Boolean)
    var
        emailAddr: Text;
    begin
        if Handled then
            exit;

        emailAddr := GetEmailAddressFromRecRef(RecRef);
        if StrLen(emailAddr) = 0 then
            exit;

        EmailAddress := emailAddr;
        Handled := true;
    end;

    local procedure GetEmailAddressFromRecRef(var RecRef: RecordRef): Text
    var
        POSEntry: Record "NPR POS Entry";
        GiftVoucher: Record "NPR Gift Voucher";
        CreditVoucher: Record "NPR Credit Voucher";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        case RecRef.Number of
            Database::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    case true of
                        POSEntry."Customer No." <> '':
                            begin
                                Customer.Get(POSEntry."Customer No.");
                                exit(Customer."E-Mail");
                            end;
                        POSEntry."Contact No." <> '':
                            begin
                                Contact.Get(POSEntry."Contact No.");
                                exit(Contact."E-Mail");
                            end;
                    end;

                end;
            DATABASE::"NPR Gift Voucher":
                begin
                    RecRef.SetTable(GiftVoucher);
                    case GiftVoucher."Customer Type" of
                        GiftVoucher."Customer Type"::Alm:
                            if Customer.Get(GiftVoucher."Customer No.") then
                                exit(Customer."E-Mail");
                        GiftVoucher."Customer Type"::Kontant:
                            if Contact.Get(GiftVoucher."Customer No.") then
                                exit(Contact."E-Mail");
                    end;
                end;
            DATABASE::"NPR Credit Voucher":
                begin
                    RecRef.SetTable(CreditVoucher);
                    case CreditVoucher."Customer Type" of
                        CreditVoucher."Customer Type"::Alm:
                            if Customer.Get(CreditVoucher."Customer No") then
                                exit(Customer."E-Mail");
                        CreditVoucher."Customer Type"::Kontant:
                            if Contact.Get(CreditVoucher."Customer No") then
                                exit(Contact."E-Mail");
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014450, 'OnAfterGetReportIDEvent', '', false, false)]
    local procedure GetReportID(RecRef: RecordRef; var ReportID: Integer)
    begin
        if ReportID > 0 then
            exit;

        ReportID := GetReportIDFromRecRef(RecRef);
    end;

    procedure GetReportIDFromRecRef(RecRef: RecordRef) ReportID: Integer
    var
        RetailReportSelection: Record "NPR Report Selection Retail";
    begin
        Clear(RetailReportSelection);
        case RecRef.Number of
            DATABASE::"NPR Gift Voucher":
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Gift Voucher");
            DATABASE::"NPR Credit Voucher":
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Credit Voucher");
            DATABASE::"NPR POS Entry":
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Large Sales Receipt (POS Entry)");
            else
                exit(0);
        end;

        RetailReportSelection.SetFilter("Report ID", '<>%1', 0);
        if RetailReportSelection.FindFirst then;

        exit(RetailReportSelection."Report ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014464, 'SendReportEvent', '', false, false)]
    local procedure SendReport(RecVariant: Variant; Silent: Boolean)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVariant);
        case RecRef.Number of
            DATABASE::"NPR Credit Voucher":
                SendReportCreditVoucher(RecVariant, Silent);
            DATABASE::"NPR Gift Voucher":
                SendReportGiftVoucher(RecVariant, Silent);
            DATABASE::"NPR POS Entry":
                SendReportPOSEntry(RecVariant, Silent);
        end;
    end;

    procedure SendReportCreditVoucher(var CreditVoucher: Record "NPR Credit Voucher"; Silent: Boolean)
    var
        Customer: Record Customer;
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        ReportID: Integer;
        Contact: Record Contact;
        EmailAddr: Text;
    begin
        RecRef.GetTable(CreditVoucher);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        case CreditVoucher."Customer Type" of
            CreditVoucher."Customer Type"::Alm:
                if Customer.Get(CreditVoucher."Customer No") then
                    EmailAddr := Customer."E-Mail";
            CreditVoucher."Customer Type"::Kontant:
                if Contact.Get(CreditVoucher."Customer No") then
                    EmailAddr := Contact."E-Mail";
        end;

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);
    end;

    procedure SendReportGiftVoucher(var GiftVoucher: Record "NPR Gift Voucher"; Silent: Boolean)
    var
        Customer: Record Customer;
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        ReportID: Integer;
        Contact: Record Contact;
        EmailAddr: Text;
    begin
        RecRef.GetTable(GiftVoucher);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        case GiftVoucher."Customer Type" of
            GiftVoucher."Customer Type"::Alm:
                if Customer.Get(GiftVoucher."Customer No.") then
                    EmailAddr := Customer."E-Mail";
            GiftVoucher."Customer Type"::Kontant:
                if Contact.Get(GiftVoucher."Customer No.") then
                    EmailAddr := Contact."E-Mail";
        end;

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);
    end;

    local procedure SendReportPOSEntry(var PosEntry: Record "NPR POS Entry"; Silent: Boolean)
    var
        RecRef: RecordRef;
        EmailMgt: Codeunit "NPR E-mail Management";
        EmailDocumentManagement: Codeunit "NPR E-mail Doc. Mgt.";
        ReportID: Integer;
        EmailAddr: Text;
    begin
        RecRef.GetTable(PosEntry);
        if not Silent then
            if not EmailMgt.ConfirmResendEmail(RecRef) then
                exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        EmailAddr := EmailDocumentManagement.GetMailReceipients(RecRef, ReportID);

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);
    end;

    procedure POSEntryExists(): Boolean
    var
        TableInformation: Record "Table Information";
    begin
        exit(TableInformation.Get(CompanyName, POSEntryTableId()));
    end;

    procedure CreditVoucherExists(): Boolean
    var
        TableInformation: Record "Table Information";
    begin
        exit(TableInformation.Get(CompanyName, CreditVoucherTableId()));
    end;

    procedure GiftVoucherExists(): Boolean
    var
        TableInformation: Record "Table Information";
    begin
        exit(TableInformation.Get(CompanyName, GiftVoucherTableId()));
    end;

    procedure POSEntryTableId(): Integer
    var
        POSEntry: Record "NPR POS Entry";
    begin
        exit(6150621);
    end;

    procedure CreditVoucherTableId(): Integer
    begin
        exit(6014408);
    end;

    procedure GiftVoucherTableId(): Integer
    begin
        exit(6014409);
    end;
}

