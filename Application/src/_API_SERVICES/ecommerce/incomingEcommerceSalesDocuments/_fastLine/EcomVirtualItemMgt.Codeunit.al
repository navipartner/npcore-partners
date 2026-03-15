#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248551 "NPR Ecom Virtual Item Mgt"
{
    Access = Internal;

    local procedure ProcessVirtualItemLine(var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UnsupportedSubtypeLbl: Label 'Subtype %1 in %2 is not supported.', Comment = '%1 - ecom sales line subtype, %2 - record id';
    begin
        case EcomSalesLine.Subtype of
            EcomSalesLine.Subtype::Voucher:
                CreateVoucher(EcomSalesLine, true, false);
            EcomSalesLine.Subtype::Ticket:
                begin
                    EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
                    CreateTickets(EcomSalesHeader, true, false);
                end;
            else
                Error(UnsupportedSubtypeLbl, EcomSalesLine.Subtype, EcomSalesLine.RecordId);
        end;
    end;

    internal procedure ProcessVirtualItemLineWithConfirmation(var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmVirtualItemLbl: Label 'Are you sure you want to process the virtual item?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmVirtualItemLbl, true) then
            exit;

        ProcessVirtualItemLine(EcomSalesLine);
    end;

    internal procedure CreateVouchers(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        if not EcomSalesHeader."Vouchers Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        if (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::"Partially Processed") and
            (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::Processed) then
            exit;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Voucher);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
        EcomSalesLine.SetRange(Captured, true);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetFilter("Unit Price", '<>0');
        if EcomSalesLine.FindSet() then
            repeat
                CreateVoucher(EcomSalesLine, ShowError, UpdateRetryCount);
            until EcomSalesLine.Next() = 0;

        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    internal procedure CaptureEcomDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSaleDocCaptureProcess: Codeunit "NPR EcomSaleDocCaptureProcess";
    begin
        if not EcomSalesHeader."Virtual Items Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        Clear(EcomSaleDocCaptureProcess);
        EcomSaleDocCaptureProcess.SetShowError(ShowError);
        EcomSaleDocCaptureProcess.SetUpdateRetryCount(UpdateRetryCount);
        EcomSaleDocCaptureProcess.Run(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    local procedure CreateVoucher(var EcomSalesLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean) Success: Boolean
    var
        EcomCreateVchrProcess: Codeunit "NPR EcomCreateVchrProcess";
    begin
        Clear(EcomCreateVchrProcess);
        EcomCreateVchrProcess.SetShowError(ShowError);
        EcomCreateVchrProcess.SetUpdateRetryCount(UpdateRetryCount);
        Success := EcomCreateVchrProcess.Run(EcomSalesLine);
    end;

    internal procedure CreateTickets(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomCreateTicketProcess: Codeunit "NPR EcomCreateTicketProcess";
        Success: Boolean;
    begin
        if not EcomSalesHeader."Tickets Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        if (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::"Partially Processed") and
            (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::Processed) then
            exit;

        if not AllTicketLinesCapturedAndUnprocessed(EcomSalesHeader, ShowError) then
            exit;

        Clear(EcomCreateTicketProcess);
        EcomCreateTicketProcess.SetShowError(ShowError);
        EcomCreateTicketProcess.SetUpdateRetryCount(UpdateRetryCount);
        Success := EcomCreateTicketProcess.Run(EcomSalesHeader);

        if not Success and ShowError then
            Error(GetLastErrorText());

        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    local procedure AllTicketLinesCapturedAndUnprocessed(EcomSalesHeader: Record "NPR Ecom Sales Header"; RunPageAction: Boolean): Boolean
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetFilter("Unit Price", '<>0');

        if EcomSalesLine.IsEmpty() then
            exit(false);

        EcomSalesLine.SetRange(Captured, false);
        if not EcomSalesLine.IsEmpty() then
            exit(false);

        EcomSalesLine.SetRange(Captured);
        if RunPageAction then begin
            EcomSalesLine.SetFilter("Virtual Item Process Status", '<>%1&<>%2', EcomSalesLine."Virtual Item Process Status"::" ", EcomSalesLine."Virtual Item Process Status"::Error);
            if not EcomSalesLine.IsEmpty() then
                exit(false);
        end else begin
            EcomSalesLine.SetFilter("Virtual Item Process Status", '<>%1', EcomSalesLine."Virtual Item Process Status"::" ");
            if not EcomSalesLine.IsEmpty() then
                exit(false);
        end;
        exit(true);
    end;

    internal procedure AssignBucketLines(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        BucketInt: Integer;
    begin
        BucketInt := Random(100);

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Subtype, '%1|%2', EcomSalesLine.Subtype::Ticket, EcomSalesLine.Subtype::Voucher);
        EcomSalesLine.ModifyAll("Bucket Id", BucketInt);

        exit(BucketInt);
    end;

    internal procedure GetRetryCaptureCountFilter(): Integer
    var
        EcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not EcomSalesDocSetup.Get() then
            EcomSalesDocSetup.Init();
        exit(EcomSalesDocSetup."Max Capture Retry Count");
    end;

    internal procedure UpdateVirtualItemInformationInHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");

        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Voucher);
        EcomSalesHeader."Vouchers Exist" := not EcomSalesLine.IsEmpty;

        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesHeader."Tickets Exist" := not EcomSalesLine.IsEmpty;
        EcomSalesLine.SetRange(Subtype);

        EcomSalesHeader."Virtual Items Exist" := EcomSalesHeader."Vouchers Exist" or EcomSalesHeader."Tickets Exist";
        EcomVirtualItemEvents.OnUpdateVirtualInformationInHeaderBeforeModify(EcomSalesHeader);
        EcomSalesHeader.Modify();
    end;

    internal procedure OpenEcomVoucherLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomVirtualItemLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Subtype, '%1|%2', EcomSalesLine.Subtype::Ticket, EcomSalesLine.Subtype::Voucher);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomTicketLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Item);
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomCapturedLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Captured, true);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure GetVoucherProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Voucher Processing Status" of
            EcomSalesHeader."Voucher Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Voucher Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetTicketProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Ticket Processing Status" of
            EcomSalesHeader."Ticket Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Ticket Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetVirtualItemProcessingStatusStyle(EcomSalesLine: Record "NPR Ecom Sales Line") StyleText: Text
    begin
        case EcomSalesLine."Virtual Item Process Status" of
            EcomSalesLine."Virtual Item Process Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesLine."Virtual Item Process Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetVirtualItemErrorTextStyle(EcomSalesLine: Record "NPR Ecom Sales Line") StyleText: Text
    begin
        case EcomSalesLine."Virtual Item Process Status" of
            EcomSalesLine."Virtual Item Process Status"::Error:
                StyleText := 'Unfavorable';
        end;
    end;

    internal procedure GetCaptureProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Capture Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetCaptureErrorStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Error:
                StyleText := 'Unfavorable';
        end;
    end;

    internal procedure GetVirtualItemProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Virtual Items Process Status" of
            EcomSalesHeader."Virtual Items Process Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Virtual Items Process Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure FindVoucher(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var Voucher: Record "NPR NpRv Voucher")
    var
        GlobalVoucherWS: Codeunit "NPR NpRv Global Voucher WS";
    begin
        if not GlobalVoucherWS.FindVoucher('', CopyStr(EcomSalesPmtLine."Payment Reference", 1, 50), Voucher) then
            CheckIfVoucherHasBeenArchived(EcomSalesPmtLine)
        else
            ValidateActiveVoucher(Voucher)
    end;

    local procedure CheckIfVoucherHasBeenArchived(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        ArchivedVoucher: Record "NPR NpRv Arch. Voucher";
        InvalidReferenceErrorLbl: Label 'Invalid voucher reference no. %1.', Comment = '%1 - reference no';
        VoucherArchivedErrorLbl: Label 'Voucher with type %1 and reference no. %2 has been archived.', Comment = '%1 - voucher type, %2 - reference no.';
    begin
        ArchivedVoucher.Reset();
        ArchivedVoucher.SetRange("Reference No.", EcomSalesPmtLine."Payment Reference");
        if not ArchivedVoucher.FindFirst() then
            Error(InvalidReferenceErrorLbl, EcomSalesPmtLine."Payment Reference");

        Error(VoucherArchivedErrorLbl, ArchivedVoucher."Voucher Type", EcomSalesPmtLine."Payment Reference");
    end;

    local procedure ValidateActiveVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        VoucherFullyUsedErrorLbl: Label 'Voucher with type %1 and reference no. %2 is fully used.', Comment = '%1 - voucher type, %2 - reference no.';
        NotValidVoucherErrorLbl: Label 'Voucher with type %1 and reference no. %2 is not valid yet.', Comment = '%1 - voucher type, %2 - reference no.';
        ExpiredValidVoucherErrorLbl: Label 'Voucher with type %1 and reference no. %2 has expired.', Comment = '%1 - voucher type, %2 - reference no.';
        TimeStamp: DateTime;
    begin
        if not Voucher."Allow Top-up" then begin
            Voucher.CalcFields(Open);
            if not Voucher.Open then
                Error(VoucherFullyUsedErrorLbl, Voucher."Voucher Type", Voucher."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if Voucher."Starting Date" > Timestamp then
            Error(NotValidVoucherErrorLbl, Voucher."Voucher Type", Voucher."Reference No.");

        if (Voucher."Ending Date" < Timestamp) and (Voucher."Ending Date" <> 0DT) then
            Error(ExpiredValidVoucherErrorLbl, Voucher."Voucher Type", Voucher."Reference No.");
    end;

    internal procedure CalculateVirtualItemsDocStatus(EcomSalesHeader: Record "NPR Ecom Sales Header") VirtualItemsDocStatus: Enum "NPR EcomVirtualItemDocStatus";
    var
        HasError: Boolean;
        HasPartiallyProcessed: Boolean;
        AllProcessed: Boolean;
        VoucherProcessed: Boolean;
        TicketProcessed: Boolean;
    begin
        HasError := (EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Error) or
                    (EcomSalesHeader."Ticket Processing Status" = EcomSalesHeader."Ticket Processing Status"::Error);

        if HasError then begin
            VirtualItemsDocStatus := VirtualItemsDocStatus::Error;
            exit;
        end;

        VoucherProcessed := (not EcomSalesHeader."Vouchers Exist") or (EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Processed);
        TicketProcessed := (not EcomSalesHeader."Tickets Exist") or (EcomSalesHeader."Ticket Processing Status" = EcomSalesHeader."Ticket Processing Status"::Processed);

        // Partially Processed logic:
        // - If vouchers don't exist, tickets can never be partially processed
        // - If vouchers exist and tickets don't exist, check voucher status
        // - If both exist, partial unless both are fully processed
        if not EcomSalesHeader."Vouchers Exist" then
            HasPartiallyProcessed := false
        else begin
            if not EcomSalesHeader."Tickets Exist" then
                HasPartiallyProcessed := (EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::"Partially Processed")
            else
                HasPartiallyProcessed := not (VoucherProcessed and TicketProcessed);
        end;

        if HasPartiallyProcessed then begin
            VirtualItemsDocStatus := VirtualItemsDocStatus::"Partially Processed";
            exit;
        end;
        AllProcessed := VoucherProcessed and TicketProcessed;
        if AllProcessed and (EcomSalesHeader."Vouchers Exist" or EcomSalesHeader."Tickets Exist") then begin
            VirtualItemsDocStatus := VirtualItemsDocStatus::Processed;
            exit;
        end;
        // Default to Pending
        VirtualItemsDocStatus := VirtualItemsDocStatus::Pending;
    end;

    internal procedure IsTicketItem(ItemNo: Text[50]): Boolean
    var
        Item: Record Item;
        ItemCode: Code[20];
    begin
        if ItemNo = '' then
            exit(false);
        if not Evaluate(ItemCode, ItemNo) then
            exit(false);
        if not Item.Get(ItemCode) then
            exit(false);
        exit(Item."NPR Ticket Type" <> '');
    end;

    internal procedure EmitError(ErrorTxt: text; EventId: text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ErrorText', ErrorTxt);
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());

        Session.LogMessage(EventId, ErrorTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

}

#endif