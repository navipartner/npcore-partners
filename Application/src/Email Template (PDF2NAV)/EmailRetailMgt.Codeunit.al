codeunit 6014474 "NPR E-mail Retail Mgt."
{
    // PN1.00/MH/20140730 NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This codeunit contains all Retail Specific functions of PDF2NAV.
    // 
    //   Functions:
    //       Print(ReportNo : Integer;VAR RecRef : RecordRef;Filepath : Text[250];Filename : Text[250]) ReturnValue : Boolean
    //         - Uses REPORT.SAVEASPDF to generate PDF Output of the specified report.
    //           The PDF is saved at the specified Filepath + Filename.
    //       GetReportIDFromRecRef(RecRef : RecordRef) ReportID : Integer
    //         - Returns the Report ID connected to the RecRef.
    // PN1.06/TR/20150818   CASE 220997 Print function expanded with "Credit Voucher" section.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR4.00/MHA/20151214 CASE 228859 Retail References added from cu 6014464 "E-mail Document Management"
    // PN1.10/MHA/20160314 CASE 236653 Print() and EmailLog() function deleted and added subscriber functions SendReport() and GetReportID()
    // NPR5.28/MMV /20161104 CASE 254575 Added functions OnGetEmailAddressEvent() and GetEmailAddressFromRecRef()
    //                                   Added support for Contact table.
    // NPR5.40/THRO/20180314 CASE 304312 Added Report id for "POS Entry"
    // NPR5.46/TS  /20180918  CASE 302770 Added Action Group PDF2NAV on POSEntry List
    // NPR5.46/NPKNAV/20181008  CASE 302770 Transport NPR5.46 - 8 October 2018


    trigger OnRun()
    begin
    end;

    var
        RecRef: RecordRef;
        Text001: Label 'Nothing to print';

    [EventSubscriber(ObjectType::Codeunit, 6014450, 'GetEmailAddressEvent', '', false, false)]
    local procedure OnGetEmailAddressEvent(var RecRef: RecordRef; var EmailAddress: Text; var Handled: Boolean)
    var
        emailAddr: Text;
    begin
        //-NPR5.28 [254575]
        if Handled then
            exit;

        emailAddr := GetEmailAddressFromRecRef(RecRef);
        if StrLen(emailAddr) = 0 then
            exit;

        EmailAddress := emailAddr;
        Handled := true;
        //+NPR5.28 [254575]
    end;

    local procedure GetEmailAddressFromRecRef(var RecRef: RecordRef): Text
    var
        AuditRoll: Record "NPR Audit Roll";
        GiftVoucher: Record "NPR Gift Voucher";
        CreditVoucher: Record "NPR Credit Voucher";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        //-NPR5.28 [254575]
        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                begin
                    RecRef.SetTable(AuditRoll);
                    case AuditRoll."Customer Type" of
                        AuditRoll."Customer Type"::"Ord.":
                            if Customer.Get(AuditRoll."Customer No.") then
                                exit(Customer."E-Mail");
                        AuditRoll."Customer Type"::Cash:
                            if Contact.Get(AuditRoll."Customer No.") then
                                exit(Contact."E-Mail");
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
        //+NPR5.28 [254575]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014450, 'GetReportIDEvent', '', false, false)]
    local procedure GetReportID(RecRef: RecordRef; var ReportID: Integer)
    begin
        //-PN1.10
        if ReportID > 0 then
            exit;

        ReportID := GetReportIDFromRecRef(RecRef);
        //+PN1.10
    end;

    procedure GetReportIDFromRecRef(RecRef: RecordRef) ReportID: Integer
    var
        RetailReportSelection: Record "NPR Report Selection Retail";
    begin
        Clear(RetailReportSelection);
        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                //-PN1.10
                //RetailReportSelection.SETRANGE("Report Type",RetailReportSelection."Report Type"::Bon);
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Large Sales Receipt");
            //-PN1.10
            DATABASE::"NPR Gift Voucher":
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Gift Voucher");
            DATABASE::"NPR Credit Voucher":
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Credit Voucher");
            //-NPR5.40 [304312]
            DATABASE::"NPR POS Entry":
                RetailReportSelection.SetRange("Report Type", RetailReportSelection."Report Type"::"Large Sales Receipt (POS Entry)");
            //+NPR5.40 [304312]
            else
                exit(0);
        end;

        RetailReportSelection.SetFilter("Report ID", '<>%1', 0);
        if RetailReportSelection.FindFirst then;

        exit(RetailReportSelection."Report ID");
    end;

    procedure "--- Send E-mail"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014464, 'SendReportEvent', '', false, false)]
    local procedure SendReport(RecVariant: Variant; Silent: Boolean)
    var
        RecRef: RecordRef;
    begin
        //-PN1.10
        RecRef.GetTable(RecVariant);
        case RecRef.Number of
            DATABASE::"NPR Audit Roll":
                SendReportAuditRoll(RecVariant, Silent);
            DATABASE::"NPR Credit Voucher":
                SendReportCreditVoucher(RecVariant, Silent);
            DATABASE::"NPR Gift Voucher":
                SendReportGiftVoucher(RecVariant, Silent);
            //-NPR5.46 [302770]
            DATABASE::"NPR POS Entry":
                SendReportPOSEntry(RecVariant, Silent);
        //+302770 [302770]
        end;
        //+PN1.10
    end;

    procedure SendReportAuditRoll(var AuditRoll: Record "NPR Audit Roll"; Silent: Boolean)
    var
        Text10600005: Label 'Nothing to print';
        Customer: Record Customer;
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        ReportID: Integer;
        EmailAddr: Text;
        Contact: Record Contact;
    begin
        //-NPR4.00
        if (AuditRoll.Type = AuditRoll.Type::"Open/Close") or (AuditRoll.Type = AuditRoll.Type::Cancelled) then begin
            if Silent then
                exit;
            Error(Text001);
        end;

        RecRef.GetTable(AuditRoll);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        //-NPR5.28 [254575]
        case AuditRoll."Customer Type" of
            AuditRoll."Customer Type"::"Ord.":
                if Customer.Get(AuditRoll."Customer No.") then
                    EmailAddr := Customer."E-Mail";
            AuditRoll."Customer Type"::Cash:
                if Contact.Get(AuditRoll."Customer No.") then
                    EmailAddr := Contact."E-Mail";
        end;

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);

        // CLEAR(Customer);
        // IF Customer.GET(AuditRoll."Customer No.") THEN;

        // EmailMgt.SendReport(ReportID,RecRef,Customer."E-Mail",Silent);
        //+NPR5.28 [254575]
        //+NPR4.00
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
        //-NPR4.00
        RecRef.GetTable(CreditVoucher);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;


        //-NPR5.28 [254575]
        case CreditVoucher."Customer Type" of
            CreditVoucher."Customer Type"::Alm:
                if Customer.Get(CreditVoucher."Customer No") then
                    EmailAddr := Customer."E-Mail";
            CreditVoucher."Customer Type"::Kontant:
                if Contact.Get(CreditVoucher."Customer No") then
                    EmailAddr := Contact."E-Mail";
        end;

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);

        // CLEAR(Customer);
        // IF Customer.GET(CreditVoucher."Customer No") THEN;
        //
        // EmailMgt.SendReport(ReportID,RecRef,Customer."E-Mail",Silent);
        //+NPR5.28 [254575]
        //+NPR4.00
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
        //-NPR4.00
        RecRef.GetTable(GiftVoucher);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        //-NPR5.28 [254575]
        case GiftVoucher."Customer Type" of
            GiftVoucher."Customer Type"::Alm:
                if Customer.Get(GiftVoucher."Customer No.") then
                    EmailAddr := Customer."E-Mail";
            GiftVoucher."Customer Type"::Kontant:
                if Contact.Get(GiftVoucher."Customer No.") then
                    EmailAddr := Contact."E-Mail";
        end;

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);

        // CLEAR(Customer);
        // IF Customer.GET(GiftVoucher."Customer No.") THEN;
        //
        // EmailMgt.SendReport(ReportID,RecRef,Customer."E-Mail",Silent);
        //+NPR5.28 [254575]
        //+NPR4.00
    end;

    local procedure SendReportPOSEntry(var PosEntry: Record "NPR POS Entry"; Silent: Boolean)
    var
        Customer: Record Customer;
        RecRef: RecordRef;
        EmailMgt: Codeunit "NPR E-mail Management";
        ReportID: Integer;
        EmailAddr: Text;
    begin
        //-NPR5.46[302770]
        RecRef.GetTable(PosEntry);
        if not EmailMgt.ConfirmResendEmail(RecRef) then
            exit;

        ReportID := EmailMgt.GetReportIDFromRecRef(RecRef);
        if ReportID = 0 then
            exit;

        if Customer.Get(PosEntry."Customer No.") then
            EmailAddr := Customer."E-Mail";

        EmailMgt.SendReport(ReportID, RecRef, EmailAddr, Silent);
        //+NPR5.46[302770]
    end;

    procedure "--- Retail Exists"()
    begin
    end;

    procedure AuditRollExists(): Boolean
    var
        TableInformation: Record "Table Information";
    begin
        //-NPR4.00
        exit(TableInformation.Get(CompanyName, AuditRollTableId()));
        //+NPR4.00
    end;

    procedure CreditVoucherExists(): Boolean
    var
        TableInformation: Record "Table Information";
    begin
        //-NPR4.00
        exit(TableInformation.Get(CompanyName, CreditVoucherTableId()));
        //+NPR4.00
    end;

    procedure GiftVoucherExists(): Boolean
    var
        TableInformation: Record "Table Information";
    begin
        //-NPR4.00
        exit(TableInformation.Get(CompanyName, GiftVoucherTableId()));
        //+NPR4.00
    end;

    procedure "--- Retail Table Id"()
    begin
    end;

    procedure AuditRollTableId(): Integer
    begin
        //-NPR4.00
        exit(6014407);
        //+NPR4.00
    end;

    procedure CreditVoucherTableId(): Integer
    begin
        //-NPR4.00
        exit(6014408);
        //+NPR4.00
    end;

    procedure GiftVoucherTableId(): Integer
    begin
        //-NPR4.00
        exit(6014409);
        //+NPR4.00
    end;
}

