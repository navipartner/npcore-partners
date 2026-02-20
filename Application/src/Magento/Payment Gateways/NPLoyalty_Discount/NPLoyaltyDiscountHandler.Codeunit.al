
codeunit 6248662 "NPR NPLoyalty Discount Handler" implements "NPR IPaymentGateway"
{
    Access = Internal;
    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesInvHeader: Record "Sales Invoice Header";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary;
        LoyaltyPointMgmt: Codeunit "NPR MM Loyalty Point Mgt.";
        NPLoyaltyDiscountMgnt: Codeunit "NPR NP Loyalty Discount Mgt";
        CaptureFailedErr: Label 'Loyalty points capture failed: %1 (ID: %2)';
        Success: Boolean;
        DocumentNo: Code[20];
        EcomSaleId: Guid;
        MembershipSystemId: Guid;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if GeneralLedgerSetup.Get() then;
        case Request."Document Table No." of
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System ID");
                    DocumentNo := SalesInvHeader."No.";
                    MembershipSystemId := NPLoyaltyDiscountMgnt.GetMembershipId(SalesInvHeader."Bill-to Customer No.");
                    EcomSaleId := SalesInvHeader."NPR Inc Ecom Sale Id";
                end;
            Database::"NPR Ecom Sales Header":
                begin
                    EcomSalesHeader.GetBySystemId(Request."Document System ID");
                    MembershipSystemId := NPLoyaltyDiscountMgnt.GetMembershipId(EcomSalesHeader."Sell-to Customer No.");
                    DocumentNo := EcomSalesHeader."External No.";
                    EcomSaleId := EcomSalesHeader.SystemId;
                end;
        end;
        if GetReservationEntryFromAuthorization(ReservationLedgerEntry, CopyStr(Request."Transaction ID", 1, MaxStrLen(ReservationLedgerEntry."Authorization Code"))) then
            MakeAuthorization(TempAuthorization, ReservationLedgerEntry, DocumentNo, EcomSaleId, false);

        AddPaymentLinetoBuffer(TempPaymentLineBuffer, ReservationLedgerEntry, Request, GeneralLedgerSetup);

        Success := LoyaltyPointMgmt.EcomCaptureReservation(TempAuthorization, TempPaymentLineBuffer, ResponseMessage, ResponseMessageId, MembershipSystemId, EcomSaleId, DocumentNo, 1);
        Response."Response Success" := Success;
        if not Success then
            Error(CaptureFailedErr, ResponseMessage, ResponseMessageId);
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary;
        LoyaltyPointMgmt: Codeunit "NPR MM Loyalty Point Mgt.";
        NPLoyaltyDiscountMgnt: Codeunit "NPR NP Loyalty Discount Mgt";
        RefundFailedErr: Label 'Loyalty points refund failed: %1 (ID: %2)';
        Success: Boolean;
        EcomSaleId: Guid;
        MembershipSystemId: Guid;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if GeneralLedgerSetup.Get() then;

        SalesCrMemoHeader.GetBySystemId(Request."Document System ID");

        MembershipSystemId := NPLoyaltyDiscountMgnt.GetMembershipId(SalesCrMemoHeader."Bill-to Customer No.");

        EcomSaleId := SalesCrMemoHeader."NPR Inc Ecom Sale Id";

        if GetReservationEntryFromAuthorization(ReservationLedgerEntry, CopyStr(Request."Transaction ID", 1, MaxStrLen(ReservationLedgerEntry."Authorization Code"))) then
            MakeAuthorization(TempAuthorization, ReservationLedgerEntry, SalesCrMemoHeader."No.", EcomSaleId, false);
        AddPaymentLinetoBuffer(TempPaymentLineBuffer, ReservationLedgerEntry, Request, GeneralLedgerSetup);

        Success := LoyaltyPointMgmt.EcomCaptureReservation(TempAuthorization, TempPaymentLineBuffer, ResponseMessage, ResponseMessageId, MembershipSystemId, EcomSaleId, SalesCrMemoHeader."No.", 1);
        Response."Response Success" := Success;
        if not Success then
            Error(RefundFailedErr, ResponseMessage, ResponseMessageId);
    end;

    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesHeader: Record "Sales Header";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        NPLoyaltyDiscountMgnt: Codeunit "NPR NP Loyalty Discount Mgt";
        CancelationFailedErr: Label 'Loyalty points cancel failed: %1 (ID: %2)';
        Success: Boolean;
        EcomSaleId: Guid;
        MembershipSystemId: Guid;
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin
        if GeneralLedgerSetup.Get() then;

        SalesHeader.GetBySystemId(Request."Document System ID");

        MembershipSystemId := NPLoyaltyDiscountMgnt.GetMembershipId(SalesHeader."Bill-to Customer No.");

        EcomSaleId := SalesHeader."NPR Inc Ecom Sale Id";

        if GetReservationEntryFromAuthorization(ReservationLedgerEntry, CopyStr(Request."Transaction ID", 1, MaxStrLen(ReservationLedgerEntry."Authorization Code"))) then
            MakeAuthorization(TempAuthorization, ReservationLedgerEntry, ReservationLedgerEntry."Reference Number", EcomSaleId, true);
        AddPaymentLinetoBuffer(TempPaymentLineBuffer, ReservationLedgerEntry, Request, GeneralLedgerSetup);

        Success := LoyaltyPointsMgrServer.CancelReservation(TempAuthorization, TempPaymentLineBuffer, TempPointsOut, ResponseMessage, ResponseMessageId, MembershipSystemId, 1);
        Response."Response Success" := Success;
        if not Success then
            Error(CancelationFailedErr, ResponseMessage, ResponseMessageId);
    end;

    local procedure AddPaymentLinetoBuffer(var TempPaymentLineBuffer: Record "NPR MM Reg. Sales Buffer" temporary; ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)"; Request: Record "NPR PG Payment Request"; GeneralLedgerSetup: Record "General Ledger Setup")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        TempPaymentLineBuffer.Init();
        TempPaymentLineBuffer."Entry No." += 1;
        TempPaymentLineBuffer."Authorization Code" := ReservationLedgerEntry."Authorization Code";
        TempPaymentLineBuffer."Currency Code" := GeneralLedgerSetup."LCY Code";
        Case Request."Document Table No." of
            Database::"Sales Invoice Header":
                begin
                    TempPaymentLineBuffer."Total Points" := -ReservationLedgerEntry."Burned Points";
                    TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::PAYMENT;
                    TempPaymentLineBuffer."Total Amount" := Request."Request Amount";
                end;

            Database::"Sales Cr.Memo Header":
                begin
                    TempPaymentLineBuffer."Total Points" := -ReservationLedgerEntry."Burned Points";
                    TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::REFUND;
                    TempPaymentLineBuffer."Total Amount" := -Request."Request Amount";
                end;

            Database::"Sales Header":
                TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::CANCEL_RESERVATION;

            Database::"NPR Ecom Sales Header":
                begin
                    if EcomSalesHeader.GetBySystemId(Request."Document System Id") then
                        if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then begin
                            TempPaymentLineBuffer."Total Points" := -ReservationLedgerEntry."Burned Points";
                            TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::PAYMENT;
                            TempPaymentLineBuffer."Total Amount" := Request."Request Amount";
                        end else begin
                            TempPaymentLineBuffer."Total Points" := -ReservationLedgerEntry."Burned Points";
                            TempPaymentLineBuffer.Type := TempPaymentLineBuffer.Type::REFUND;
                            TempPaymentLineBuffer."Total Amount" := -Request."Request Amount";
                        end;
                end;
        End;
        TempPaymentLineBuffer.Insert();
    end;

    local procedure GetReservationEntryFromAuthorization(var ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)"; AuthorizationCode: Text[40]): Boolean
    begin
        ReservationLedgerEntry.SetCurrentKey("Authorization Code");
        ReservationLedgerEntry.SetRange("Authorization Code", AuthorizationCode);
        ReservationLedgerEntry.SetRange("Entry Type", ReservationLedgerEntry."Entry Type"::RESERVE);
        exit(ReservationLedgerEntry.FindFirst());
    end;

    local procedure MakeAuthorization(var TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)"; DocNo: Code[20]; EcomSaleId: Guid; IsCancel: Boolean)
    begin
        TempAuthorization.Init();
        TempAuthorization."Entry No." := 0;
        TempAuthorization."Company Name" := ReservationLedgerEntry."Company Name";
        TempAuthorization."POS Store Code" := ReservationLedgerEntry."POS Store Code";
        TempAuthorization."POS Unit Code" := ReservationLedgerEntry."POS Unit Code";
        TempAuthorization."Reference Number" := DocNo;
        TempAuthorization."Transaction Date" := Today;
        TempAuthorization."Transaction Time" := Time;
        if IsCancel then
            TempAuthorization."Authorization Code" := ''
        else
            TempAuthorization."Authorization Code" := ReservationLedgerEntry."Authorization Code";
        TempAuthorization."Foreign Transaction Id" := ReservationLedgerEntry."Foreign Transaction Id";
        TempAuthorization."Inc Ecom Sale Id" := EcomSaleId;
        TempAuthorization.Insert(false);
    end;

    procedure IsLoyaltyPointsPaymentLine(PaymentGatewayCode: Code[10]): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentGatewayCode = '' then
            exit(false);
        if not PaymentGateway.Get(PaymentGatewayCode) then
            exit(false);
        exit(PaymentGateway."Integration Type" = PaymentGateway."Integration Type"::NPLoyalty_Discount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMembershipPointsUpdate', '', true, true)]
    local procedure OnAfterMembershipPointsUpdate(MembershipEntryNo: Integer; MembershipPointsEntryNo: Integer)
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        ReserveLoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ValueEntry: Record "Value Entry";
        EcomSaleId: Guid;
    begin
        if not Membership.Get(MembershipEntryNo) then
            exit;
        if not MembershipPointsEntry.Get(MembershipPointsEntryNo) then
            exit;
        if not ValueEntry.Get(MembershipPointsEntry."Value Entry No.") then
            exit;
        if ValueEntry."Document Type" = ValueEntry."Document Type"::" " then
            exit;
        if not (ValueEntry."Document Type" In [ValueEntry."Document Type"::"Sales Invoice", ValueEntry."Document Type"::"Sales Credit Memo"]) then
            exit;
        Case ValueEntry."Document Type" of
            ValueEntry."Document Type"::"Sales Invoice":
                begin
                    if not SalesInvoiceHeader.Get(ValueEntry."Document No.") then
                        exit;
                    if IsNullGuid(SalesInvoiceHeader."NPR Inc Ecom Sale Id") then
                        exit;
                    EcomSaleId := SalesInvoiceHeader."NPR Inc Ecom Sale Id";
                end;
            ValueEntry."Document Type"::"Sales Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(ValueEntry."Document No.") then
                        exit;
                    if IsNullGuid(SalesCrMemoHeader."NPR Inc Ecom Sale Id") then
                        exit;
                    EcomSaleId := SalesCrMemoHeader."NPR Inc Ecom Sale Id";
                end;
        end;
        ReserveLoyaltyStoreLedger.SetCurrentKey("Inc Ecom Sale Id");
        ReserveLoyaltyStoreLedger.SetRange("Inc Ecom Sale Id", EcomSaleId);
        ReserveLoyaltyStoreLedger.SetRange("Entry Type", ReserveLoyaltyStoreLedger."Entry Type"::RESERVE);
        if not ReserveLoyaltyStoreLedger.FindFirst() then
            UpsertLoyaltyStoreLedger(LoyaltyStoreLedger, MembershipPointsEntry, EcomSaleId)
        else
            UpsertLoyaltyStoreLedgerWithReserve(LoyaltyStoreLedger, ReserveLoyaltyStoreLedger, MembershipPointsEntry, EcomSaleId);
        MembershipPointsEntry."Awarded Points" := MembershipPointsEntry.Points;
        MembershipPointsEntry.Modify();
        Membership.CalcFields("Remaining Points");
        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Modify();
    end;

    local procedure UpsertLoyaltyStoreLedger(var LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; MembershipPointsEntry: Record "NPR MM Members. Points Entry"; EcomSalesId: Guid)
    var
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
    begin
        LoyaltyStoreLedger.SetCurrentKey("Inc Ecom Sale Id");
        LoyaltyStoreLedger.SetRange("Inc Ecom Sale Id", EcomSalesId);
        LoyaltyStoreLedger.SetRange("Entry Type", LoyaltyStoreLedger."Entry Type"::RECEIPT);
        if not LoyaltyStoreLedger.FindFirst() then begin
            LoyaltyStoreLedger.Init();
            LoyaltyStoreLedger."Entry No." := 0;
            LoyaltyStoreLedger."Entry Type" := LoyaltyStoreLedger."Entry Type"::RECEIPT;
            LoyaltyStoreLedger."Authorization Code" := LoyaltyPointsMgrServer.CreateAuthorizationCode();
            LoyaltyStoreLedger."Reference Number" := MembershipPointsEntry."Document No.";
            LoyaltyStoreLedger."Transaction Date" := Today;
            LoyaltyStoreLedger."Transaction Time" := Time;
            LoyaltyStoreLedger."Earned Points" := MembershipPointsEntry.Points;
            LoyaltyStoreLedger."Inc Ecom Sale Id" := EcomSalesId;
            LoyaltyStoreLedger.Insert();
        end else
            LoyaltyStoreLedger."Earned Points" += MembershipPointsEntry.Points;
    end;

    local procedure UpsertLoyaltyStoreLedgerWithReserve(var LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; ReserveLoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; MembershipPointsEntry: Record "NPR MM Members. Points Entry"; EcomSalesId: Guid)
    var
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
    begin
        LoyaltyStoreLedger.SetCurrentKey("Inc Ecom Sale Id");
        LoyaltyStoreLedger.SetRange("Inc Ecom Sale Id", EcomSalesId);
        LoyaltyStoreLedger.SetRange("Entry Type", LoyaltyStoreLedger."Entry Type"::RECEIPT);
        if not LoyaltyStoreLedger.FindFirst() then begin
            LoyaltyStoreLedger.TransferFields(ReserveLoyaltyStoreLedger, false);
            LoyaltyStoreLedger."Entry Type" := LoyaltyStoreLedger."Entry Type"::RECEIPT;
            LoyaltyStoreLedger."Authorization Code" := LoyaltyPointsMgrServer.CreateAuthorizationCode();
            LoyaltyStoreLedger."Retail Id" := ReserveLoyaltyStoreLedger."Retail Id";
            LoyaltyStoreLedger."Reference Number" := MembershipPointsEntry."Document No.";
            LoyaltyStoreLedger."Entry No." := 0;
            LoyaltyStoreLedger."Earned Points" := 0;
            LoyaltyStoreLedger."Burned Points" := 0;
            LoyaltyStoreLedger."Earned Points" := MembershipPointsEntry.Points;
            LoyaltyStoreLedger.Insert();
        end else
            LoyaltyStoreLedger."Earned Points" += MembershipPointsEntry.Points;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'OnAfterCaptureSalesInvoice', '', true, true)]
    local procedure OnAfterCaptureSalesInvoice(SalesInvHdrNo: Code[20])
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempMembershipEntryTagBuffer: Record "NPR MM Memb. Entry Tag Buff" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        MagentoPmtMngt: Codeunit "NPR Magento Pmt. Mgt.";
        NPLoyaltyDiscountMgnt: Codeunit "NPR NP Loyalty Discount Mgt";
        TotalBurnAmount: Decimal;
        TotalEarnAmount: Decimal;
        SalesDocumentTypeEnum: Enum "Sales Document Type";
        MembershipSystemId: Guid;
    begin
        if not SalesInvoiceHeader.Get(SalesInvHdrNo) then
            exit;

        if not MagentoPmtMngt.HasMagentoPaymentPoints(Database::"Sales Invoice Header", SalesDocumentTypeEnum::Quote, SalesInvHdrNo) then
            exit;

        MembershipSystemId := NPLoyaltyDiscountMgnt.GetMembershipId(SalesInvoiceHeader."Bill-to Customer No.");
        if IsNullGuid(MembershipSystemId) then
            exit;

        if not Membership.GetBySystemId(MembershipSystemId) then
            exit;

        LoyaltyStoreLedger.SetCurrentKey("Inc Ecom Sale Id");
        LoyaltyStoreLedger.SetRange("Inc Ecom Sale Id", SalesInvoiceHeader."NPR Inc Ecom Sale Id");
        LoyaltyStoreLedger.SetRange("Entry Type", LoyaltyStoreLedger."Entry Type"::RECEIPT);
        if not LoyaltyStoreLedger.FindFirst() then
            exit;

        CalculateTotalEarnBurnAmount(SalesInvoiceHeader, TotalEarnAmount, TotalBurnAmount);

        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        if (TotalEarnAmount <> 0) and (TotalBurnAmount <> 0) then
            LoyaltyPointsMgrServer.CreateNotEligibleEntry(LoyaltySetup, LoyaltyStoreLedger, Membership, TempMembershipEntryTagBuffer, TotalEarnAmount, TotalBurnAmount);

        Membership.CalcFields("Remaining Points");
        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Modify();

        UpdateDocumentNoWithPostedDocNo(SalesInvoiceHeader, Membership);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'OnAfterRefundSalesCreditMemo', '', true, true)]
    local procedure OnAfterRefundSalesCreditMemo(SalesCrMemoHdrNo: Code[20])
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempMembershipEntryTagBuffer: Record "NPR MM Memb. Entry Tag Buff" temporary;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        MagentoPmtMngt: Codeunit "NPR Magento Pmt. Mgt.";
        NPLoyaltyDiscountMgnt: Codeunit "NPR NP Loyalty Discount Mgt";
        TotalBurnAmount: Decimal;
        TotalEarnAmount: Decimal;
        SalesDocumentTypeEnum: Enum "Sales Document Type";
        MembershipSystemId: Guid;
    begin
        if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
            exit;

        if not MagentoPmtMngt.HasMagentoPaymentPoints(Database::"Sales Cr.Memo Header", SalesDocumentTypeEnum::Quote, SalesCrMemoHdrNo) then
            exit;

        MembershipSystemId := NPLoyaltyDiscountMgnt.GetMembershipId(SalesCrMemoHeader."Bill-to Customer No.");
        if IsNullGuid(MembershipSystemId) then
            exit;

        if not Membership.GetBySystemId(MembershipSystemId) then
            exit;

        LoyaltyStoreLedger.SetCurrentKey("Inc Ecom Sale Id");
        LoyaltyStoreLedger.SetRange("Inc Ecom Sale Id", SalesCrMemoHeader."NPR Inc Ecom Sale Id");
        LoyaltyStoreLedger.SetRange("Entry Type", LoyaltyStoreLedger."Entry Type"::RECEIPT);
        if not LoyaltyStoreLedger.FindFirst() then
            exit;

        CalculateTotalEarnBurnAmount(SalesCrMemoHeader, TotalEarnAmount, TotalBurnAmount);

        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        if (TotalEarnAmount <> 0) and (TotalBurnAmount <> 0) then
            LoyaltyPointsMgrServer.CreateNotEligibleEntry(LoyaltySetup, LoyaltyStoreLedger, Membership, TempMembershipEntryTagBuffer, TotalEarnAmount, TotalBurnAmount);

        Membership.CalcFields("Remaining Points");
        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Modify();

        UpdateDocumentNoWithPostedDocNo(SalesCrMemoHeader, Membership);
    end;

    local procedure CalculateTotalEarnBurnAmount(RecordVariant: Variant; var TotalEarnAmount: Decimal; var TotalBurnAmount: Decimal)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        Case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                    SalesInvoiceLine.CalcSums("Amount Including VAT");
                    TotalEarnAmount := SalesInvoiceLine."Amount Including VAT";

                    SalesInvoiceLine.SetRange(Type);
                    SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"G/L Account");
                    SalesInvoiceLine.SetRange("NPR Loyalty Discount", true);
                    SalesInvoiceLine.CalcSums("Amount Including VAT");
                    TotalBurnAmount := SalesInvoiceLine."Amount Including VAT";
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
                    SalesCrMemoLine.CalcSums("Amount Including VAT");
                    TotalEarnAmount := SalesCrMemoLine."Amount Including VAT" * -1;

                    SalesCrMemoLine.SetRange(Type);
                    SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
                    SalesCrMemoLine.SetRange("NPR Loyalty Discount", true);
                    SalesCrMemoLine.CalcSums("Amount Including VAT");
                    TotalBurnAmount := SalesCrMemoLine."Amount Including VAT" * -1;
                end;
        end;
    end;

    local procedure UpdateDocumentNoWithPostedDocNo(RecordVariant: Variant; Membership: Record "NPR MM Membership")
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        MembershipPointsEntry.SetCurrentKey("Membership Entry No.", "Entry Type", "Document No.");
        MembershipPointsEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipPointsEntry.SetRange("Entry Type", MembershipPointsEntry."Entry Type"::CAPTURE);

        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        Case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    MembershipPointsEntry.SetRange("Document No.", SalesInvoiceHeader."External Document No.");
                    MembershipPointsEntry.ModifyAll("Document No.", SalesInvoiceHeader."No.");
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    RecRef.SetTable(SalesCrMemoHeader);
                    MembershipPointsEntry.SetRange("Document No.", SalesCrMemoHeader."External Document No.");
                    MembershipPointsEntry.ModifyAll("Document No.", SalesCrMemoHeader."No.");
                end;
        end;
    end;

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        CaptureInternal(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        RefundInternal(Request, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        CancelInternal(Request, Response);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10])
    begin
    end;

    #endregion
}
