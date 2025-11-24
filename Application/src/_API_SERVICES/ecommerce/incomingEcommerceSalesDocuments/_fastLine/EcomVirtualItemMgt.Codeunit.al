#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248551 "NPR Ecom Virtual Item Mgt"
{
    Access = Internal;

    local procedure ProcessVirtualItemLine(var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        UnsupportedTypeLbl: Label 'Type %1 in %2 is not supported.', Comment = '%1 - ecom sales line type, %2 - record id';
    begin
        case EcomSalesLine.Type of
            EcomSalesLine.Type::Voucher:
                CreateVoucher(EcomSalesLine, true, false);
            else
                Error(UnsupportedTypeLbl, EcomSalesLine.Type, EcomSalesLine.RecordId);
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
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
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

    internal procedure AssignBucketLines(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        BucketInt: Integer;
    begin
        BucketInt := Random(100);

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Type, '%1', EcomSalesLine.Type::Voucher);
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

        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
        EcomSalesHeader."Vouchers Exist" := not EcomSalesLine.IsEmpty;

        EcomSalesHeader."Virtual Items Exist" := EcomSalesHeader."Vouchers Exist";
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
        EcomSalesLine.Setfilter(Type, '%1', EcomSalesLine.Type::Voucher);
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
    begin
        case true of
            EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Error:
                VirtualItemsDocStatus := VirtualItemsDocStatus::Error;

            EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::"Partially Processed":
                VirtualItemsDocStatus := VirtualItemsDocStatus::"Partially Processed";

            EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Processed:
                VirtualItemsDocStatus := VirtualItemsDocStatus::Processed;

            EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Pending:
                VirtualItemsDocStatus := VirtualItemsDocStatus::Pending;
        end;

    end;

}
#endif