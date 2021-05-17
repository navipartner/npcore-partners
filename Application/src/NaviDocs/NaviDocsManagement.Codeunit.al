codeunit 6059767 "NPR NaviDocs Management"
{
    TableNo = "NPR NaviDocs Entry";

    trigger OnRun()
    var
    begin
        if not (NaviDocsSetup.Get() and NaviDocsSetup."Enable NaviDocs" and (Rec.Status <> 2)) then
            exit;
        if (Rec."Delay sending until" <> 0DT) and (Rec."Delay sending until" > CurrentDateTime) then
            exit;
        ClearLastError();
        if not DocManage(Rec) then begin
            Commit();
            Error('');
        end;
        Rec.Status := 2;
        Rec.Modify(true);
    end;

    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
        MailAndDocumentHandling: Codeunit "NPR E-mail Management";
        NPRDocumentLocalization: Codeunit "NPR Doc. Localization Proxy";
        DevMsgNotTemporaryErr: Label 'This function can only be used when the record is temporary.';
        Error003: Label 'No report for printing the %1 found.';
        Error004: Label 'E-mail Address is missing.';
        Error015: Label 'Unsupported %1.';
        Error016: Label '%1 %2 not found.';
        ActivityContentText: Label 'NaviDocs';
        ActivityHandling: Label 'Handling';
        ActivityStatusChange: Label 'Status Change';
        EntryChangedTxt: Label '%1 changed to %2.';

    procedure Process(NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        ManagementStatus: Boolean;

    begin
        if not (NaviDocsSetup.Get() and
                NaviDocsSetup."Enable NaviDocs" and
                (NaviDocsEntry.Status <> 2)) then
            exit;
        if (NaviDocsEntry."Delay sending until" <> 0DT) and (NaviDocsEntry."Delay sending until" > CurrentDateTime) then
            exit;

        NaviDocsEntry."Processed Qty." += 1;
        NaviDocsEntry.Status := 1;
        NaviDocsEntry.Modify();
        Commit();
        ManagementStatus := NaviDocsManagement.Run(NaviDocsEntry);
        if (not ManagementStatus) and (GetLastErrorText <> '') then begin
            InsertComment(NaviDocsEntry, GetLastErrorText, true);
            ClearLastError();
        end;

        if ManagementStatus then
            NaviDocsEntry.Status := 2
        else
            if TrySendWarningMail(NaviDocsEntry) then;

        NaviDocsEntry.Modify(true);

    end;

    procedure AddDocumentEntry(RecRef: RecordRef; ReportNo: Integer)
    var
        TempHandlingProfile: Record "NPR NaviDocs Handling Profile" temporary;
    begin
        if not NaviDocsSetup.Get() then
            exit;
        OnAddHandlingProfilesToLibrary();
        GetMasterTableHandlingProfiles(RecRef, TempHandlingProfile);
        if TempHandlingProfile.FindSet() then
            repeat
                AddDocumentEntryWithHandlingProfile(RecRef, TempHandlingProfile.Code, ReportNo, TempHandlingProfile.Description, 0DT);
            until TempHandlingProfile.Next() = 0;
    end;

    procedure AddDocumentEntryWithHandlingProfile(RecRef: RecordRef; HandlingProfile: Code[20]; ReportNo: Integer; Recipient: Text; DelayUntil: DateTime)
    begin
        AddDocumentEntryWithHandlingProfileExt(RecRef, HandlingProfile, ReportNo, Recipient, '', DelayUntil);
    end;

    procedure AddDocumentEntryWithHandlingProfileExt(RecRef: RecordRef; HandlingProfile: Code[20]; ReportNo: Integer; Recipient: Text; TemplateCode: Code[20]; DelayUntil: DateTime): BigInteger
    var
        NaviDocsEntry: Record "NPR NaviDocs Entry";
        TableMetadata: Record "Table Metadata";
        InsertIsHandled: Boolean;
        PrimaryKey: KeyRef;
        I: Integer;
        InsertedEntryNo: BigInteger;
    begin
        if not NaviDocsSetup.Get() then
            exit;
        if not NaviDocsSetup."Enable NaviDocs" then
            exit;

        OnBeforeAddDocumentEntry(InsertIsHandled, RecRef, HandlingProfile, ReportNo, Recipient);
        if InsertIsHandled then
            exit;
        InsertedEntryNo := 0;
        OnBeforeAddDocumentEntryExt(InsertedEntryNo, RecRef, HandlingProfile, ReportNo, Recipient, TemplateCode, DelayUntil);
        if InsertedEntryNo <> 0 then
            exit(InsertedEntryNo);

        if RecRef.Get(RecRef.RecordId) then begin
            NaviDocsEntry.Init();
            NaviDocsEntry."Entry No." := 0;
            NaviDocsEntry.Validate("Record ID", RecRef.RecordId);

            NaviDocsEntry.Validate("Table No.", RecRef.Number);
            NaviDocsEntry."Document Description" := '';
            if TableMetadata.Get(RecRef.Number) then
                NaviDocsEntry."Document Description" += TableMetadata.Caption;
            PrimaryKey := RecRef.KeyIndex(1);
            for I := 1 to PrimaryKey.FieldCount - 1 do
                NaviDocsEntry."Document Description" += ' ' + Format(PrimaryKey.FieldIndex(I).Value);

            NaviDocsEntry."No." := CopyStr(Format(PrimaryKey.FieldIndex(PrimaryKey.FieldCount).Value), 1, 20);
            TransferFromTable(NaviDocsEntry, RecRef);

            NaviDocsEntry.Validate("Document Handling Profile", HandlingProfile);
            if Recipient <> '' then
                NaviDocsEntry."E-mail (Recipient)" := Recipient;

            NaviDocsEntry."Report No." := ReportNo;
            NaviDocsEntry."Delay sending until" := DelayUntil;
            NaviDocsEntry."Template Code" := TemplateCode;
            NaviDocsEntry.Insert(true);
            InsertedEntryNo := NaviDocsEntry."Entry No.";
        end;
        exit(InsertedEntryNo);
    end;

    procedure AddDocumentEntryWithAttachments(RecRef: RecordRef; HandlingProfile: Code[20]; ReportNo: Integer; Recipient: Text; TemplateCode: Code[20]; DelayUntil: DateTime; var Attachments: Record "NPR NaviDocs Entry Attachment"): Boolean
    var
        NaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment";
        NewEntryNo: BigInteger;
    begin
        NewEntryNo := AddDocumentEntryWithHandlingProfileExt(RecRef, HandlingProfile, ReportNo, Recipient, TemplateCode, DelayUntil);
        if NewEntryNo = 0 then
            exit(false);
        if Attachments.FindSet() then
            repeat
                Attachments.CalcFields(Data);
                NaviDocsEntryAttachment := Attachments;
                NaviDocsEntryAttachment."NaviDocs Entry No." := NewEntryNo;
                NaviDocsEntryAttachment.Insert(true);
            until Attachments.Next() = 0;
    end;

    local procedure TransferFromTable(var NaviDocsEntry: Record "NPR NaviDocs Entry"; RecRef: RecordRef)
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchHeader: Record "Purchase Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ServiceHeader: Record "Service Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceContractHeader: Record "Service Contract Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        case RecRef.Number of
            DATABASE::Customer:
                begin
                    RecRef.SetTable(Customer);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := Customer."No.";
                    NaviDocsEntry."Name (Recipient)" := Customer.Name;
                    NaviDocsEntry."Name 2 (Recipient)" := Customer."Name 2";
                end;
            DATABASE::Vendor:
                begin
                    RecRef.SetTable(Vendor);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Vendor;
                    NaviDocsEntry."No. (Recipient)" := Vendor."No.";
                    NaviDocsEntry."Name (Recipient)" := Vendor.Name;
                    NaviDocsEntry."Name 2 (Recipient)" := Vendor."Name 2";
                end;
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    NaviDocsEntry."Document Type" := SalesHeader."Document Type".AsInteger();
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := SalesHeader."Sell-to Customer No.";
                    NaviDocsEntry."Name (Recipient)" := SalesHeader."Sell-to Customer Name";
                    NaviDocsEntry."Name 2 (Recipient)" := SalesHeader."Sell-to Customer Name 2";
                    NaviDocsEntry."Posting Date" := SalesHeader."Posting Date";
                    NaviDocsEntry."External Document No." := SalesHeader."External Document No.";
                end;
            DATABASE::"Purchase Header":
                begin
                    RecRef.SetTable(PurchHeader);
                    NaviDocsEntry."Document Type" := PurchHeader."Document Type".AsInteger();
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Vendor;
                    NaviDocsEntry."No. (Recipient)" := PurchHeader."Buy-from Vendor No.";
                    NaviDocsEntry."Posting Date" := PurchHeader."Posting Date";
                    NaviDocsEntry."Name (Recipient)" := PurchHeader."Buy-from Vendor Name";
                    NaviDocsEntry."Name 2 (Recipient)" := PurchHeader."Buy-from Vendor Name 2";
                end;
            DATABASE::"Sales Shipment Header":
                begin
                    RecRef.SetTable(SalesShipmentHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := SalesShipmentHeader."Sell-to Customer No.";
                    NaviDocsEntry."Posting Date" := SalesShipmentHeader."Posting Date";
                    NaviDocsEntry."Name (Recipient)" := SalesShipmentHeader."Sell-to Customer Name";
                    NaviDocsEntry."Name 2 (Recipient)" := SalesShipmentHeader."Sell-to Customer Name 2";
                    NaviDocsEntry."External Document No." := SalesShipmentHeader."External Document No.";
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := SalesInvoiceHeader."Bill-to Customer No.";
                    NaviDocsEntry."Posting Date" := SalesInvoiceHeader."Posting Date";
                    NaviDocsEntry."Name (Recipient)" := SalesInvoiceHeader."Bill-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := SalesInvoiceHeader."Bill-to Name 2";
                    NaviDocsEntry."Order No." := SalesInvoiceHeader."Order No.";
                    NaviDocsEntry."External Document No." := SalesInvoiceHeader."External Document No.";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := SalesCrMemoHeader."Bill-to Customer No.";
                    NaviDocsEntry."Posting Date" := SalesCrMemoHeader."Posting Date";
                    NaviDocsEntry."Name (Recipient)" := SalesCrMemoHeader."Bill-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := SalesCrMemoHeader."Bill-to Name 2";
                    NaviDocsEntry."External Document No." := SalesCrMemoHeader."External Document No.";
                end;
            DATABASE::"Issued Reminder Header":
                begin
                    RecRef.SetTable(IssuedReminderHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := IssuedReminderHeader."Customer No.";
                    NaviDocsEntry."Name (Recipient)" := IssuedReminderHeader.Name;
                    NaviDocsEntry."Name 2 (Recipient)" := IssuedReminderHeader."Name 2";
                    NaviDocsEntry."Posting Date" := IssuedReminderHeader."Posting Date";
                end;
            DATABASE::"Issued Fin. Charge Memo Header":
                begin
                    RecRef.SetTable(IssuedFinChargeMemoHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := IssuedFinChargeMemoHeader."Customer No.";
                    NaviDocsEntry."Name (Recipient)" := IssuedFinChargeMemoHeader.Name;
                    NaviDocsEntry."Name 2 (Recipient)" := IssuedFinChargeMemoHeader."Name 2";
                    NaviDocsEntry."Posting Date" := IssuedFinChargeMemoHeader."Posting Date";
                end;
            DATABASE::"Return Receipt Header":
                begin
                    RecRef.SetTable(ReturnReceiptHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := ReturnReceiptHeader."Sell-to Customer No.";
                    NaviDocsEntry."Name (Recipient)" := ReturnReceiptHeader."Sell-to Customer Name";
                    NaviDocsEntry."Name 2 (Recipient)" := ReturnReceiptHeader."Sell-to Customer Name 2";
                    NaviDocsEntry."Posting Date" := ReturnReceiptHeader."Posting Date";
                end;
            DATABASE::"Service Header":
                begin
                    RecRef.SetTable(ServiceHeader);
                    NaviDocsEntry."Document Type" := ServiceHeader."Document Type".AsInteger();
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := ServiceHeader."Customer No.";
                    NaviDocsEntry."Name (Recipient)" := ServiceHeader.Name;
                    NaviDocsEntry."Name 2 (Recipient)" := ServiceHeader."Name 2";
                    NaviDocsEntry."Posting Date" := ServiceHeader."Posting Date";
                end;
            DATABASE::"Service Shipment Header":
                begin
                    RecRef.SetTable(ServiceShipmentHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := ServiceShipmentHeader."Customer No.";
                    NaviDocsEntry."Name (Recipient)" := ServiceShipmentHeader.Name;
                    NaviDocsEntry."Name 2 (Recipient)" := ServiceShipmentHeader."Name 2";
                    NaviDocsEntry."Posting Date" := ServiceShipmentHeader."Posting Date";
                end;
            DATABASE::"Service Invoice Header":
                begin
                    RecRef.SetTable(ServiceInvoiceHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := ServiceInvoiceHeader."Bill-to Customer No.";
                    NaviDocsEntry."Name (Recipient)" := ServiceInvoiceHeader."Bill-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := ServiceInvoiceHeader."Bill-to Name 2";
                    NaviDocsEntry."Posting Date" := ServiceInvoiceHeader."Posting Date";
                end;
            DATABASE::"Service Cr.Memo Header":
                begin
                    RecRef.SetTable(ServiceCrMemoHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := ServiceCrMemoHeader."Bill-to Customer No.";
                    NaviDocsEntry."Name (Recipient)" := ServiceCrMemoHeader."Bill-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := ServiceCrMemoHeader."Bill-to Name 2";
                    NaviDocsEntry."Posting Date" := ServiceCrMemoHeader."Posting Date";
                end;
            DATABASE::"Service Contract Header":
                begin
                    RecRef.SetTable(ServiceContractHeader);
                    NaviDocsEntry."Document Type" := ServiceContractHeader."Contract Type";
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    NaviDocsEntry."No. (Recipient)" := ServiceContractHeader."Bill-to Customer No.";
                    ServiceContractHeader.CalcFields("Bill-to Name", "Bill-to Name 2");
                    NaviDocsEntry."Name (Recipient)" := ServiceContractHeader."Bill-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := ServiceContractHeader."Bill-to Name 2";
                end;
            DATABASE::"Purch. Rcpt. Header":
                begin
                    RecRef.SetTable(PurchRcptHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Vendor;
                    NaviDocsEntry."No. (Recipient)" := PurchRcptHeader."Buy-from Vendor No.";
                    NaviDocsEntry."Name (Recipient)" := PurchRcptHeader."Buy-from Vendor Name";
                    NaviDocsEntry."Name 2 (Recipient)" := PurchRcptHeader."Buy-from Vendor Name 2";
                    NaviDocsEntry."Posting Date" := PurchRcptHeader."Posting Date";
                end;
            DATABASE::"Purch. Inv. Header":
                begin
                    RecRef.SetTable(PurchInvHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Vendor;
                    NaviDocsEntry."No. (Recipient)" := PurchInvHeader."Pay-to Vendor No.";
                    NaviDocsEntry."Name (Recipient)" := PurchInvHeader."Pay-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := PurchInvHeader."Pay-to Name 2";
                    NaviDocsEntry."Posting Date" := PurchInvHeader."Posting Date";
                end;
            DATABASE::"Purch. Cr. Memo Hdr.":
                begin
                    RecRef.SetTable(PurchCrMemoHdr);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Vendor;
                    NaviDocsEntry."No. (Recipient)" := PurchCrMemoHdr."Pay-to Vendor No.";
                    NaviDocsEntry."Name (Recipient)" := PurchCrMemoHdr."Pay-to Name";
                    NaviDocsEntry."Name 2 (Recipient)" := PurchCrMemoHdr."Pay-to Name 2";
                    NaviDocsEntry."Posting Date" := PurchCrMemoHdr."Posting Date";
                end;
            DATABASE::"Return Shipment Header":
                begin
                    RecRef.SetTable(ReturnShipmentHeader);
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Vendor;
                    NaviDocsEntry."No. (Recipient)" := ReturnShipmentHeader."Buy-from Vendor No.";
                    NaviDocsEntry."Name (Recipient)" := ReturnShipmentHeader."Buy-from Vendor Name";
                    NaviDocsEntry."Name 2 (Recipient)" := ReturnShipmentHeader."Buy-from Vendor Name 2";
                    NaviDocsEntry."Posting Date" := ReturnShipmentHeader."Posting Date";
                end;
        end;
    end;

    procedure DocManage(NaviDocsEntry: Record "NPR NaviDocs Entry") DocManageSuccess: Boolean
    var
        Error002: Label 'Posted Sales Invoice %1 %2 does not exist!';
        Succes001: Label 'Handled succesfully by %1.';
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
        RecRef: RecordRef;
        ReportID: Integer;
        IsDocHandled: Boolean;
        ErrorMessage: Text;
    begin
        if not (NaviDocsSetup.Get() and NaviDocsSetup."Enable NaviDocs") then
            exit(false);

        if (NaviDocsEntry."Delay sending until" <> 0DT) and (NaviDocsEntry."Delay sending until" > CurrentDateTime) then
            exit;

        DocManageSuccess := false;

        if not NaviDocsHandlingProfile.Get(NaviDocsEntry."Document Handling Profile") then begin
            InsertComment(NaviDocsEntry, StrSubstNo(Error002, NaviDocsHandlingProfile.TableCaption, NaviDocsEntry."Document Handling Profile"), true);
            exit(false);
        end;
        if NaviDocsHandlingProfile."Report Required" then begin
            ReportID := NaviDocsEntry."Report No.";
            if ReportID = 0 then
                if not RecRef.Get(NaviDocsEntry."Record ID") then begin
                    InsertComment(NaviDocsEntry, StrSubstNo(Error002, NaviDocsEntry."Document Description", NaviDocsEntry."No."), true);
                    exit(false);
                end;
            if ReportID = 0 then
                ReportID := MailAndDocumentHandling.GetReportIDFromRecRef(RecRef);
            if ReportID = 0 then begin
                InsertComment(NaviDocsEntry, StrSubstNo(Error003, RecRef.RecordId), true);
                exit(false);
            end;
        end;

        OnManageDocument(IsDocHandled, NaviDocsEntry."Document Handling Profile", NaviDocsEntry, ReportID, DocManageSuccess, ErrorMessage);

        if IsDocHandled then begin
            if DocManageSuccess then
                InsertComment(NaviDocsEntry, StrSubstNo(Succes001, NaviDocsEntry."Document Handling"), false)
            else
                InsertComment(NaviDocsEntry, ErrorMessage, true);
            exit(DocManageSuccess);
        end;

        if not RecRef.Get(NaviDocsEntry."Record ID") then begin
            InsertComment(NaviDocsEntry, StrSubstNo(Error002, NaviDocsEntry."Document Description", NaviDocsEntry."No."), true);
            exit(false);
        end;

        case NaviDocsEntry."Document Handling Profile" of
            HandlingTypePrintCode():
                DocManageSuccess := DocManagePrint(NaviDocsEntry, RecRef, ReportID);
            HandlingTypeMailCode():
                DocManageSuccess := DocManageMail(NaviDocsEntry, RecRef, ReportID);
            HandlingTypeElecDocCode():
                DocManageSuccess := DocManageElectronicDoc(NaviDocsEntry, RecRef, ReportID);
        end;

        if not DocManageSuccess then
            exit(false);

        InsertComment(NaviDocsEntry, StrSubstNo(Succes001, NaviDocsEntry."Document Handling"), false);
        exit(DocManageSuccess);
    end;

    local procedure DocManagePrint(NaviDocsEntry: Record "NPR NaviDocs Entry"; RecRef: RecordRef; ReportID: Integer): Boolean
    var
        ErrorMessage: Text[1024];
    begin
        RecRef.SetRecFilter();
        SetCustomReportLayout(RecRef, ReportID);
        ErrorMessage := PrintDoc(ReportID, false, false, RecRef);
        ClearCustomReportLayout();
        if ErrorMessage <> '' then begin
            InsertComment(NaviDocsEntry, ErrorMessage, true);
            exit(false);
        end else
            exit(true);
    end;

    local procedure DocManageMail(NaviDocsEntry: Record "NPR NaviDocs Entry"; RecRef: RecordRef; ReportID: Integer): Boolean
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        EmailDocumentManagement: Codeunit "NPR E-mail Doc. Mgt.";
        ErrorMessage: Text[1024];
    begin
        if NaviDocsEntry."E-mail (Recipient)" = '' then
            if ReportID <> 0 then
                NaviDocsEntry."E-mail (Recipient)" := EmailDocumentManagement.GetMailReceipients(RecRef, ReportID);
        if NaviDocsEntry."E-mail (Recipient)" = '' then begin
            InsertComment(NaviDocsEntry, Error004, true);
            exit(false);
        end;
        if NaviDocsEntry."Template Code" <> '' then
            EmailTemplateHeader.SetRange(Code, NaviDocsEntry."Template Code");
        if ReportID <= 0 then
            ErrorMessage := MailAndDocumentHandling.SendEmailTemplate(RecRef, EmailTemplateHeader, NaviDocsEntry."E-mail (Recipient)", true)
        else begin
            SetCustomReportLayout(RecRef, ReportID);
            SetReportReqParameters(NaviDocsEntry, ReportID);
            ErrorMessage := MailAndDocumentHandling.SendReportTemplate(ReportID, RecRef, EmailTemplateHeader, NaviDocsEntry."E-mail (Recipient)", true);
            ClearReportReqParameters(ReportID);
            ClearCustomReportLayout();
        end;
        if ErrorMessage <> '' then begin
            InsertComment(NaviDocsEntry, ErrorMessage, true);
            exit(false);
        end else
            exit(true);
    end;

    local procedure DocManageElectronicDoc(NaviDocsEntry: Record "NPR NaviDocs Entry"; RecRef: RecordRef; ReportID: Integer): Boolean
    var
        Customer: Record Customer;
        CustomerDocumentSendingProfile: Record "Document Sending Profile";
    begin
        if NaviDocsEntry."Type (Recipient)" <> NaviDocsEntry."Type (Recipient)"::Customer then begin
            InsertComment(NaviDocsEntry, StrSubstNo(Error015, NaviDocsEntry.FieldCaption("Type (Recipient)")), true);
            exit(false);
        end;
        if not Customer.Get(NaviDocsEntry."No. (Recipient)") then begin
            InsertComment(NaviDocsEntry, StrSubstNo(Error016, NaviDocsEntry."Type (Recipient)", NaviDocsEntry."No. (Recipient)"), true);
            exit(false);
        end;

        if not CustomerDocumentSendingProfile.Get(Customer."Document Sending Profile") then begin
            InsertComment(NaviDocsEntry, StrSubstNo(Error016, CustomerDocumentSendingProfile.TableCaption, Customer."Document Sending Profile"), true);
            exit(false);
        end;
        if not TrySendElectronicDoc(RecRef, CustomerDocumentSendingProfile) then begin
            InsertComment(NaviDocsEntry, GetLastErrorText, true);
            ClearLastError();
            exit(false);
        end;
    end;

    [TryFunction]
    local procedure TrySendElectronicDoc(RecRef: RecordRef; DocumentSendingProfile: Record "Document Sending Profile")
    var
        TempDocumentSendingProfile: Record "Document Sending Profile" temporary;
        ReportDistributionManagement: Codeunit "Report Distribution Management";
        PostedDocumentVariant: Variant;
    begin
        TempDocumentSendingProfile.Init();
        TempDocumentSendingProfile."Electronic Document" := TempDocumentSendingProfile."Electronic Document"::"Through Document Exchange Service";
        TempDocumentSendingProfile."Electronic Format" := DocumentSendingProfile."Electronic Format";

        PostedDocumentVariant := RecRef;
        ReportDistributionManagement.VANDocumentReport(PostedDocumentVariant, TempDocumentSendingProfile);
    end;

    local procedure PrintDoc(ReportID: Integer; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant): Text
    var
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
    begin
        ReportPrinterInterface.RunReport(ReportID, ReqWindow, SystemPrinter, Record);
        exit(ReportPrinterInterface.GetLastError());
    end;

    local procedure GetCustomReportLayout(var CustomReportLayout: Record "Custom Report Layout"; RecRef: RecordRef; ReportID: Integer): Boolean
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        if RecRef.Number in [18, 36, 112, 114] then begin
            CustomReportSelection.SetRange("Source Type", DATABASE::Customer);
            CustomReportSelection.SetRange("Source No.", Format(RecRef.Field(4).Value));
            CustomReportSelection.SetRange("Report ID", ReportID);
            if CustomReportSelection.FindFirst() then
                if CustomReportSelection."Custom Report Layout Code" <> '' then
                    exit(CustomReportLayout.Get(CustomReportSelection."Custom Report Layout Code"));
        end;
        exit(false);
    end;

    procedure CreateHandlingProfileLibrary()
    var
        HandlingTypePrintTxt: Label 'Print Document';
        HandlingTypeMailTxt: Label 'Send Document in E-Mail';
        HandlingTypeElecDocTxt: Label 'Send Electronic Document';
    begin
        AddHandlingProfileToLibrary(HandlingTypePrintCode(), HandlingTypePrintTxt, true, true, false, false);
        AddHandlingProfileToLibrary(HandlingTypeMailCode(), HandlingTypeMailTxt, true, false, true, false);
        AddHandlingProfileToLibrary(HandlingTypeElecDocCode(), HandlingTypeElecDocTxt, true, false, false, true);
        OnAddHandlingProfilesToLibrary();
    end;

    procedure AddHandlingProfileToLibrary("Code": Code[20]; Description: Text[30]; ReportRequired: Boolean; DefaultForPrint: Boolean; DefaultForEmail: Boolean; DefaultForElectronicDoc: Boolean)
    var
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
    begin
        if NaviDocsHandlingProfile.Get(Code) then
            exit;

        NaviDocsHandlingProfile.Init();
        NaviDocsHandlingProfile.Code := Code;
        NaviDocsHandlingProfile.Description := Description;
        NaviDocsHandlingProfile."Report Required" := ReportRequired;
        NaviDocsHandlingProfile."Default for Print" := DefaultForPrint;
        NaviDocsHandlingProfile."Default for E-Mail" := DefaultForEmail;
        NaviDocsHandlingProfile."Default Electronic Document" := DefaultForElectronicDoc;
        NaviDocsHandlingProfile.Insert(true);
    end;

    local procedure GetMasterTableHandlingProfiles(RecRef: RecordRef; var TempHandlingProfiles: Record "NPR NaviDocs Handling Profile" temporary)
    begin
        if not GetCustomerHandlingProfiles(RecRef, TempHandlingProfiles) then
            GetVendorHandlingProfiles(RecRef, TempHandlingProfiles);
    end;

    local procedure GetCustomerHandlingProfiles(RecRef: RecordRef; var TempHandlingProfiles: Record "NPR NaviDocs Handling Profile" temporary): Boolean
    var
        Customer: Record Customer;
        DocumentSendingProfile: Record "Document Sending Profile";
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
        CustomerNo: Code[20];
    begin
        if not TempHandlingProfiles.IsTemporary then
            Error(DevMsgNotTemporaryErr);
        TempHandlingProfiles.DeleteAll();
        CustomerNo := '';

        case RecRef.Number of
            DATABASE::Customer:
                CustomerNo := RecRef.Field(1).Value;  //No.
            DATABASE::"Sales Header":
                CustomerNo := RecRef.Field(2).Value;  //Sell-to Customer No.
            DATABASE::"Sales Shipment Header":
                CustomerNo := RecRef.Field(2).Value;  //Sell-to Customer No.
            DATABASE::"Sales Invoice Header":
                CustomerNo := RecRef.Field(4).Value;  //Bill-to Customer No.
            DATABASE::"Sales Cr.Memo Header":
                CustomerNo := RecRef.Field(4).Value;  //Bill-to Customer No.
            DATABASE::"Return Receipt Header":
                CustomerNo := RecRef.Field(2).Value;  //Sell-to Customer No.
            DATABASE::"Issued Reminder Header":
                CustomerNo := RecRef.Field(2).Value;  //Customer No.
            DATABASE::"Issued Fin. Charge Memo Header":
                CustomerNo := RecRef.Field(2).Value;  //Customer No.
            DATABASE::"Service Header":
                CustomerNo := RecRef.Field(2).Value;  //Customer No.
            DATABASE::"Service Shipment Header":
                CustomerNo := RecRef.Field(2).Value;  //Customer No.
            DATABASE::"Service Invoice Header":
                CustomerNo := RecRef.Field(4).Value;  //Bill-to Customer No.
            DATABASE::"Service Cr.Memo Header":
                CustomerNo := RecRef.Field(4).Value;  //Bill-to Customer No.
            DATABASE::"Service Contract Header":
                CustomerNo := RecRef.Field(16).Value;  //Bill-to Customer No.
            else
                exit(false);  // table is not listed as related to a Customer
        end;
        if (CustomerNo = '') or not Customer.Get(CustomerNo) then
            exit(true);

        if not DocumentSendingProfile.Get(Customer."Document Sending Profile") then
            DocumentSendingProfile.GetDefault(DocumentSendingProfile);

        if DocumentSendingProfile.Printer <> DocumentSendingProfile.Printer::No then begin
            NaviDocsHandlingProfile.SetRange("Default for Print", true);
            if NaviDocsHandlingProfile.FindFirst() then begin
                TempHandlingProfiles := NaviDocsHandlingProfile;
                TempHandlingProfiles.Description := '';
                if TempHandlingProfiles.Insert() then;
            end;
            NaviDocsHandlingProfile.SetRange("Default for Print");
        end;
        if (DocumentSendingProfile."E-Mail" <> DocumentSendingProfile."E-Mail"::No) and
            ((DocumentSendingProfile."E-Mail Attachment" = DocumentSendingProfile."E-Mail Attachment"::PDF) or
            (DocumentSendingProfile."E-Mail Attachment" = DocumentSendingProfile."E-Mail Attachment"::"PDF & Electronic Document")) then begin
            NaviDocsHandlingProfile.SetRange("Default for E-Mail", true);
            if NaviDocsHandlingProfile.FindFirst() then begin
                TempHandlingProfiles := NaviDocsHandlingProfile;
                TempHandlingProfiles.Description := Customer."E-Mail";
                if TempHandlingProfiles.Insert() then;
            end;
            NaviDocsHandlingProfile.SetRange("Default for E-Mail");
        end;
        if DocumentSendingProfile."Electronic Document" = DocumentSendingProfile."Electronic Document"::"Through Document Exchange Service" then begin
            NaviDocsHandlingProfile.SetRange("Default Electronic Document", true);
            if NaviDocsHandlingProfile.FindFirst() then begin
                TempHandlingProfiles := NaviDocsHandlingProfile;
                TempHandlingProfiles.Description := Customer."No.";
                if TempHandlingProfiles.Insert() then;
            end;
        end;
        exit(true);
    end;

    local procedure GetVendorHandlingProfiles(RecRef: RecordRef; var TempHandlingProfiles: Record "NPR NaviDocs Handling Profile" temporary): Boolean
    var
        Vendor: Record Vendor;
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
        VendorNo: Code[20];
    begin
        if not TempHandlingProfiles.IsTemporary then
            Error(DevMsgNotTemporaryErr);
        TempHandlingProfiles.DeleteAll();
        VendorNo := '';
        case RecRef.Number of
            DATABASE::Vendor:
                VendorNo := RecRef.Field(1).Value;
            DATABASE::"Purchase Header":
                VendorNo := RecRef.Field(2).Value; //Buy-from Vendor No.
            DATABASE::"Purch. Rcpt. Header":
                VendorNo := RecRef.Field(2).Value; //Buy-from Vendor No.
            DATABASE::"Purch. Inv. Header":
                VendorNo := RecRef.Field(4).Value; //Pay-to Vendor No.
            DATABASE::"Purch. Cr. Memo Hdr.":
                VendorNo := RecRef.Field(4).Value; //Pay-to Vendor No.
            DATABASE::"Return Shipment Header":
                VendorNo := RecRef.Field(2).Value; //Buy-from Vendor No.
            else
                exit(false);  // table is not listed as related to a Vendor
        end;
        if (VendorNo = '') or not Vendor.Get(VendorNo) then
            exit(true);

        NaviDocsHandlingProfile.SetRange("Default for E-Mail", true);
        if NaviDocsHandlingProfile.FindFirst() then begin
            TempHandlingProfiles := NaviDocsHandlingProfile;
            TempHandlingProfiles.Description := Vendor."E-Mail";
            if TempHandlingProfiles.Insert() then;
        end;
        exit(true);
    end;

    procedure InsertComment(NaviDocsEntry: Record "NPR NaviDocs Entry"; Comment: Text; Warning: Boolean)
    begin
        InsertCommentWithActivity(NaviDocsEntry, ActivityHandling, Comment, Warning);
    end;

    local procedure InsertCommentWithActivity(NaviDocsEntry: Record "NPR NaviDocs Entry"; Activity: Text; Comment: Text; Warning: Boolean)
    var
        NaviDocsEntryComment: Record "NPR NaviDocs Entry Comment";
        ActivityLog: Record "Activity Log";
        LineNo: Integer;
        ActivityLogStatus: Option Success,Failed;
    begin
        NaviDocsSetup.Get();
        if not NaviDocsSetup."Log to Activity Log" then begin
            NaviDocsEntryComment.LockTable();
            NaviDocsEntryComment.SetRange("Entry No.", NaviDocsEntry."Entry No.");
            if NaviDocsEntryComment.FindLast() then;
            LineNo := NaviDocsEntryComment."Line No." + 10000;

            NaviDocsEntryComment.Init();
            NaviDocsEntryComment."Entry No." := NaviDocsEntry."Entry No.";
            NaviDocsEntryComment."Table No." := NaviDocsEntry."Table No.";
            NaviDocsEntryComment."Document Type" := NaviDocsEntry."Document Type";
            NaviDocsEntryComment."Document No." := NaviDocsEntry."No.";
            NaviDocsEntryComment."Line No." := LineNo;
            NaviDocsEntryComment.Description := CopyStr(Comment, 1, MaxStrLen(NaviDocsEntryComment.Description));
            NaviDocsEntryComment.Warning := Warning;
            if NaviDocsEntryComment.Insert(true) then;
        end else begin
            if Warning then
                ActivityLogStatus := ActivityLogStatus::Failed;
            if Activity = ActivityHandling then begin
                ActivityLog.LogActivity(NaviDocsEntry.RecordId, ActivityLogStatus, ActivityContentText, CopyStr(NaviDocsEntry."Document Handling", 1, 250), CopyStr(Comment, 1, 250));
                ActivityLog.LogActivity(NaviDocsEntry."Record ID", ActivityLogStatus, ActivityContentText, CopyStr(NaviDocsEntry."Document Handling", 1, 250), CopyStr(Comment, 1, 250));
            end else
                ActivityLog.LogActivity(NaviDocsEntry.RecordId, ActivityLogStatus, ActivityContentText, CopyStr(Activity, 1, 250), CopyStr(Comment, 1, 250));
        end;
    end;

    procedure UpdateStatus(NaviDocsEntry: Record "NPR NaviDocs Entry"; Status: Integer): Boolean
    var
        Error002: Label 'Error on Manual Status Update: %1 is invalid';
        Txt001: Label 'Status Manually Updated to: %1';
        Txt011: Label 'Unhandled';
        Txt021: Label 'Error';
        Txt031: Label 'Handled';
        Comment: Text[250];
    begin
        if (Status < 0) or (Status > 2) then begin
            InsertComment(NaviDocsEntry, Error002, true);
            exit(false);
        end;

        if NaviDocsEntry.Find() then begin
            NaviDocsEntry.Status := Status;
            NaviDocsEntry."Processed Qty." := 0;
            NaviDocsEntry.Modify(true);

            case Status of
                NaviDocsStatusUnhandled():
                    Comment := StrSubstNo(Txt001, Txt011);
                NaviDocsStatusError():
                    Comment := StrSubstNo(Txt001, Txt021);
                NaviDocsStatusHandled():
                    Comment := StrSubstNo(Txt001, Txt031);
            end;
            InsertCommentWithActivity(NaviDocsEntry, ActivityStatusChange, Comment, false);
        end;

        exit(true);
    end;

    procedure UpdateStatusComment(NaviDocsEntry: Record "NPR NaviDocs Entry"; Status: Integer; Comment: Text[250]): Boolean
    var
        Error002: Label 'Error on Manual Status Update: %1 is invalid';
    begin
        if (Status < 0) or (Status > 2) then begin
            InsertComment(NaviDocsEntry, Error002, true);
            exit(false);
        end;

        NaviDocsSetup.Get();

        if NaviDocsEntry.Find() then begin
            NaviDocsEntry.Status := Status;
            NaviDocsEntry."Processed Qty." := NaviDocsSetup."Max Retry Qty";
            NaviDocsEntry.Modify(true);
            InsertCommentWithActivity(NaviDocsEntry, ActivityStatusChange, Comment, false);
        end;

        exit(true);
    end;

    procedure CheckAndUpdateStatus(var NaviDocsEntry: Record "NPR NaviDocs Entry") Updated: Boolean
    var
        Txt001: Label 'Document Handled but not from NaviDocs.';
    begin
        if NaviDocsEntry.Status = 2 then
            exit(false);

        SetHandled(NaviDocsEntry, true);
        if (NaviDocsEntry."Printed Qty." > 0) or NaviDocsEntry."OIO Sent" or (NaviDocsEntry."E-mail Qty." > 0) then begin
            NaviDocsEntry.Status := 2;
            NaviDocsEntry.Modify(true);
            InsertComment(NaviDocsEntry, Txt001, false);
            exit(true);
        end;

        exit(false);
    end;

    procedure SetHandlingProfile(var NaviDocsEntry: Record "NPR NaviDocs Entry"; NewHandlingProfile: Record "NPR NaviDocs Handling Profile"): Boolean
    begin
        if NaviDocsEntry."Document Handling Profile" <> NewHandlingProfile.Code then begin
            NaviDocsEntry.Validate("Document Handling Profile", NewHandlingProfile.Code);
            NaviDocsEntry.Modify(true);
            InsertComment(NaviDocsEntry, StrSubstNo(EntryChangedTxt, NaviDocsEntry.FieldCaption("Document Handling Profile"), NewHandlingProfile.Description), false);
            exit(true);
        end;
        exit(false);
    end;

    procedure SetHandled(var NaviDocsEntry: Record "NPR NaviDocs Entry"; ModifyRecord: Boolean)
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        RecRef: RecordRef;
        VariantVar: Variant;
    begin
        case NaviDocsEntry."Table No." of
            DATABASE::"Sales Header":
                if SalesHeader.Get(NaviDocsEntry."Document Type", NaviDocsEntry."No.") then begin
                    RecRef.GetTable(SalesHeader);
                    NaviDocsEntry."Printed Qty." := SalesHeader."No. Printed";
                end;
            DATABASE::"Sales Invoice Header":
                if SalesInvoiceHeader.Get(NaviDocsEntry."No.") then begin
                    RecRef.GetTable(SalesInvoiceHeader);
                    NaviDocsEntry."Printed Qty." := SalesInvoiceHeader."No. Printed";
                    NPRDocumentLocalization.T112_GetFieldValue(SalesInvoiceHeader, 'Electronic Invoice Created', VariantVar);
                    if VariantVar.IsBoolean then
                        NaviDocsEntry."OIO Sent" := VariantVar;
                end;
            DATABASE::"Sales Cr.Memo Header":
                if SalesCrMemoHeader.Get(NaviDocsEntry."No.") then begin
                    RecRef.GetTable(SalesCrMemoHeader);
                    NaviDocsEntry."Printed Qty." := SalesCrMemoHeader."No. Printed";
                    NPRDocumentLocalization.T114_GetFieldValue(SalesCrMemoHeader, 'Electronic Credit Memo Created', VariantVar);
                    if VariantVar.IsBoolean then
                        NaviDocsEntry."OIO Sent" := VariantVar;
                end;
            DATABASE::"Issued Reminder Header":
                if IssuedReminderHeader.Get(NaviDocsEntry."No.") then begin
                    RecRef.GetTable(IssuedReminderHeader);
                    NaviDocsEntry."Printed Qty." := IssuedReminderHeader."No. Printed";
                    NPRDocumentLocalization.T297_GetFieldValue(IssuedReminderHeader, 'Electronic Reminder Created', VariantVar);
                    if VariantVar.IsBoolean then
                        NaviDocsEntry."OIO Sent" := VariantVar;
                end;
            DATABASE::"Issued Fin. Charge Memo Header":
                if IssuedFinChargeMemoHeader.Get(NaviDocsEntry."No.") then begin
                    RecRef.GetTable(IssuedFinChargeMemoHeader);
                    NaviDocsEntry."Printed Qty." := IssuedFinChargeMemoHeader."No. Printed";
                    NPRDocumentLocalization.T304_GetFieldValue(IssuedFinChargeMemoHeader, 'Elec. Fin. Charge Memo Created', VariantVar);
                    if VariantVar.IsBoolean then
                        NaviDocsEntry."OIO Sent" := VariantVar;
                end;
        end;

        if ModifyRecord then
            NaviDocsEntry.Modify(true);
    end;

    procedure ConvertLog()
    var
        NaviDocsEntry: Record "NPR NaviDocs Entry";
        NaviDocsEntryComment: Record "NPR NaviDocs Entry Comment";
        ActivityLog: Record "Activity Log";
        ConvertOldLogEntryText: Label 'Convert existing Log entries to Activity Log?';
        ConvertCompleteText: Label 'Convertion complete.';
    begin
        if not Confirm(ConvertOldLogEntryText) then
            exit;
        if NaviDocsEntry.FindSet() then
            repeat
                NaviDocsEntryComment.SetRange("Table No.", NaviDocsEntry."Table No.");
                NaviDocsEntryComment.SetRange("Document Type", NaviDocsEntry."Document Type");
                NaviDocsEntryComment.SetRange("Document No.", NaviDocsEntry."No.");
                if NaviDocsEntryComment.FindSet() then
                    repeat
                        ActivityLog.Init();
                        ActivityLog.ID := 0;
                        ActivityLog."Record ID" := NaviDocsEntry.RecordId;
                        ActivityLog."Activity Date" := CreateDateTime(NaviDocsEntryComment."Insert Date", NaviDocsEntryComment."Insert Time");
                        ActivityLog."User ID" := NaviDocsEntryComment."User ID";
                        if NaviDocsEntryComment.Warning then
                            ActivityLog.Status := ActivityLog.Status::Failed
                        else
                            ActivityLog.Status := ActivityLog.Status::Success;
                        ActivityLog.Context := ActivityContentText;
                        ActivityLog.Description := 'Converted';
                        ActivityLog."Activity Message" := NaviDocsEntryComment.Description;
                        ActivityLog.Insert(true);
                    until NaviDocsEntryComment.Next() = 0;
            until NaviDocsEntry.Next() = 0;
        Message(ConvertCompleteText);
    end;

    local procedure SetCustomReportLayout(RecRef: RecordRef; ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
        CustomReportLayoutVariant: Variant;
    begin
        if RecRef.Number in [18, 36, 112, 114] then begin
            CustomReportSelection.SetRange("Source Type", DATABASE::Customer);
            if RecRef.Number = 18 then
                CustomReportSelection.SetRange("Source No.", Format(RecRef.Field(1).Value))
            else
                CustomReportSelection.SetRange("Source No.", Format(RecRef.Field(4).Value));
            CustomReportSelection.SetRange("Report ID", ReportID);
            if CustomReportSelection.FindFirst() then begin
                EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection, CustomReportLayoutVariant);
                if CustomReportLayout.Get(CustomReportLayoutVariant) then
                    ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutVariant);
            end;
        end;
    end;

    local procedure ClearCustomReportLayout()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
        BlankVariant: Variant;
    begin
        EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection, BlankVariant);
        ReportLayoutSelection.SetTempLayoutSelected(BlankVariant);
    end;

    local procedure SetReportReqParameters(NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer)
    var
        NaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment";
        InStr: InStream;
        Parameters: Text;
    begin
        NaviDocsEntryAttachment.SetRange("NaviDocs Entry No.", NaviDocsEntry."Entry No.");
        NaviDocsEntryAttachment.SetRange("Internal Type", NaviDocsEntryAttachment."Internal Type"::"Report Parameters");
        if NaviDocsEntryAttachment.FindSet() then
            repeat
                NaviDocsEntryAttachment.CalcFields(Data);
                NaviDocsEntryAttachment.Data.CreateInStream(InStr);
                InStr.ReadText(Parameters);
                MailAndDocumentHandling.StoreRequestParameters(ReportID, Parameters);
            until NaviDocsEntryAttachment.Next() = 0;
    end;

    local procedure ClearReportReqParameters(ReportID: Integer)
    begin
        MailAndDocumentHandling.ClearRequestParameters(ReportID);
    end;

    procedure PageAccountCard(NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        case NaviDocsEntry."Type (Recipient)" of
            NaviDocsEntry."Type (Recipient)"::Customer:
                begin
                    Customer.Get(NaviDocsEntry."No. (Recipient)");
                    PAGE.RunModal(PAGE::"Customer Card", Customer);
                end;
            NaviDocsEntry."Type (Recipient)"::Vendor:
                begin
                    Vendor.Get(NaviDocsEntry."No. (Recipient)");
                    PAGE.RunModal(PAGE::"Vendor Card", Vendor);
                end;
            NaviDocsEntry."Type (Recipient)"::Contact:
                begin
                    Contact.Get(NaviDocsEntry."No. (Recipient)");
                    PAGE.RunModal(PAGE::"Contact Card", Contact);
                end;
        end;
    end;

    procedure PageDocumentCard(NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        RecRef: RecordRef;
        RecVariant: Variant;
        PageManagement: Codeunit "Page Management";
    begin
        RecRef.Get(NaviDocsEntry."Record ID");
        RecVariant := RecRef;
        PageManagement.PageRun(RecVariant);
    end;

    procedure PageMailAndDocCard(NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        MailAndDocumentHeader: Record "NPR E-mail Template Header";
        EmailManagement: Codeunit "NPR E-mail Management";
        Handled: Boolean;
    begin
        OnShowTemplate(Handled, NaviDocsEntry);
        if Handled then
            exit;
        if NaviDocsEntry."Template Code" <> '' then
            MailAndDocumentHeader.SetRange(Code, NaviDocsEntry."Template Code")
        else begin
            Clear(MailAndDocumentHeader);
            MailAndDocumentHeader.SetRange("Table No.", NaviDocsEntry."Table No.");
            MailAndDocumentHeader.SetRange("Report ID", NaviDocsEntry."Report No.");
            MailAndDocumentHeader.SetFilter(Group, '%1', EmailManagement.GetDefaultGroupFilter());
            if not MailAndDocumentHeader.FindFirst() then
                MailAndDocumentHeader.SetRange("Report ID");
        end;
        PAGE.RunModal(PAGE::"NPR E-mail Template", MailAndDocumentHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddDocumentEntry(var IsInsertHandled: Boolean; var RecRef: RecordRef; var HandlingProfile: Code[20]; var ReportNo: Integer; var Recipient: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddDocumentEntryExt(var InsertedEntryNo: BigInteger; var RecRef: RecordRef; var HandlingProfile: Code[20]; var ReportNo: Integer; var Recipient: Text; var TemplateCode: Code[20]; var DelayUntil: DateTime)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddHandlingProfilesToLibrary()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnManageDocument(var IsDocumentHandled: Boolean; ProfileCode: Code[20]; var NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer; var WithSuccess: Boolean; var ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowTemplate(var RequestHandled: Boolean; NaviDocsEntry: Record "NPR NaviDocs Entry")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014464, 'OnBeforeSendReport', '', true, true)]
    local procedure EMailDocMgtSendReportEvent(RecVariant: Variant; Silent: Boolean; var OverruleMail: Boolean)
    var
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
        TestNumber: Record "Integer";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        EmailDocumentManagement: Codeunit "NPR E-mail Doc. Mgt.";
        EMailMgt: Codeunit "NPR E-mail Management";
        ReportID: Integer;
        Recipient: Text;
    begin
        if not NaviDocsSetup.Get() then
            exit;
        if not (NaviDocsSetup."Enable NaviDocs" and NaviDocsSetup."Pdf2Nav Send pdf") then
            exit;
        if not DataTypeManagement.GetRecordRef(RecVariant, RecRef) then
            exit;
        if NaviDocsSetup."Pdf2Nav Table Filter" <> '' then begin
            TestNumber.FilterGroup(55);
            TestNumber.SetFilter(Number, NaviDocsSetup."Pdf2Nav Table Filter");
            TestNumber.FilterGroup(0);
            TestNumber.SetRange(Number, RecRef.Number);
            if not TestNumber.FindFirst() then
                exit;
        end;
        NaviDocsHandlingProfile.Get(HandlingTypeMailCode());
        if NaviDocsHandlingProfile."Report Required" then
            ReportID := EMailMgt.GetReportIDFromRecRef(RecRef);
        Recipient := EMailMgt.GetCustomReportEmailAddress();
        if Recipient = '' then
            Recipient := EmailDocumentManagement.GetMailReceipients(RecRef, ReportID);
        AddDocumentEntryWithHandlingProfile(RecRef, HandlingTypeMailCode(), ReportID, Recipient, 0DT);

        OverruleMail := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnBeforeAddDocumentEntryExt', '', true, true)]
    local procedure OnBeforeAddPOSEntryDocumentEntry(var InsertedEntryNo: BigInteger; var RecRef: RecordRef; var HandlingProfile: Code[20]; var ReportNo: Integer; var Recipient: Text; var TemplateCode: Code[20]; var DelayUntil: DateTime)
    var
        POSEntry: Record "NPR POS Entry";
        NaviDocsEntry: Record "NPR NaviDocs Entry";
        Customer: Record Customer;
        Contact: Record Contact;
        EmailMgt: Codeunit "NPR E-mail Management";
        RecipientRecRef: RecordRef;
    begin
        if InsertedEntryNo <> 0 then
            exit;

        if RecRef.Number <> DATABASE::"NPR POS Entry" then
            exit;

        if not POSEntry.Get(RecRef.RecordId) then
            exit;

        NaviDocsEntry.Init();
        NaviDocsEntry."Entry No." := 0;
        NaviDocsEntry.Validate("Record ID", RecRef.RecordId);
        NaviDocsEntry.Validate("Table No.", RecRef.Number);
        NaviDocsEntry."Document Description" := POSEntry.TableCaption;
        NaviDocsEntry."No." := POSEntry."Document No.";
        NaviDocsEntry."Posting Date" := POSEntry."Entry Date";

        case true of
            POSEntry."Customer No." <> '':
                begin
                    NaviDocsEntry."No. (Recipient)" := POSEntry."Customer No.";
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
                    if (Recipient = '') and (HandlingProfile = HandlingTypeMailCode()) then
                        if Customer.Get(NaviDocsEntry."No. (Recipient)") then begin
                            RecipientRecRef.GetTable(Customer);
                            Recipient := EmailMgt.GetEmailAddressFromRecRef(RecipientRecRef);
                        end;
                end;
            POSEntry."Contact No." <> '':
                begin
                    NaviDocsEntry."No. (Recipient)" := POSEntry."Contact No.";
                    NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Contact;
                    if (Recipient = '') and (HandlingProfile = HandlingTypeMailCode()) then
                        if Contact.Get(NaviDocsEntry."No. (Recipient)") then begin
                            RecipientRecRef.GetTable(Contact);
                            Recipient := EmailMgt.GetEmailAddressFromRecRef(RecipientRecRef);
                        end;
                end;
        end;

        NaviDocsEntry.Validate("Document Handling Profile", HandlingProfile);
        NaviDocsEntry."E-mail (Recipient)" := Recipient;
        NaviDocsEntry."Report No." := ReportNo;
        NaviDocsEntry."Delay sending until" := DelayUntil;
        NaviDocsEntry."Template Code" := TemplateCode;
        NaviDocsEntry.Insert(true);
        InsertedEntryNo := NaviDocsEntry."Entry No.";
    end;

    [TryFunction]
    procedure TrySendWarningMail(NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        NaviDocsEntryComment: Record "NPR NaviDocs Entry Comment";
        EmailSetup: Record "NPR E-mail Setup";
        MailSeparators: List of [Text];
        Txt001: Label 'NaviDocs Error %1 - %2';
        MailManagement: Codeunit "Mail Management";
        EmailItem: Record "Email Item" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
    begin
        NaviDocsSetup.Get();
        if not NaviDocsSetup."Send Warming E-mail" then
            exit;
        if not MailManagement.IsEnabled() then
            exit;


        MailSeparators.Add(';');
        MailSeparators.Add(',');


        EmailSenderHandler.CreateEmailItem(EmailItem, EmailSetup."From Name", EmailSetup."From E-mail Address",
                                            NaviDocsSetup."Warning E-mail".Split(MailSeparators),
                                            StrSubstNo(Txt001, NaviDocsEntry."Document Description", NaviDocsEntry."No."), '', true);

        NaviDocsEntryComment.SetRange("Entry No.", NaviDocsEntry."Entry No.");
        NaviDocsEntryComment.SetRange("Table No.", NaviDocsEntry."Table No.");
        NaviDocsEntryComment.SetRange("Document Type", NaviDocsEntry."Document Type");
        NaviDocsEntryComment.SetRange("Document No.", NaviDocsEntry."No.");
        if NaviDocsEntryComment.FindLast() then
            EmailSenderHandler.AppendBodyLine(EmailItem, NaviDocsEntryComment.Description + '<br><br>');

        EmailSenderHandler.Send(EmailItem);
    end;

    procedure NaviDocsStatusUnhandled(): Integer
    begin
        exit(0);
    end;

    procedure NaviDocsStatusError(): Integer
    begin
        exit(1);
    end;

    procedure NaviDocsStatusHandled(): Integer
    begin
        exit(2);
    end;

    procedure HandlingTypePrintCode(): Code[20]
    begin
        exit('PRINT');
    end;

    procedure HandlingTypeMailCode(): Code[20]
    begin
        exit('E-MAIL');
    end;

    procedure HandlingTypeElecDocCode(): Code[20]
    begin
        exit('ELECTRONIC DOC');
    end;
}

