codeunit 6185075 "NPR MM Payment Method Mgt."
{
    Access = Internal;

    internal procedure AddMemberPaymentMethod(RecID: RecordId; MemberPmtMethodEntryNo: Integer)
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MemberPaymentMethod2: Record "NPR MM Member Payment Method";
        MemberPaymentMethod3: Record "NPR MM Member Payment Method";
        Unassigned: Boolean;
    begin
        if (RecID.TableNo() = 0) or (MemberPmtMethodEntryNo = 0) then
            exit;
        if not MemberPaymentMethod.Get(MemberPmtMethodEntryNo) then
            exit;

        if (MemberPaymentMethod."Table No." = RecID.TableNo()) and (MemberPaymentMethod."BC Record ID" = RecID) then
            exit;  //Already assigned to the entity that we need to assign the payment method to

        Unassigned := MemberPaymentMethod."Table No." = 0;
        MemberPaymentMethod."Table No." := RecID.TableNo();
        MemberPaymentMethod."BC Record ID" := RecID;
        if Unassigned then begin
            MemberPaymentMethod2.Modify(true);
            exit;
        end;

        MemberPaymentMethod2 := MemberPaymentMethod;
        MemberPaymentMethod2.SetRange("Table No.", MemberPaymentMethod2."Table No.");
        MemberPaymentMethod2.SetRange("BC Record ID", MemberPaymentMethod2."BC Record ID");
        MemberPaymentMethod2.SetRange(PSP, MemberPaymentMethod2.PSP);
        MemberPaymentMethod2.SetRange(Status, MemberPaymentMethod2.Status);
        MemberPaymentMethod2.SetRange("Payment Token", MemberPaymentMethod2."Payment Token");
        if not MemberPaymentMethod2.FindFirst() then begin
            MemberPaymentMethod2."Entry No." := 0;
            MemberPaymentMethod2.Insert(true);
            exit;
        end;
        MemberPaymentMethod3 := MemberPaymentMethod2;
        MemberPaymentMethod2.TransferFields(MemberPaymentMethod, false);
        if Format(MemberPaymentMethod2) <> Format(MemberPaymentMethod3) then
            MemberPaymentMethod2.Modify(true);
    end;

    internal procedure SetMemberPaymentMethodDefaultBeforeEndSale(SalePOS: Record "NPR POS Sale")
    var
        Membership: Record "NPR MM Membership";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Customer: Record Customer;
    begin
        if SalePOS."Header Type" = SalePOS."Header Type"::Cancelled then
            exit;

        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EFTTransactionRequest.SetFilter("Sales Line No.", '<>%1', 0);
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetFilter("Recurring Detail Reference", '<>%1', '');
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        if not EFTTransactionRequest.FindLast() then
            exit;

        repeat
            MemberPaymentMethod.Reset();
            MemberPaymentMethod.SetCurrentKey("Created from System Id");
            MemberPaymentMethod.SetRange("Created from System Id", EFTTransactionRequest.SystemId);
            if MemberPaymentMethod.FindFirst() then
                SetMembePaymentMethodAsDefault(EFTTransactionRequest, MemberPaymentMethod)
            else begin
                Customer.SetLoadFields("No.");
                if Customer.Get(SalePOS."Customer No.") then begin
                    Membership.Reset();
                    Membership.SetCurrentKey("Customer No.");
                    Membership.SetRange("Customer No.", Customer."No.");
                    Membership.SetLoadFields("Entry No.");
                    if Membership.FindFirst() then
                        if FindMemberPaymentMethod(EFTTransactionRequest, Membership, MemberPaymentMethod) then
                            SetMembePaymentMethodAsDefault(EFTTransactionRequest, MemberPaymentMethod);
                end;
            end;
        until EFTTransactionRequest.Next() = 0;
    end;

    local procedure SetMembePaymentMethodAsDefault(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        Membership: Record "NPR MM Membership";
        Modi: Boolean;
    begin
        if not MemberPaymentMethod.Default then begin
            MemberPaymentMethod.Validate(Default, true);
            Modi := true;
        end;
        if MemberPaymentMethod.Status <> MemberPaymentMethod.Status::Active then begin
            MemberPaymentMethod.Validate(Status, MemberPaymentMethod.Status::Active);
            Modi := true;
        end;

        if Modi then
            MemberPaymentMethod.Modify(true);

        if MemberPaymentMethod."Table No." = Database::"NPR MM Membership" then
            if Membership.Get(MemberPaymentMethod."BC Record ID") then
                UpdateMembership(EftTransactionRequest, Membership);
    end;

    internal procedure SetMembePaymentMethodAsDefault(PaymentLine: Record "NPR Magento Payment Line"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        Membership: Record "NPR MM Membership";
        Modi: Boolean;
    begin
        if not MemberPaymentMethod.Default then begin
            MemberPaymentMethod.Validate(Default, true);
            Modi := true;
        end;
        if MemberPaymentMethod.Status <> MemberPaymentMethod.Status::Active then begin
            MemberPaymentMethod.Validate(Status, MemberPaymentMethod.Status::Active);
            Modi := true;
        end;

        if Modi then
            MemberPaymentMethod.Modify(true);

        if MemberPaymentMethod."Table No." = Database::"NPR MM Membership" then
            if Membership.Get(MemberPaymentMethod."BC Record ID") then
                UpdateMembership(PaymentLine, Membership);
    end;

    internal procedure FindMemberPaymentMethod(EftTransactionRequest: Record "NPR EFT Transaction Request"; Membership: Record "NPR MM Membership"; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        if EftTransactionRequest."Recurring Detail Reference" = '' then
            exit;

        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetCurrentKey("Table No.", "BC Record ID", PSP, "Payment Token", "Shopper Reference");
        MemberPaymentMethod.SetRange("BC Record ID", Membership.RecordId);
        MemberPaymentMethod.SetRange("Table No.", Database::"NPR MM Membership");
        MemberPaymentMethod.SetRange("Payment Token", EftTransactionRequest."Recurring Detail Reference");
        MemberPaymentMethod.SetRange("Shopper Reference", EftTransactionRequest."Internal Customer ID");
        case EftTransactionRequest."Integration Type" of
            EFTAdyenIntegration.CloudIntegrationType(),
            EFTAdyenIntegration.LocalIntegrationType():
                MemberPaymentMethod.SetRange(PSP, MemberPaymentMethod.PSP::Adyen);
        end;

        Found := MemberPaymentMethod.FindFirst();
    end;

    internal procedure FindMemberPaymentMethod(PaymentLine: Record "NPR Magento Payment Line"; Membership: Record "NPR MM Membership"; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Token" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;

        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetCurrentKey("Table No.", "BC Record ID", PSP, "Payment Token", "Shopper Reference");
        MemberPaymentMethod.SetRange("BC Record ID", Membership.RecordId);
        MemberPaymentMethod.SetRange("Table No.", Database::"NPR MM Membership");
        MemberPaymentMethod.SetRange("Payment Token", PaymentLine."Payment Token");
        MemberPaymentMethod.SetRange("Shopper Reference", PaymentLine."Payment Gateway Shopper Ref.");
        case PaymentGateway."Integration Type" of
            PaymentGateway."Integration Type"::Adyen:
                MemberPaymentMethod.SetRange(PSP, MemberPaymentMethod.PSP::Adyen);
        end;

        Found := MemberPaymentMethod.FindFirst();
    end;

    internal procedure UpdateMembership(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Membership: Record "NPR MM Membership")
    var
        Modi: Boolean;
    begin
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL then begin
            Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
            Modi := true;
        end;
        if Membership."Auto-Renew Payment Method Code" <> EftTransactionRequest."POS Payment Type Code" then begin
            Membership."Auto-Renew Payment Method Code" := EftTransactionRequest."POS Payment Type Code";
            Modi := true;
        end;
        if Modi then
            Membership.Modify();
    end;

    internal procedure UpdateMembership(PaymentLine: Record "NPR Magento Payment Line"; var Membership: Record "NPR MM Membership")
    var
        Modi: Boolean;
    begin
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL then begin
            Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
            Modi := true;
        end;
        if Membership."Auto-Renew Payment Method Code" <> PaymentLine."Source No." then begin
#pragma warning disable AA0139
            Membership."Auto-Renew Payment Method Code" := PaymentLine."Source No.";
#pragma warning restore AA0139
            Modi := true;
        end;
        if Modi then
            Membership.Modify();
    end;


    internal procedure DeleteMemberPaymentMethods(SalePOS: Record "NPR POS Sale")
    var
        SalesLinePOS: Record "NPR POS Sale Line";
    begin
        SalesLinePOS.Reset();
        SalesLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SalesLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SalesLinePOS.SetRange("Line Type", SalesLinePOS."Line Type"::"POS Payment");
        SalesLinePOS.SetLoadFields("Sales Ticket No.", "Line No.");
        if not SalesLinePOS.FindSet() then
            exit;

        repeat
            DeleteMemberPaymentMethod(SalesLinePOS);
        until SalesLinePOS.Next() = 0;
    end;

    internal procedure DeleteMemberPaymentMethod(CurrEftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetCurrentKey("Created from System Id");
        MemberPaymentMethod.SetRange("Created from System Id", CurrEftTransactionRequest.SystemId);
        if not MemberPaymentMethod.IsEmpty then
            MemberPaymentMethod.DeleteAll(true);
    end;

    local procedure DeleteMemberPaymentMethod(SalesLinePOS: Record "NPR POS Sale Line")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if SalesLinePOS."Line Type" <> SalesLinePOS."Line Type"::"POS Payment" then
            exit;

        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesLinePOS."Sales Ticket No.");
        EFTTransactionRequest.SetRange("Sales Line No.", SalesLinePOS."Line No.");
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetFilter("Recurring Detail Reference", '<>%1', '');
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.SetLoadFields("Sales Ticket No.", "Sales Line No.", SystemId, Successful, "Recurring Detail Reference", "Processing Type");
        if not EFTTransactionRequest.FindFirst() then
            exit;

        DeleteMemberPaymentMethod(EFTTransactionRequest);
    end;

    internal procedure GetMemberPaymentMethod(MembershipEntryNo: Integer; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean;
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.SetLoadFields("Entry No.", "Customer No.");
        if not Membership.Get(MembershipEntryNo) then
            exit;

        MemberPaymentMethod.SetCurrentKey("Table No.", "BC Record ID", Status, Default);
        MemberPaymentMethod.SetRange("Table No.", Database::"NPR MM Membership");
        MemberPaymentMethod.SetRange("BC Record ID", Membership.RecordId);
        MemberPaymentMethod.SetRange(Status, MemberPaymentMethod.Status::Active);
        MemberPaymentMethod.SetRange(Default, true);
        Found := MemberPaymentMethod.FindFirst();
    end;

    internal procedure AddMemberPaymentMethod(PaymentLine: Record "NPR Magento Payment Line"; Default: boolean; var MemberPaymentMethod: Record "NPR MM Member Payment Method"; Membership: Record "NPR MM Membership")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");

        Clear(MemberPaymentMethod);
        MemberPaymentMethod.Init();
        MemberPaymentMethod."BC Record ID" := Membership.RecordId;
        MemberPaymentMethod."Table No." := Database::"NPR MM Membership";
        MemberPaymentMethod.Insert(true);
        MemberPaymentMethod."Payment Token" := PaymentLine."Payment Token";
        MemberPaymentMethod."Shopper Reference" := PaymentLine."Payment Gateway Shopper Ref.";
        MemberPaymentMethod."PAN Last 4 Digits" := PaymentLine."Card Summary";
        MemberPaymentMethod."Expiry Date" := GetLastDateOfMonth(PaymentLine."Expiry Date Text");
        case PaymentGateway."Integration Type" of
            PaymentGateway."Integration Type"::Adyen:
                MemberPaymentMethod.PSP := MemberPaymentMethod.PSP::Adyen;
        end;
        MemberPaymentMethod.Validate(Status, MemberPaymentMethod.Status::Active);
        MemberPaymentMethod.Validate(Default, Default);
        MemberPaymentMethod."Payment Instrument Type" := PaymentLine."Payment Instrument Type";
        MemberPaymentMethod."Payment Brand" := PaymentLine.Brand;
        MemberPaymentMethod."Created from System Id" := PaymentLine.SystemId;
        MemberPaymentMethod.Modify(true);
    end;

    local procedure GetLastDateOfMonth(DateText: Text) LastDate: Date
    var
        Month: Integer;
        Year: Integer;
        SeparatorPosition: Integer;
        MonthText: Text;
        YearText: Text;
        InvalidMonthErrorLbl: Label 'Invalid month format: %1', Comment = '%1 - Month';
        InvalidYearErrorLbl: Label 'Invalid year format: %1', Comment = '%1 - Year';
    begin
        SeparatorPosition := StrPos(DateText, '/');
        MonthText := CopyStr(DateText, 1, SeparatorPosition - 1);
        if not Evaluate(Month, MonthText) then
            Error(InvalidMonthErrorLbl, MonthText);

        YearText := CopyStr(DateText, SeparatorPosition + 1);
        if not Evaluate(Year, YearText) then
            Error(InvalidYearErrorLbl, YearText);

        LastDate := DMY2Date(1, Month, Year);
        LastDate := CalcDate('<+1M-1D>', LastDate);
    end;
}