codeunit 6059767 "NaviDocs Management"
{
    // NPR71.00.00.01/MH/20140820  Hotfixed due to Refactoring of PDF2NAV.
    // NPR4.12/TSA/20150703 CASE 216800 - Created W1 Version, moved functionality relating to Danish localization to other codeunit
    // NPR9   /LS/20151022  CASE 225607  Changed Global variable SmtpMessage in function SendWarningMailfrom version 8.0 to 9.0
    // PN1.09/MHA/20160114 CASE 195494 Removed references to Statement Report as NaviDocs Customer is not yet implemented
    // 
    //                                   Removed Kop&Kande from warning mail subject (local text constant)
    // NPR5.23/MMV /20160609 CASE 240856 Added PrintDoc() with support for alternative print methods.
    //                                   Removed case on Statement Report since the functionality itself was already removed in PN1.09
    //                                   Removed NPR71 comments in DocManage functions.
    // NPR5.26/THRO/20160803 CASE 248662 Cleanup and redesigned to handle more tables and Handling Profiles
    // NPR5.26/THRO/20160908 CASE 250371 Delay sending.
    // NPR5.26/BR  /20160916 CASE 244114 Fix sending without report
    // NPR5.27/THRO/20161004 CASE 254280 Bugfix EMailDocMgtSendReportEvent
    // NPR5.28/MMV /20161104 CASE 254575 Added support for new "Contact" option.
    //                                   Added support for Audit Roll via new subscriber function OnBeforeAddEmailAuditRollDocumentEntry()
    //                                   PDF2NAV handling: Subscribe to new event & always create e-mail entries.
    // NPR5.29/THRO/20161229 CASE 262219 Filter to current record when using Print
    //                                   NAV2017 functionality changes in eletronic document sending
    // NPR5.30/THRO/20170209 CASE 243998 Use Activity Log for Logging. Added InsertCommentWithActivity + ConvertLog
    // NPR5.31/THRO/20170330 CASE 260773 Use email address and layout from Custom Report Selection
    // NPR5.31/JLK /20170313 CASE 268274 Removed unused text constant
    // NPR5.36/THRO/20170913 CASE 289216 Group on E-Mail Template
    // NPR5.38/THRO/20171108 CASE 295065 Moved NAV version specific code to wrapper codeunit
    // NPR5.40/THRO/20180301 CASE 306875 Added SetHandlingProfile
    // NPR5.40/THRO/20180305 CASE 305875 Added support for POS Entry via new subscriber function OnBeforeAddPOSEntryDocumentEntry()
    // NPR5.42/THRO/20180522 CASE 308861 Changed TryFunction to ASSERTERROR
    // NPR5.42/THRO/20180522 CASE 308861 Added OnBeforeAddDocumentEntryExt publisher with extended parameters. using new publisher in OnBeforeAddAuditRollDocumentEntry and OnBeforeAddPOSEntryDocumentEntry
    // NPR5.43/THRO/20180614 CASE 315958 Added functionality for Attachments
    // NPR5.43/THRO/20180615 CASE 308861 Fixed the TryDocManage (change from TryFuntion to ASSERTERROR)
    // NPR5.43/THRO/20180618 CASE 316218 Custom Report Layout for Customer Statement

    TableNo = "NaviDocs Entry";

    trigger OnRun()
    var
        ManagementStatus: Boolean;
    begin
        if not (NaviDocsSetup.Get and
                NaviDocsSetup."Enable NaviDocs" and
                (Status <> 2)) then
          exit;
        //-NPR5.26
        if ("Delay sending until" <> 0DT) and ("Delay sending until" > CurrentDateTime) then
          exit;
        //+NPR5.26

        "Processed Qty." += 1;
        Status := 1;
        Modify;
        Commit;

        //-NPR5.26 [248662]
        //-NPR5.43 [308861]
        //IF NOT TryDocManage(Rec,ManagementStatus) THEN BEGIN
        ManagementStatus := TryDocManage(Rec);
        if (not ManagementStatus) and (GetLastErrorText <> '') then begin
        //-NPR5.43 [308861]
          InsertComment(Rec,GetLastErrorText,true);
          ClearLastError;
        end;
        //+NPR5.26 [248662]

        if ManagementStatus then
          Status := 2
        else
          if TrySendWarningMail(Rec) then;

        Modify(true);
    end;

    var
        NaviDocsSetup: Record "NaviDocs Setup";
        MailAndDocumentHandling: Codeunit "E-mail Management";
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

    procedure AddDocumentEntry(RecRef: RecordRef;ReportNo: Integer)
    var
        TempHandlingProfile: Record "NaviDocs Handling Profile" temporary;
    begin
        if not NaviDocsSetup.Get then
          exit;
        //-NPR5.26 [248662]
        OnAddHandlingProfilesToLibrary;
        GetMasterTableHandlingProfiles(RecRef,TempHandlingProfile);
        if TempHandlingProfile.FindSet then
          repeat
        //-NPR5.26
        //    AddDocumentEntryWithHandlingProfile(RecRef,TempHandlingProfile.Code,ReportNo,TempHandlingProfile.Description);
            AddDocumentEntryWithHandlingProfile(RecRef,TempHandlingProfile.Code,ReportNo,TempHandlingProfile.Description,0DT);
        //+NPR5.26
          until TempHandlingProfile.Next = 0;

        //+NPR5.26 [248662]
    end;

    procedure AddDocumentEntryWithHandlingProfile(RecRef: RecordRef;HandlingProfile: Code[20];ReportNo: Integer;Recipient: Text;DelayUntil: DateTime)
    var
        NaviDocsEntry: Record "NaviDocs Entry";
        TableMetadata: Record "Table Metadata";
        InsertIsHandled: Boolean;
        PrimaryKey: KeyRef;
        I: Integer;
        DocType: Integer;
    begin
        //-NPR5.36 [289216]
        AddDocumentEntryWithHandlingProfileExt(RecRef,HandlingProfile,ReportNo,Recipient,'',DelayUntil);
        //+NPR5.36 [289216]
    end;

    procedure AddDocumentEntryWithHandlingProfileExt(RecRef: RecordRef;HandlingProfile: Code[20];ReportNo: Integer;Recipient: Text;TemplateCode: Code[20];DelayUntil: DateTime): BigInteger
    var
        NaviDocsEntry: Record "NaviDocs Entry";
        TableMetadata: Record "Table Metadata";
        InsertIsHandled: Boolean;
        PrimaryKey: KeyRef;
        I: Integer;
        DocType: Integer;
        InsertedEntryNo: BigInteger;
    begin
        //-NPR5.36 [289216]
        if not NaviDocsSetup.Get then
          exit;
        if not NaviDocsSetup."Enable NaviDocs" then
          exit;

        OnBeforeAddDocumentEntry(InsertIsHandled,RecRef,HandlingProfile,ReportNo,Recipient);
        if InsertIsHandled then
          exit;
        //-NPR5.42 [308861]
        //-NPR5.43 [315958]
        InsertedEntryNo := 0;
        OnBeforeAddDocumentEntryExt(InsertedEntryNo,RecRef,HandlingProfile,ReportNo,Recipient,TemplateCode,DelayUntil);
        if InsertedEntryNo <> 0 then
          exit(InsertedEntryNo);
        //+NPR5.43 [315958]
        //+NPR5.42 [308861]

        if RecRef.Get(RecRef.RecordId) then begin
          NaviDocsEntry.Init;
          NaviDocsEntry."Entry No." := 0;
          NaviDocsEntry.Validate("Record ID",RecRef.RecordId);

          NaviDocsEntry.Validate("Table No.",RecRef.Number);
          NaviDocsEntry."Document Description" := '';
          if TableMetadata.Get(RecRef.Number) then
            NaviDocsEntry."Document Description" += TableMetadata.Caption;
          PrimaryKey := RecRef.KeyIndex(1);
          for I := 1 to PrimaryKey.FieldCount - 1 do
            NaviDocsEntry."Document Description" += ' ' + Format(PrimaryKey.FieldIndex(I).Value);

          NaviDocsEntry."No." := CopyStr(Format(PrimaryKey.FieldIndex(PrimaryKey.FieldCount).Value),1,20);
          TransferFromTable(NaviDocsEntry,RecRef);

          NaviDocsEntry.Validate("Document Handling Profile",HandlingProfile);
          if Recipient <> '' then
            NaviDocsEntry."E-mail (Recipient)" := Recipient;

          NaviDocsEntry."Report No." := ReportNo;
          NaviDocsEntry."Delay sending until" := DelayUntil;
        //-NPR5.36 [289216]
          NaviDocsEntry."Template Code" := TemplateCode;
        //+NPR5.36 [289216]
          NaviDocsEntry.Insert(true);
          //-NPR5.43 [315958]
          InsertedEntryNo := NaviDocsEntry."Entry No.";
          //+NPR5.43 [315958]
        end;
        //+NPR5.36 [289216]
        //-NPR5.43 [315958]
        exit(InsertedEntryNo);
        //+NPR5.43 [315958]
    end;

    procedure AddDocumentEntryWithAttachments(RecRef: RecordRef;HandlingProfile: Code[20];ReportNo: Integer;Recipient: Text;TemplateCode: Code[20];DelayUntil: DateTime;var Attachments: Record "NaviDocs Entry Attachment"): Boolean
    var
        NaviDocsEntryAttachment: Record "NaviDocs Entry Attachment";
        NewEntryNo: BigInteger;
    begin
        //-NPR5.43 [315958]
        NewEntryNo := AddDocumentEntryWithHandlingProfileExt(RecRef,HandlingProfile,ReportNo,Recipient,TemplateCode,DelayUntil);
        if NewEntryNo = 0 then
          exit(false);
        if Attachments.FindSet then
          repeat
            Attachments.CalcFields(Data);
            NaviDocsEntryAttachment := Attachments;
            NaviDocsEntryAttachment."NaviDocs Entry No." := NewEntryNo;
            NaviDocsEntryAttachment.Insert(true);
          until Attachments.Next = 0;
        //+NPR5.43 [315958]
    end;

    local procedure TransferFromTable(var NaviDocsEntry: Record "NaviDocs Entry";RecRef: RecordRef)
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
        with NaviDocsEntry do begin
          case RecRef.Number of
            DATABASE::Customer :
              begin
                RecRef.SetTable(Customer);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := Customer."No.";
                "Name (Recipient)" := Customer.Name;
                "Name 2 (Recipient)" := Customer."Name 2";
              end;
            DATABASE::Vendor :
              begin
                RecRef.SetTable(Vendor);
                "Type (Recipient)" := "Type (Recipient)"::Vendor;
                "No. (Recipient)" := Vendor."No.";
                "Name (Recipient)" := Vendor.Name;
                "Name 2 (Recipient)" := Vendor."Name 2";
              end;
            DATABASE::"Sales Header" :
              begin
                RecRef.SetTable(SalesHeader);
                "Document Type" := SalesHeader."Document Type";
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := SalesHeader."Sell-to Customer No.";
                "Name (Recipient)" := SalesHeader."Sell-to Customer Name";
                "Name 2 (Recipient)" := SalesHeader."Sell-to Customer Name 2";
                "Posting Date" := SalesHeader."Posting Date";
                "External Document No." := SalesHeader."External Document No.";
              end;
            DATABASE::"Purchase Header" :
              begin
                RecRef.SetTable(PurchHeader);
                "Document Type" := PurchHeader."Document Type";
                "Type (Recipient)" := "Type (Recipient)"::Vendor;
                "No. (Recipient)" := PurchHeader."Buy-from Vendor No.";
                "Posting Date" := PurchHeader."Posting Date";
                "Name (Recipient)" := PurchHeader."Buy-from Vendor Name";
                "Name 2 (Recipient)" := PurchHeader."Buy-from Vendor Name 2";
              end;
            DATABASE::"Sales Shipment Header" :
              begin
                RecRef.SetTable(SalesShipmentHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := SalesShipmentHeader."Sell-to Customer No.";
                "Posting Date" := SalesShipmentHeader."Posting Date";
                "Name (Recipient)" := SalesShipmentHeader."Sell-to Customer Name";
                "Name 2 (Recipient)" := SalesShipmentHeader."Sell-to Customer Name 2";
                "External Document No." := SalesShipmentHeader."External Document No.";
              end;
            DATABASE::"Sales Invoice Header" :
              begin
                RecRef.SetTable(SalesInvoiceHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := SalesInvoiceHeader."Bill-to Customer No.";
                "Posting Date" := SalesInvoiceHeader."Posting Date";
                "Name (Recipient)" := SalesInvoiceHeader."Bill-to Name";
                "Name 2 (Recipient)" := SalesInvoiceHeader."Bill-to Name 2";
                "Order No." := SalesInvoiceHeader."Order No.";
                "External Document No." := SalesInvoiceHeader."External Document No.";
              end;
            DATABASE::"Sales Cr.Memo Header" :
              begin
                RecRef.SetTable(SalesCrMemoHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := SalesCrMemoHeader."Bill-to Customer No.";
                "Posting Date" := SalesCrMemoHeader."Posting Date";
                "Name (Recipient)" := SalesCrMemoHeader."Bill-to Name";
                "Name 2 (Recipient)" := SalesCrMemoHeader."Bill-to Name 2";
                "External Document No." := SalesCrMemoHeader."External Document No.";
              end;
            DATABASE::"Issued Reminder Header" :
              begin
                RecRef.SetTable(IssuedReminderHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := IssuedReminderHeader."Customer No.";
                "Name (Recipient)" := IssuedReminderHeader.Name;
                "Name 2 (Recipient)" := IssuedReminderHeader."Name 2";
                "Posting Date" := IssuedReminderHeader."Posting Date";
              end;
            DATABASE::"Issued Fin. Charge Memo Header" :
              begin
                RecRef.SetTable(IssuedFinChargeMemoHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := IssuedFinChargeMemoHeader."Customer No.";
                "Name (Recipient)" := IssuedFinChargeMemoHeader.Name;
                "Name 2 (Recipient)" := IssuedFinChargeMemoHeader."Name 2";
                "Posting Date" := IssuedFinChargeMemoHeader."Posting Date";
              end;
            DATABASE::"Return Receipt Header" :
              begin
                RecRef.SetTable(ReturnReceiptHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := ReturnReceiptHeader."Sell-to Customer No.";
                "Name (Recipient)" := ReturnReceiptHeader."Sell-to Customer Name";
                "Name 2 (Recipient)" := ReturnReceiptHeader."Sell-to Customer Name 2";
                "Posting Date" :=ReturnReceiptHeader."Posting Date";
              end;
            DATABASE::"Service Header" :
              begin
                RecRef.SetTable(ServiceHeader);
                "Document Type" := ServiceHeader."Document Type";
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := ServiceHeader."Customer No.";
                "Name (Recipient)" := ServiceHeader.Name;
                "Name 2 (Recipient)" := ServiceHeader."Name 2";
                "Posting Date" := ServiceHeader."Posting Date";
              end;
            DATABASE::"Service Shipment Header" :
              begin
                RecRef.SetTable(ServiceShipmentHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := ServiceShipmentHeader."Customer No.";
                "Name (Recipient)" := ServiceShipmentHeader.Name;
                "Name 2 (Recipient)" := ServiceShipmentHeader."Name 2";
                "Posting Date" := ServiceShipmentHeader."Posting Date";
              end;
            DATABASE::"Service Invoice Header" :
              begin
                RecRef.SetTable(ServiceInvoiceHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := ServiceInvoiceHeader."Bill-to Customer No.";
                "Name (Recipient)" := ServiceInvoiceHeader."Bill-to Name";
                "Name 2 (Recipient)" := ServiceInvoiceHeader."Bill-to Name 2";
                "Posting Date" := ServiceInvoiceHeader."Posting Date";
              end;
            DATABASE::"Service Cr.Memo Header" :
              begin
                RecRef.SetTable(ServiceCrMemoHeader);
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := ServiceCrMemoHeader."Bill-to Customer No.";
                "Name (Recipient)" := ServiceCrMemoHeader."Bill-to Name";
                "Name 2 (Recipient)" := ServiceCrMemoHeader."Bill-to Name 2";
                "Posting Date" := ServiceCrMemoHeader."Posting Date";
              end;
            DATABASE::"Service Contract Header" :
              begin
                RecRef.SetTable(ServiceContractHeader);
                "Document Type" := ServiceContractHeader."Contract Type";
                "Type (Recipient)" := "Type (Recipient)"::Customer;
                "No. (Recipient)" := ServiceContractHeader."Bill-to Customer No.";
                ServiceContractHeader.CalcFields("Bill-to Name","Bill-to Name 2");
                "Name (Recipient)" := ServiceContractHeader."Bill-to Name";
                "Name 2 (Recipient)" := ServiceContractHeader."Bill-to Name 2";
              end;
            DATABASE::"Purch. Rcpt. Header" :
              begin
                RecRef.SetTable(PurchRcptHeader);
                "Type (Recipient)" := "Type (Recipient)"::Vendor;
                "No. (Recipient)" := PurchRcptHeader."Buy-from Vendor No.";
                "Name (Recipient)" := PurchRcptHeader."Buy-from Vendor Name";
                "Name 2 (Recipient)" := PurchRcptHeader."Buy-from Vendor Name 2";
                "Posting Date" := PurchRcptHeader."Posting Date";
              end;
            DATABASE::"Purch. Inv. Header" :
              begin
                RecRef.SetTable(PurchInvHeader);
                "Type (Recipient)" := "Type (Recipient)"::Vendor;
                "No. (Recipient)" := PurchInvHeader."Pay-to Vendor No.";
                "Name (Recipient)" := PurchInvHeader."Pay-to Name";
                "Name 2 (Recipient)" := PurchInvHeader."Pay-to Name 2";
                "Posting Date" := PurchInvHeader."Posting Date";
              end;
            DATABASE::"Purch. Cr. Memo Hdr." :
              begin
                RecRef.SetTable(PurchCrMemoHdr);
                "Type (Recipient)" := "Type (Recipient)"::Vendor;
                "No. (Recipient)" := PurchCrMemoHdr."Pay-to Vendor No.";
                "Name (Recipient)" := PurchCrMemoHdr."Pay-to Name";
                "Name 2 (Recipient)" := PurchCrMemoHdr."Pay-to Name 2";
                "Posting Date" := PurchCrMemoHdr."Posting Date";
              end;
            DATABASE::"Return Shipment Header" :
              begin
                RecRef.SetTable(ReturnShipmentHeader);
                "Type (Recipient)" := "Type (Recipient)"::Vendor;
                "No. (Recipient)" := ReturnShipmentHeader."Buy-from Vendor No.";
                "Name (Recipient)" := ReturnShipmentHeader."Buy-from Vendor Name";
                "Name 2 (Recipient)" := ReturnShipmentHeader."Buy-from Vendor Name 2";
                "Posting Date" := ReturnShipmentHeader."Posting Date";
              end;
          end;
        end;
    end;

    procedure "--- Document Management"()
    begin
    end;

    local procedure TryDocManage(NaviDocsEntry: Record "NaviDocs Entry"): Boolean
    var
        DocManageSuccess: Boolean;
    begin
        //-NPR5.43 [308861]
        asserterror begin
          DocManageSuccess := DocManage(NaviDocsEntry);
          Commit;
          Error('');
        end;
        exit(DocManageSuccess);
        //+NPR5.43 [308861]
    end;

    procedure DocManage(NaviDocsEntry: Record "NaviDocs Entry") DocManageSuccess: Boolean
    var
        Error002: Label 'Posted Sales Invoice %1 does not exist!';
        Succes001: Label 'Handled succesfully by %1.';
        Customer: Record Customer;
        Vendor: Record Vendor;
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
        RecRef: RecordRef;
        ReportID: Integer;
        IsDocHandled: Boolean;
        ErrorMessage: Text;
    begin
        //-NPR5.26 [248662]
        if not (NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs") then
        //+NPR5.26 [248662]
          exit(false);

        //-NPR5.26
        if (NaviDocsEntry."Delay sending until" <> 0DT) and (NaviDocsEntry."Delay sending until" > CurrentDateTime) then
          exit;
        //+NPR5.26

        DocManageSuccess := false;

        //-NPR5.26 [248662]
        if not NaviDocsHandlingProfile.Get(NaviDocsEntry."Document Handling Profile") then begin
          InsertComment(NaviDocsEntry,StrSubstNo(Error002,NaviDocsHandlingProfile.TableCaption,NaviDocsEntry."Document Handling Profile"),true);
          exit(false);
        end;
        if NaviDocsHandlingProfile."Report Required" then begin
          ReportID := NaviDocsEntry."Report No.";
          if ReportID = 0 then
            if not RecRef.Get(NaviDocsEntry."Record ID") then begin
              InsertComment(NaviDocsEntry,StrSubstNo(Error002,NaviDocsEntry."Document Description",NaviDocsEntry."No."),true);
              exit(false);
            end;
          if ReportID = 0 then
            ReportID := MailAndDocumentHandling.GetReportIDFromRecRef(RecRef);
          if ReportID = 0 then begin
            InsertComment(NaviDocsEntry,StrSubstNo(Error003,RecRef.RecordId),true);
            exit(false);
          end;
        end;

        OnManageDocument(IsDocHandled,NaviDocsEntry."Document Handling Profile",NaviDocsEntry,ReportID,DocManageSuccess,ErrorMessage);

        if IsDocHandled then begin
          if DocManageSuccess then
            InsertComment(NaviDocsEntry,StrSubstNo(Succes001,NaviDocsEntry."Document Handling"),false)
          else
            InsertComment(NaviDocsEntry,ErrorMessage,true);
          exit(DocManageSuccess);
        end;

        if not RecRef.Get(NaviDocsEntry."Record ID") then begin
          InsertComment(NaviDocsEntry,StrSubstNo(Error002,NaviDocsEntry."Document Description",NaviDocsEntry."No."),true);
          exit(false);
        end;

        case NaviDocsEntry."Document Handling Profile" of
          HandlingTypePrintCode : DocManageSuccess := DocManagePrint(NaviDocsEntry,RecRef,ReportID);
          HandlingTypeMailCode : DocManageSuccess := DocManageMail(NaviDocsEntry,RecRef,ReportID);
          HandlingTypeElecDocCode : DocManageSuccess := DocManageElectronicDoc(NaviDocsEntry,RecRef,ReportID);
        end;
        //+NPR5.26 [248662]

        if not DocManageSuccess then
          exit(false);

        InsertComment(NaviDocsEntry,StrSubstNo(Succes001,NaviDocsEntry."Document Handling"),false);
        exit(DocManageSuccess);
    end;

    local procedure DocManagePrint(NaviDocsEntry: Record "NaviDocs Entry";RecRef: RecordRef;ReportID: Integer): Boolean
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        ErrorMessage: Text[1024];
        UseCustomReportLayout: Boolean;
    begin
        //-NPR5.29 [262219]
        RecRef.SetRecFilter;
        //+NPR5.29 [262219]
        //-NPR5.26 [248662]
        //-NPR5.31 [260773]
        //-NPR5.38 [295065]
        SetCustomReportLayout(RecRef,ReportID);
        //+NPR5.38 [295065]
        //+NPR5.31 [260773]
        ErrorMessage := PrintDoc(ReportID,false,false,RecRef);
        //-NPR5.31 [260773]
        //-NPR5.38 [295065]
        ClearCustomReportLayout;
        //+NPR5.38 [295065]
        //+NPR5.31 [260773]
        if ErrorMessage <> '' then begin
          InsertComment(NaviDocsEntry,ErrorMessage,true);
          exit(false);
        end else
          exit(true);
        //+NPR5.26 [248662]
    end;

    local procedure DocManageMail(NaviDocsEntry: Record "NaviDocs Entry";RecRef: RecordRef;ReportID: Integer): Boolean
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        EmailTemplateHeader: Record "E-mail Template Header";
        EmailDocumentManagement: Codeunit "E-mail Document Management";
        ErrorMessage: Text[1024];
        UseCustomReportLayout: Boolean;
    begin
        //-NPR5.26 [248662]
        //-NPR5.31 [260773]
        if NaviDocsEntry."E-mail (Recipient)" = '' then
          if ReportID <> 0 then
            NaviDocsEntry."E-mail (Recipient)" := EmailDocumentManagement.GetMailReceipients(RecRef,ReportID);
        //+NPR5.31 [260773]
        if NaviDocsEntry."E-mail (Recipient)" = '' then begin
          InsertComment(NaviDocsEntry,Error004,true);
          exit(false);
        end;
        //-NPR5.36 [289216]
        if NaviDocsEntry."Template Code" <> '' then
          EmailTemplateHeader.SetRange(Code,NaviDocsEntry."Template Code");
        //+NPR5.36 [289216]
        //-NPR5.26 [270787]
        //-NPR5.36 [289216]
        //IF ReportID = 0 THEN
        //  ErrorMessage := MailAndDocumentHandling.SendEmail(RecRef,NaviDocsEntry."E-mail (Recipient)",TRUE)
        if ReportID <= 0 then
          ErrorMessage := MailAndDocumentHandling.SendEmailTemplate(RecRef,EmailTemplateHeader,NaviDocsEntry."E-mail (Recipient)",true)
        //+NPR5.36 [289216]
        else begin
        //+NPR5.26 [270787]
        //-NPR5.31 [260773]
        //-NPR5.38 [295065]
          SetCustomReportLayout(RecRef,ReportID);
        //+NPR5.38 [295065]
          //-NPR5.43 [315958]
          SetReportReqParameters(NaviDocsEntry,ReportID);
          //-NPR5.43 [315958]
          ErrorMessage := MailAndDocumentHandling.SendReportTemplate(ReportID,RecRef,EmailTemplateHeader,NaviDocsEntry."E-mail (Recipient)",true);
          //-NPR5.43 [315958]
          ClearReportReqParameters(ReportID);
          //-NPR5.43 [315958]

        //-NPR5.38 [295065]
          ClearCustomReportLayout;
        //+NPR5.38 [295065]
        end;
        //+NPR5.31 [260773]
        if ErrorMessage <> '' then begin
          InsertComment(NaviDocsEntry,ErrorMessage,true);
          exit(false);
        end else
          exit(true);
        //+NPR5.26 [248662]
    end;

    local procedure DocManageElectronicDoc(NaviDocsEntry: Record "NaviDocs Entry";RecRef: RecordRef;ReportID: Integer): Boolean
    var
        Customer: Record Customer;
        CustomerDocumentSendingProfile: Record "Document Sending Profile";
        ErrorMessage: Text[1024];
    begin
        //-NPR5.26 [248662]
        if NaviDocsEntry."Type (Recipient)" <> NaviDocsEntry."Type (Recipient)"::Customer then begin
          InsertComment(NaviDocsEntry,StrSubstNo(Error015,NaviDocsEntry.FieldCaption("Type (Recipient)")),true);
          exit(false);
        end;
        if not Customer.Get(NaviDocsEntry."No. (Recipient)") then begin
          InsertComment(NaviDocsEntry,StrSubstNo(Error016,NaviDocsEntry."Type (Recipient)",NaviDocsEntry."No. (Recipient)"),true);
          exit(false);
        end;

        if not CustomerDocumentSendingProfile.Get(Customer."Document Sending Profile") then begin
          InsertComment(NaviDocsEntry,StrSubstNo(Error016,CustomerDocumentSendingProfile.TableCaption,Customer."Document Sending Profile"),true);
          exit(false);
        end;
        if not TrySendElectronicDoc(RecRef,CustomerDocumentSendingProfile) then begin
          InsertComment(NaviDocsEntry,GetLastErrorText,true);
          ClearLastError;
          exit(false);
        end;

        //+NPR5.26 [248662]
    end;

    [TryFunction]
    local procedure TrySendElectronicDoc(RecRef: RecordRef;DocumentSendingProfile: Record "Document Sending Profile")
    var
        TempDocumentSendingProfile: Record "Document Sending Profile" temporary;
        ReportDistributionManagement: Codeunit "Report Distribution Management";
        PostedDocumentVariant: Variant;
    begin
        //-NPR5.26 [248662]

        TempDocumentSendingProfile.Init;
        TempDocumentSendingProfile."Electronic Document" := TempDocumentSendingProfile."Electronic Document"::"Through Document Exchange Service";
        TempDocumentSendingProfile."Electronic Format" := DocumentSendingProfile."Electronic Format";

        PostedDocumentVariant := RecRef;
        //-NPR5.38 [295065]
        //ReportDistributionManagement.SendDocumentReport(TempDocumentSendingProfile,PostedDocumentVariant);
        ReportDistributionManagement.VANDocumentReport(PostedDocumentVariant,TempDocumentSendingProfile);
        //+NPR5.38 [295065]

        //+NPR5.26 [248662]
    end;

    local procedure PrintDoc(ReportID: Integer;ReqWindow: Boolean;SystemPrinter: Boolean;"Record": Variant): Text
    var
        ReportPrinterInterface: Codeunit "Report Printer Interface";
    begin
        //-NPR5.23 [240856]
        //ReportPrinterInterface.SetSuppressError(TRUE);
        ReportPrinterInterface.RunReport(ReportID,ReqWindow,SystemPrinter,Record);
        exit(ReportPrinterInterface.GetLastError);
        //+NPR5.23 [240856]
    end;

    local procedure GetCustomReportLayout(var CustomReportLayout: Record "Custom Report Layout";RecRef: RecordRef;ReportID: Integer): Boolean
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        //-NPR5.31 [260773]
        //-NPR5.43 [316218]
        if RecRef.Number in [18,36,112,114] then begin
        //+NPR5.43 [316218]
          CustomReportSelection.SetRange("Source Type",DATABASE::Customer);
          CustomReportSelection.SetRange("Source No.",Format(RecRef.Field(4).Value));
          CustomReportSelection.SetRange("Report ID",ReportID);
          if CustomReportSelection.FindFirst then
            if CustomReportSelection."Custom Report Layout Code" <> '' then
              exit(CustomReportLayout.Get(CustomReportSelection."Custom Report Layout Code"));
        end;
        exit(false);
        //+NPR5.31 [260773]
    end;

    local procedure "-- Handling Profile Management"()
    begin
    end;

    procedure CreateHandlingProfileLibrary()
    var
        HandlingTypePrintTxt: Label 'Print Document';
        HandlingTypeMailTxt: Label 'Send Document in E-Mail';
        HandlingTypeElecDocTxt: Label 'Send Electronic Document';
    begin
        //-NPR5.26 [248662]
        AddHandlingProfileToLibrary(HandlingTypePrintCode,HandlingTypePrintTxt,true,true,false,false);
        AddHandlingProfileToLibrary(HandlingTypeMailCode,HandlingTypeMailTxt,true,false,true,false);
        AddHandlingProfileToLibrary(HandlingTypeElecDocCode,HandlingTypeElecDocTxt,true,false,false,true);
        OnAddHandlingProfilesToLibrary;
        //+NPR5.26 [248662]
    end;

    procedure AddHandlingProfileToLibrary("Code": Code[20];Description: Text[30];ReportRequired: Boolean;DefaultForPrint: Boolean;DefaultForEmail: Boolean;DefaultForElectronicDoc: Boolean)
    var
        NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
    begin
        //-NPR5.26 [248662]
        if NaviDocsHandlingProfile.Get(Code) then
          exit;

        NaviDocsHandlingProfile.Init;
        NaviDocsHandlingProfile.Code := Code;
        NaviDocsHandlingProfile.Description := Description;
        NaviDocsHandlingProfile."Report Required" := ReportRequired;
        NaviDocsHandlingProfile."Default for Print" := DefaultForPrint;
        NaviDocsHandlingProfile."Default for E-Mail" := DefaultForEmail;
        NaviDocsHandlingProfile."Default Electronic Document" := DefaultForElectronicDoc;
        NaviDocsHandlingProfile.Insert(true);
        //+NPR5.26 [248662]
    end;

    local procedure GetMasterTableHandlingProfiles(RecRef: RecordRef;var TempHandlingProfiles: Record "NaviDocs Handling Profile" temporary)
    begin
        // Returns the handling profiles based on Document Sending Profile with recipient in Description
        //-NPR5.26 [248662]
        if not GetCustomerHandlingProfiles(RecRef,TempHandlingProfiles) then
          GetVendorHandlingProfiles(RecRef,TempHandlingProfiles);
        //+NPR5.26 [248662]
    end;

    local procedure GetCustomerHandlingProfiles(RecRef: RecordRef;var TempHandlingProfiles: Record "NaviDocs Handling Profile" temporary): Boolean
    var
        Customer: Record Customer;
        DocumentSendingProfile: Record "Document Sending Profile";
        NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
        CustomerNo: Code[20];
    begin
        //-NPR5.26 [248662]
        if not TempHandlingProfiles.IsTemporary then
          Error(DevMsgNotTemporaryErr);
        TempHandlingProfiles.DeleteAll;
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
          DATABASE::"Service Header" :
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
          NaviDocsHandlingProfile.SetRange("Default for Print",true);
          if NaviDocsHandlingProfile.FindFirst then begin
            TempHandlingProfiles := NaviDocsHandlingProfile;
            TempHandlingProfiles.Description := '';
            if TempHandlingProfiles.Insert then;
          end;
          NaviDocsHandlingProfile.SetRange("Default for Print");
        end;
        if (DocumentSendingProfile."E-Mail" <> DocumentSendingProfile."E-Mail"::No) and
            ((DocumentSendingProfile."E-Mail Attachment" = DocumentSendingProfile."E-Mail Attachment"::PDF) or
            (DocumentSendingProfile."E-Mail Attachment" = DocumentSendingProfile."E-Mail Attachment"::"PDF & Electronic Document")) then begin
          NaviDocsHandlingProfile.SetRange("Default for E-Mail",true);
          if NaviDocsHandlingProfile.FindFirst then begin
            TempHandlingProfiles := NaviDocsHandlingProfile;
            TempHandlingProfiles.Description := Customer."E-Mail";
            if TempHandlingProfiles.Insert then;
          end;
          NaviDocsHandlingProfile.SetRange("Default for E-Mail");
        end;
        if DocumentSendingProfile."Electronic Document" = DocumentSendingProfile."Electronic Document"::"Through Document Exchange Service" then begin
          NaviDocsHandlingProfile.SetRange("Default Electronic Document",true);
          if NaviDocsHandlingProfile.FindFirst then begin
            TempHandlingProfiles := NaviDocsHandlingProfile;
            TempHandlingProfiles.Description := Customer."No.";
            if TempHandlingProfiles.Insert then;
          end;
        end;
        exit(true);
        //+NPR5.26 [248662]
    end;

    local procedure GetVendorHandlingProfiles(RecRef: RecordRef;var TempHandlingProfiles: Record "NaviDocs Handling Profile" temporary): Boolean
    var
        Vendor: Record Vendor;
        DocumentSendingProfile: Record "Document Sending Profile";
        NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
        VendorNo: Code[20];
    begin
        //-NPR5.26 [248662]
        if not TempHandlingProfiles.IsTemporary then
          Error(DevMsgNotTemporaryErr);
        TempHandlingProfiles.DeleteAll;
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

        // No Document sending Profiles on Vendor - use email

        NaviDocsHandlingProfile.SetRange("Default for E-Mail",true);
        if NaviDocsHandlingProfile.FindFirst then begin
          TempHandlingProfiles := NaviDocsHandlingProfile;
          TempHandlingProfiles.Description := Vendor."E-Mail";
          if TempHandlingProfiles.Insert then;
        end;
        exit(true);
        //+NPR5.26 [248662]
    end;

    procedure "--- Aux"()
    begin
    end;

    procedure InsertComment(NaviDocsEntry: Record "NaviDocs Entry";Comment: Text;Warning: Boolean)
    begin
        //-NPR5.30 [243998]
        InsertCommentWithActivity(NaviDocsEntry,ActivityHandling,Comment,Warning);
        //+NPR5.30 [243998]
    end;

    local procedure InsertCommentWithActivity(NaviDocsEntry: Record "NaviDocs Entry";Activity: Text;Comment: Text;Warning: Boolean)
    var
        NaviDocsEntryComment: Record "NaviDocs Entry Comment";
        ActivityLog: Record "Activity Log";
        LineNo: Integer;
        ActivityLogStatus: Option Success,Failed;
    begin
        //-NPR5.30 [243998]
        NaviDocsSetup.Get;
        if not NaviDocsSetup."Log to Activity Log" then begin
        //+NPR5.30 [243998]
          /**  Get New LineNo.  **/
          NaviDocsEntryComment.LockTable;
          NaviDocsEntryComment.SetRange("Entry No.",NaviDocsEntry."Entry No.");
          if NaviDocsEntryComment.FindLast then;
          LineNo := NaviDocsEntryComment."Line No." + 10000;
        
          /**  Insert Record  **/
          NaviDocsEntryComment.Init;
          NaviDocsEntryComment."Entry No." := NaviDocsEntry."Entry No.";
          //-NPR5.26 [248662]
          //NaviDocsEntryComment.Type := NaviDocsEntry.Type;
          //+NPR5.26 [248662]
          NaviDocsEntryComment."Table No." := NaviDocsEntry."Table No.";
          NaviDocsEntryComment."Document Type" := NaviDocsEntry."Document Type";
          NaviDocsEntryComment."Document No." := NaviDocsEntry."No.";
          NaviDocsEntryComment."Line No." := LineNo;
          //-NPR5.26 [248662]
          //NaviDocsEntryComment.Description := Comment;
          NaviDocsEntryComment.Description := CopyStr(Comment,1,MaxStrLen(NaviDocsEntryComment.Description));
          //+NPR5.26 [248662]
          NaviDocsEntryComment.Warning := Warning;
          if NaviDocsEntryComment.Insert(true) then;
        //-NPR5.30 [243998]
        end else begin
          if Warning then
            ActivityLogStatus := ActivityLogStatus::Failed;
          if Activity = ActivityHandling then begin
            ActivityLog.LogActivity(NaviDocsEntry.RecordId,ActivityLogStatus,ActivityContentText,CopyStr(NaviDocsEntry."Document Handling",1,250),CopyStr(Comment,1,250));
            ActivityLog.LogActivity(NaviDocsEntry."Record ID",ActivityLogStatus,ActivityContentText,CopyStr(NaviDocsEntry."Document Handling",1,250),CopyStr(Comment,1,250));
          end else
            ActivityLog.LogActivity(NaviDocsEntry.RecordId,ActivityLogStatus,ActivityContentText,CopyStr(Activity,1,250),CopyStr(Comment,1,250));
        end;
        //+NPR5.30 [243998]

    end;

    procedure UpdateStatus(NaviDocsEntry: Record "NaviDocs Entry";Status: Integer): Boolean
    var
        Error002: Label 'Error on Manual Status Update: %1 is invalid';
        Txt001: Label 'Status Manually Updated to: %1';
        Txt011: Label 'Unhandled';
        Txt021: Label 'Error';
        Txt031: Label 'Handled';
        Comment: Text[250];
    begin
        if (Status < 0) or (Status > 2) then begin
          InsertComment(NaviDocsEntry,Error002,true);
          exit(false);
        end;

        if NaviDocsEntry.Find then begin
          NaviDocsEntry.Status := Status;
          NaviDocsEntry."Processed Qty." := 0;
          NaviDocsEntry.Modify(true);

          case Status of
            NaviDocsStatusUnhandled : Comment := StrSubstNo(Txt001,Txt011);
            NaviDocsStatusError : Comment := StrSubstNo(Txt001,Txt021);
            NaviDocsStatusHandled : Comment := StrSubstNo(Txt001,Txt031);
          end;
        //-NPR5.30 [243998]
        //  InsertComment(NaviDocsEntry,Comment,FALSE);
          InsertCommentWithActivity(NaviDocsEntry,ActivityStatusChange,Comment,false);
        //+NPR5.30 [243998]
        end;

        exit(true);
    end;

    procedure UpdateStatusComment(NaviDocsEntry: Record "NaviDocs Entry";Status: Integer;Comment: Text[250]): Boolean
    var
        Error002: Label 'Error on Manual Status Update: %1 is invalid';
    begin
        if (Status < 0) or (Status > 2) then begin
          InsertComment(NaviDocsEntry,Error002,true);
          exit(false);
        end;

        NaviDocsSetup.Get;

        if NaviDocsEntry.Find then begin
          NaviDocsEntry.Status := Status;
          NaviDocsEntry."Processed Qty." := NaviDocsSetup."Max Retry Qty";
          NaviDocsEntry.Modify(true);
        //-NPR5.30 [243998]
        //  InsertComment(NaviDocsEntry,Comment,FALSE);
          InsertCommentWithActivity(NaviDocsEntry,ActivityStatusChange,Comment,false);
        //+NPR5.30 [243998]
        end;

        exit(true);
    end;

    procedure CheckAndUpdateStatus(var NaviDocsEntry: Record "NaviDocs Entry") Updated: Boolean
    var
        Txt001: Label 'Document Handled but not from NaviDocs.';
    begin
        if NaviDocsEntry.Status = 2 then
          exit(false);

        SetHandled(NaviDocsEntry,true);
        if (NaviDocsEntry."Printed Qty." > 0) or NaviDocsEntry."OIO Sent" or (NaviDocsEntry."E-mail Qty." > 0) then begin
          NaviDocsEntry.Status := 2;
          NaviDocsEntry.Modify(true);
          InsertComment(NaviDocsEntry,Txt001,false);
          exit(true);
        end;

        exit(false);
    end;

    procedure SetHandlingProfile(var NaviDocsEntry: Record "NaviDocs Entry";NewHandlingProfile: Record "NaviDocs Handling Profile"): Boolean
    begin
        //-NPR5.40 [306875]
        if NaviDocsEntry."Document Handling Profile" <> NewHandlingProfile.Code then begin
          NaviDocsEntry.Validate("Document Handling Profile",NewHandlingProfile.Code);
          NaviDocsEntry.Modify(true);
          InsertComment(NaviDocsEntry,StrSubstNo(EntryChangedTxt,NaviDocsEntry.FieldCaption("Document Handling Profile"),NewHandlingProfile.Description),false);
          exit(true);
        end;
        exit(false);
        //+NPR5.40 [306875]
    end;

    procedure SetHandled(var NaviDocsEntry: Record "NaviDocs Entry";ModifyRecord: Boolean)
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
          DATABASE::"Sales Header" :
            if SalesHeader.Get(NaviDocsEntry."Document Type", NaviDocsEntry."No.") then begin
              RecRef.GetTable(SalesHeader);
              NaviDocsEntry."Printed Qty." := SalesHeader."No. Printed";
            end;
          DATABASE::"Sales Invoice Header" :
            if SalesInvoiceHeader.Get(NaviDocsEntry."No.") then begin
              RecRef.GetTable(SalesInvoiceHeader);
              NaviDocsEntry."Printed Qty." := SalesInvoiceHeader."No. Printed";
              //-NPR4.12
              //NaviDocsEntry."OIO Sent" := SalesInvoiceHeader."Electronic Invoice Created";
              NPRDocumentLocalization.T112_GetFieldValue (SalesInvoiceHeader, 'Electronic Invoice Created', VariantVar);
        //-NPR5.23 [246043]
        //      EVALUATE (IsDocumentCreated, VariantVar);
        //      NaviDocsEntry."OIO Sent" := IsDocumentCreated;
              if VariantVar.IsBoolean then
                NaviDocsEntry."OIO Sent" := VariantVar;
        //+NPR5.23 [236043]
              //+NPR4.12
            end;
          DATABASE::"Sales Cr.Memo Header":
            if SalesCrMemoHeader.Get(NaviDocsEntry."No.") then begin
              RecRef.GetTable(SalesCrMemoHeader);
              NaviDocsEntry."Printed Qty." := SalesCrMemoHeader."No. Printed";
              //-NPR4.12
              //NaviDocsEntry."OIO Sent" := SalesCrMemoHeader."Electronic Credit Memo Created";
              NPRDocumentLocalization.T114_GetFieldValue (SalesCrMemoHeader, 'Electronic Credit Memo Created', VariantVar);
        //-NPR5.23 [236043
        //      EVALUATE (IsDocumentCreated, VariantVar);
        //      NaviDocsEntry."OIO Sent" := IsDocumentCreated;
              if VariantVar.IsBoolean then
                NaviDocsEntry."OIO Sent" := VariantVar;
        //+NPR5.23 [236043
              //+NPR4.12
            end;
          DATABASE::"Issued Reminder Header":
            if IssuedReminderHeader.Get(NaviDocsEntry."No.") then begin
              RecRef.GetTable(IssuedReminderHeader);
              NaviDocsEntry."Printed Qty." := IssuedReminderHeader."No. Printed";
              //-NPR4.12
              // NaviDocsEntry."OIO Sent" := IssuedReminderHeader."Electronic Reminder Created";
              NPRDocumentLocalization.T297_GetFieldValue (IssuedReminderHeader, 'Electronic Reminder Created', VariantVar);
        //-NPR5.23 [236043
        //      EVALUATE (IsDocumentCreated, VariantVar);
        //      NaviDocsEntry."OIO Sent" := IsDocumentCreated;
              if VariantVar.IsBoolean then
                NaviDocsEntry."OIO Sent" := VariantVar;
        //+NPR5.23 [236043
              //+NPR4.12
              NaviDocsEntry."E-mail Qty." := MailAndDocLogCount(NaviDocsEntry);
            end;
          DATABASE::"Issued Fin. Charge Memo Header":
            if IssuedFinChargeMemoHeader.Get(NaviDocsEntry."No.") then begin
              RecRef.GetTable(IssuedFinChargeMemoHeader);
              NaviDocsEntry."Printed Qty." := IssuedFinChargeMemoHeader."No. Printed";
              //-NPR4.12
              //NaviDocsEntry."OIO Sent" := IssuedFinChargeMemoHeader."Elec. Fin. Charge Memo Created";
              NPRDocumentLocalization.T304_GetFieldValue (IssuedFinChargeMemoHeader, 'Elec. Fin. Charge Memo Created', VariantVar);
        //-NPR5.23 [236043
        //      EVALUATE (IsDocumentCreated, VariantVar);
        //      NaviDocsEntry."OIO Sent" := IsDocumentCreated;
              if VariantVar.IsBoolean then
                NaviDocsEntry."OIO Sent" := VariantVar;
        //+NPR5.23 [236043
              //+NPR4.12
            end;
        end;
        NaviDocsEntry."E-mail Qty." := MailAndDocLogCount(NaviDocsEntry);

        if ModifyRecord then
          NaviDocsEntry.Modify(true);
    end;

    procedure ConvertLog()
    var
        NaviDocsEntry: Record "NaviDocs Entry";
        NaviDocsEntryComment: Record "NaviDocs Entry Comment";
        ActivityLog: Record "Activity Log";
        ConvertOldLogEntryText: Label 'Convert existing Log entries to Activity Log?';
        ConvertCompleteText: Label 'Convertion complete.';
    begin
        //+NPR5.30 [243998]
        if not Confirm(ConvertOldLogEntryText) then
          exit;
        if NaviDocsEntry.FindSet then
          repeat
            NaviDocsEntryComment.SetRange("Table No.",NaviDocsEntry."Table No.");
            NaviDocsEntryComment.SetRange("Document Type",NaviDocsEntry."Document Type");
            NaviDocsEntryComment.SetRange("Document No.",NaviDocsEntry."No.");
            if NaviDocsEntryComment.FindSet then
              repeat
                ActivityLog.Init;
                ActivityLog.ID := 0;
                ActivityLog."Record ID" := NaviDocsEntry.RecordId;
                ActivityLog."Activity Date" := CreateDateTime(NaviDocsEntryComment."Insert Date",NaviDocsEntryComment."Insert Time");
                ActivityLog."User ID" := NaviDocsEntryComment."User ID";
                if NaviDocsEntryComment.Warning then
                  ActivityLog.Status := ActivityLog.Status::Failed
                else
                  ActivityLog.Status := ActivityLog.Status::Success;
                ActivityLog.Context := ActivityContentText;
                ActivityLog.Description := 'Converted';
                ActivityLog."Activity Message" := NaviDocsEntryComment.Description;
                ActivityLog.Insert(true);
              until NaviDocsEntryComment.Next = 0;
          until NaviDocsEntry.Next = 0;
        Message(ConvertCompleteText);
        //+NPR5.30 [243998]
    end;

    local procedure SetCustomReportLayout(RecRef: RecordRef;ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
        CustomReportLayoutVariant: Variant;
    begin
        //-NPR5.38 [295065]
        //-NPR5.43 [316218]
        if RecRef.Number in [18,36,112,114] then begin
        //+NPR5.43 [316218]
          CustomReportSelection.SetRange("Source Type",DATABASE::Customer);
        //-NPR5.43 [316218]
          if RecRef.Number = 18 then
            CustomReportSelection.SetRange("Source No.",Format(RecRef.Field(1).Value))
          else
        //+NPR5.43 [316218]
            CustomReportSelection.SetRange("Source No.",Format(RecRef.Field(4).Value));
          CustomReportSelection.SetRange("Report ID",ReportID);
          if CustomReportSelection.FindFirst then begin
            EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection,CustomReportLayoutVariant);
            if CustomReportLayout.Get(CustomReportLayoutVariant) then
              ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutVariant);
          end;
        end;
        //+NPR5.38 [295065]
    end;

    local procedure ClearCustomReportLayout()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
        BlankVariant: Variant;
    begin
        //-NPR5.38 [295065]
        EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection,BlankVariant);
        ReportLayoutSelection.SetTempLayoutSelected(BlankVariant);
        //+NPR5.38 [295065]
    end;

    local procedure SetReportReqParameters(NaviDocsEntry: Record "NaviDocs Entry";ReportID: Integer)
    var
        NaviDocsEntryAttachment: Record "NaviDocs Entry Attachment";
        InStr: InStream;
        Parameters: Text;
    begin
        //-NPR5.43 [315958]
        NaviDocsEntryAttachment.SetRange("NaviDocs Entry No.",NaviDocsEntry."Entry No.");
        NaviDocsEntryAttachment.SetRange("Internal Type",NaviDocsEntryAttachment."Internal Type"::"Report Parameters");
        if NaviDocsEntryAttachment.FindSet then
          repeat
            NaviDocsEntryAttachment.CalcFields(Data);
            NaviDocsEntryAttachment.Data.CreateInStream(InStr);
            InStr.ReadText(Parameters);
            MailAndDocumentHandling.StoreRequestParameters(ReportID,Parameters);
          until NaviDocsEntryAttachment.Next = 0;
        //+NPR5.43 [315958]
    end;

    local procedure ClearReportReqParameters(ReportID: Integer)
    begin
        //-NPR5.43 [315958]
        MailAndDocumentHandling.ClearRequestParameters(ReportID);
        //+NPR5.43 [315958]
    end;

    procedure "--- UI"()
    begin
    end;

    procedure PageAccountCard(NaviDocsEntry: Record "NaviDocs Entry")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        case NaviDocsEntry."Type (Recipient)" of
          NaviDocsEntry."Type (Recipient)"::Customer :
            begin
              Customer.Get(NaviDocsEntry."No. (Recipient)");
              PAGE.RunModal(PAGE::"Customer Card",Customer);
            end;
          NaviDocsEntry."Type (Recipient)"::Vendor :
            begin
              Vendor.Get(NaviDocsEntry."No. (Recipient)");
              PAGE.RunModal(PAGE::"Vendor Card",Vendor);
            end;
          //-NPR5.28 [254575]
          NaviDocsEntry."Type (Recipient)"::Contact :
            begin
              Contact.Get(NaviDocsEntry."No. (Recipient)");
              PAGE.RunModal(PAGE::"Contact Card", Contact);
            end;
          //+NPR5.28 [254575]
        end;
    end;

    procedure PageDocumentCard(NaviDocsEntry: Record "NaviDocs Entry")
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchHeader: Record "Purchase Header";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        RecRef: RecordRef;
        RecVariant: Variant;
        PageManagement: Codeunit "Page Management";
    begin
        //-NPR5.26 [248662]
        RecRef.Get(NaviDocsEntry."Record ID");
        RecVariant := RecRef;
        PageManagement.PageRun(RecVariant);
        //+NPR5.26 [248662]
    end;

    procedure PageMailAndDocCard(NaviDocsEntry: Record "NaviDocs Entry")
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        MailAndDocumentHeader: Record "E-mail Template Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EmailManagement: Codeunit "E-mail Management";
        RecRef: RecordRef;
        Handled: Boolean;
    begin
        //-NPR5.26 [248662]
        OnShowTemplate(Handled,NaviDocsEntry);
        if Handled then
          exit;
        //+NPR5.26 [248662]
        //-NPR5.36 [289216]
        if NaviDocsEntry."Template Code" <> '' then
          MailAndDocumentHeader.SetRange(Code,NaviDocsEntry."Template Code")
        else begin
        //+NPR5.36 [289216]
          Clear(MailAndDocumentHeader);
          MailAndDocumentHeader.SetRange("Table No.", NaviDocsEntry."Table No.");
          MailAndDocumentHeader.SetRange("Report ID", NaviDocsEntry."Report No.");
        //-NPR5.36 [289216]
          MailAndDocumentHeader.SetFilter(Group,'%1',EmailManagement.GetDefaultGroupFilter);
        //+NPR5.36 [289216]
          if not MailAndDocumentHeader.FindFirst then
            MailAndDocumentHeader.SetRange("Report ID");
        end;
        PAGE.RunModal(PAGE::"E-mail Template",MailAndDocumentHeader);
    end;

    procedure PageMailAndDocLog(NaviDocsEntry: Record "NaviDocs Entry")
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        MailAndDocumentHeader: Record "E-mail Template Header";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
        PurchHeader: Record "Purchase Header";
        PurchReceiptHeader: Record "Purch. Rcpt. Header";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        //-NPR71.00.00.01
        //MailAndDocumentHandling.RunMailLogPage(NaviDocsEntry);
        //+NPR71.00.00.01
    end;

    procedure MailAndDocLogCount(NaviDocsEntry: Record "NaviDocs Entry"): Integer
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        MailAndDocumentLog: Record "E-mail Log";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
    begin
        //-NPR71.00.00.01
        //CLEAR(MailAndDocumentLog);
        //MailAndDocumentLog.SETCURRENTKEY("NaviDocs Entry No.");
        //MailAndDocumentLog.SETRANGE("NaviDocs Entry No.", NaviDocsEntry."Entry No.");
        //EXIT(MailAndDocumentLog.COUNT);
        //+NPR71.00.00.01
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddDocumentEntry(var IsInsertHandled: Boolean;var RecRef: RecordRef;var HandlingProfile: Code[20];var ReportNo: Integer;var Recipient: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddDocumentEntryExt(var InsertedEntryNo: BigInteger;var RecRef: RecordRef;var HandlingProfile: Code[20];var ReportNo: Integer;var Recipient: Text;var TemplateCode: Code[20];var DelayUntil: DateTime)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAddHandlingProfilesToLibrary()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnManageDocument(var IsDocumentHandled: Boolean;ProfileCode: Code[20];var NaviDocsEntry: Record "NaviDocs Entry";ReportID: Integer;var WithSuccess: Boolean;var ErrorMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowTemplate(var RequestHandled: Boolean;NaviDocsEntry: Record "NaviDocs Entry")
    begin
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014464, 'OnBeforeSendReport', '', true, true)]
    local procedure EMailDocMgtSendReportEvent(RecVariant: Variant;Silent: Boolean;var OverruleMail: Boolean)
    var
        NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
        TestNumber: Record "Integer";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        EmailDocumentManagement: Codeunit "E-mail Document Management";
        EMailMgt: Codeunit "E-mail Management";
        ReportID: Integer;
        Recipient: Text;
    begin
        //-NPR5.26 [248662]
        //-NPR5.28 [254575]
        // IF ReportSent THEN
        //  EXIT;
        //+NPR5.28 [254575]
        //-NPR5.27 [254280]
        //NaviDocsSetup.GET;
        if not NaviDocsSetup.Get then
          exit;
        //-NPR5.27 [254280]
        if not (NaviDocsSetup."Enable NaviDocs" and NaviDocsSetup."Pdf2Nav Send pdf") then
          exit;
        if not DataTypeManagement.GetRecordRef(RecVariant,RecRef) then
          exit;
        if NaviDocsSetup."Pdf2Nav Table Filter" <> '' then begin
          TestNumber.FilterGroup(55);
          TestNumber.SetFilter(Number,NaviDocsSetup."Pdf2Nav Table Filter");
          TestNumber.FilterGroup(0);
          TestNumber.SetRange(Number,RecRef.Number);
          if not TestNumber.FindFirst then
            exit;
        end;
        //-NPR5.28 [254575]

        //-NPR5.31 [260773]
        //AddDocumentEntryWithHandlingProfile (RecRef, HandlingTypeMailCode(), 0, EmailManagement.GetEmailAddressFromRecRef(RecRef), 0DT);
        NaviDocsHandlingProfile.Get(HandlingTypeMailCode);
        if NaviDocsHandlingProfile."Report Required" then
          ReportID := EMailMgt.GetReportIDFromRecRef(RecRef);
        Recipient := EMailMgt.GetCustomReportEmailAddress();
        if Recipient = '' then
          Recipient := EmailDocumentManagement.GetMailReceipients(RecRef,ReportID);
        AddDocumentEntryWithHandlingProfile (RecRef, HandlingTypeMailCode(), ReportID, Recipient, 0DT);
        //+NPR5.31 [260773]

        OverruleMail := true;
        //AddDocumentEntry(RecRef,0);
        //ReportSent := TRUE;
        //+NPR5.28 [254575]

        //+NPR5.26 [248662]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnBeforeAddDocumentEntryExt', '', true, true)]
    local procedure OnBeforeAddAuditRollDocumentEntry(var InsertedEntryNo: BigInteger;var RecRef: RecordRef;var HandlingProfile: Code[20];var ReportNo: Integer;var Recipient: Text;var TemplateCode: Code[20];var DelayUntil: DateTime)
    var
        AuditRoll: Record "Audit Roll";
        NaviDocsEntry: Record "NaviDocs Entry";
        TableMetadata: Record "Table Metadata";
    begin
        //-NPR5.28 [254575]
        //-NPR5.43 [315958]
        //IF IsInsertHandled THEN
        //  EXIT;
        if InsertedEntryNo <> 0 then
          exit;
        //+NPR5.43 [315958]

        if RecRef.Number <> DATABASE::"Audit Roll" then
          exit;

        if not AuditRoll.Get (RecRef.RecordId) then
          exit;

        NaviDocsEntry.Init;
        NaviDocsEntry."Entry No." := 0;
        NaviDocsEntry.Validate ("Record ID",RecRef.RecordId);
        NaviDocsEntry.Validate ("Table No.",RecRef.Number);
        NaviDocsEntry."Document Description" := AuditRoll.TableCaption;
        NaviDocsEntry."No." := AuditRoll."Sales Ticket No.";
        NaviDocsEntry."Posting Date" := AuditRoll."Posting Date";

        if StrLen(AuditRoll."Customer No.") > 0 then begin
          NaviDocsEntry."No. (Recipient)" := AuditRoll."Customer No.";
          case AuditRoll."Customer Type" of
            AuditRoll."Customer Type"::"Ord." :
              NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
            AuditRoll."Customer Type"::Cash :
              NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Contact;
          end;
        end;

        NaviDocsEntry.Validate ("Document Handling Profile",HandlingProfile);
        NaviDocsEntry."E-mail (Recipient)" := Recipient;
        NaviDocsEntry."Report No." := ReportNo;
        NaviDocsEntry."Posting Date" := AuditRoll."Sale Date";
        //-NPR5.42 [308861]
        NaviDocsEntry."Delay sending until" := DelayUntil;
        NaviDocsEntry."Template Code" := TemplateCode;
        //+NPR5.42 [308861]

        //-NPR5.43 [315958]
        //IsInsertHandled := NaviDocsEntry.INSERT (TRUE);
        NaviDocsEntry.Insert (true);
        InsertedEntryNo := NaviDocsEntry."Entry No.";
        //-NPR5.43 [315958]
        //+NPR5.28 [254575]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnBeforeAddDocumentEntryExt', '', true, true)]
    local procedure OnBeforeAddPOSEntryDocumentEntry(var InsertedEntryNo: BigInteger;var RecRef: RecordRef;var HandlingProfile: Code[20];var ReportNo: Integer;var Recipient: Text;var TemplateCode: Code[20];var DelayUntil: DateTime)
    var
        POSEntry: Record "POS Entry";
        NaviDocsEntry: Record "NaviDocs Entry";
        Customer: Record Customer;
        Contact: Record Contact;
        EmailMgt: Codeunit "E-mail Management";
        RecipientRecRef: RecordRef;
    begin
        //-NPR5.40 [305875]
        //-NPR5.43 [315958]
        //IF IsInsertHandled THEN
        //  EXIT;
        if InsertedEntryNo <> 0 then
          exit;
        //+NPR5.43 [315958]

        if RecRef.Number <> DATABASE::"POS Entry" then
          exit;

        if not POSEntry.Get (RecRef.RecordId) then
          exit;

        NaviDocsEntry.Init;
        NaviDocsEntry."Entry No." := 0;
        NaviDocsEntry.Validate ("Record ID",RecRef.RecordId);
        NaviDocsEntry.Validate ("Table No.",RecRef.Number);
        NaviDocsEntry."Document Description" := POSEntry.TableCaption;
        NaviDocsEntry."No." := POSEntry."Document No.";
        NaviDocsEntry."Posting Date" := POSEntry."Entry Date";

        case true of
          POSEntry."Customer No." <> '' :
            begin
              NaviDocsEntry."No. (Recipient)" := POSEntry."Customer No.";
              NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Customer;
              if (Recipient = '') and (HandlingProfile = HandlingTypeMailCode) then
                if Customer.Get(NaviDocsEntry."No. (Recipient)") then begin
                  RecipientRecRef.GetTable(Customer);
                  Recipient := EmailMgt.GetEmailAddressFromRecRef(RecipientRecRef);
                end;
            end;
          POSEntry."Contact No." <> '' :
            begin
              NaviDocsEntry."No. (Recipient)" := POSEntry."Contact No.";
              NaviDocsEntry."Type (Recipient)" := NaviDocsEntry."Type (Recipient)"::Contact;
              if (Recipient = '') and (HandlingProfile = HandlingTypeMailCode) then
                if Contact.Get(NaviDocsEntry."No. (Recipient)") then begin
                  RecipientRecRef.GetTable(Contact);
                  Recipient := EmailMgt.GetEmailAddressFromRecRef(RecipientRecRef);
                end;
            end;
        end;

        NaviDocsEntry.Validate ("Document Handling Profile",HandlingProfile);
        NaviDocsEntry."E-mail (Recipient)" := Recipient;
        NaviDocsEntry."Report No." := ReportNo;
        //-NPR5.42 [308861]
        NaviDocsEntry."Delay sending until" := DelayUntil;
        NaviDocsEntry."Template Code" := TemplateCode;
        //+NPR5.42 [308861]

        //-NPR5.43 [315958]
        //IsInsertHandled := NaviDocsEntry.INSERT (TRUE);
        NaviDocsEntry.Insert (true);
        InsertedEntryNo := NaviDocsEntry."Entry No.";
        //-NPR5.43 [315958]
        //+NPR5.40 [305875]
    end;

    procedure "--- ErrorHandling"()
    begin
    end;

    [TryFunction]
    procedure TrySendWarningMail(NaviDocsEntry: Record "NaviDocs Entry")
    var
        IComm: Record "I-Comm";
        NaviDocsEntryComment: Record "NaviDocs Entry Comment";
        EmailSetup: Record "E-mail Setup";
        StringLibrary: Codeunit "String Library";
        Txt001: Label 'NaviDocs Error %1 - %2 %3';
        Mail: DotNet npNetSmtpMessage;
        i: Integer;
    begin
        NaviDocsSetup.Get;
        if not NaviDocsSetup."Send Warming E-mail" then
          exit;
        //-NPR5.26 [248662]
        EmailSetup.Get;
        if EmailSetup."Mail Server" = '' then
          exit;
        if EmailSetup."Mail Server Port" <= 0 then
          EmailSetup."Mail Server Port" := 25;
        //+NPR5.26 [248662]


        //-NPR71.00.00.01
        //MailAndDocumentHandling.AddEmailAttachmentsToSmtpMessage(Mailserver, ServerPort, Authentication, UserName, Password, EnableSSL);
        //+NPR71.00.00.01

        if not IsNull(Mail) then
          Mail.Dispose;
        Clear(Mail);
        Mail := Mail.SmtpMessage;
        Mail.HtmlFormatted := true;

        Mail.FromAddress := NaviDocsSetup."Warning E-mail";
        StringLibrary.Construct(NaviDocsSetup."Warning E-mail");
        StringLibrary.Replace(',',';');
        for i := 1 to StringLibrary.CountOccurences(';') + 1 do
          Mail.AddRecipients(StringLibrary.SelectStringSep(i,';'));
        //-NPR5.26 [248662]
        //Mail.Subject := STRSUBSTNO(Txt001,FORMAT(NaviDocsEntry.Type),NaviDocsEntry."Document Description",NaviDocsEntry."No.");
        //NaviDocsEntryComment.SETRANGE("Entry No.",NaviDocsEntry.Type);
        Mail.Subject := StrSubstNo(Txt001,NaviDocsEntry."Document Description",NaviDocsEntry."No.");
        NaviDocsEntryComment.SetRange("Entry No.",NaviDocsEntry."Entry No.");
        //+NPR5.26 [248662]
        NaviDocsEntryComment.SetRange("Table No.",NaviDocsEntry."Table No.");
        NaviDocsEntryComment.SetRange("Document Type",NaviDocsEntry."Document Type");
        NaviDocsEntryComment.SetRange("Document No.",NaviDocsEntry."No.");
        if NaviDocsEntryComment.FindLast then
          Mail.AppendBody(NaviDocsEntryComment.Description + '<br><br>');
        //-NPR5.26 [248662]
        //IF Mail.Send(Mailserver, ServerPort, Authentication, UserName, Password, EnableSSL) = '' THEN ;
        if Mail.Send(EmailSetup."Mail Server",EmailSetup."Mail Server Port",EmailSetup.Username <> '',
                     EmailSetup.Username,EmailSetup.Password,EmailSetup."Enable Ssl") = '' then;
        //+NPR5.26 [248662]

        Mail.Dispose;
        Clear(Mail);
    end;

    procedure "--- Enum"()
    begin
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
        //-NPR5.26 [248662]
        exit('PRINT');
        //+NPR5.26 [248662]
    end;

    procedure HandlingTypeMailCode(): Code[20]
    begin
        //-NPR5.26 [248662]
        exit('E-MAIL');
        //+NPR5.26 [248662]
    end;

    procedure HandlingTypeElecDocCode(): Code[20]
    begin
        //-NPR5.26 [248662]
        exit('ELECTRONIC DOC');
        //+NPR5.26 [248662]
    end;
}

