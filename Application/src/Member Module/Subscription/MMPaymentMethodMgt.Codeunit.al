codeunit 6185075 "NPR MM Payment Method Mgt."
{
    Access = Internal;

#if (BC17 or BC18 or BC19 or BC20 or BC21)
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member Payment Method", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member Payment Method", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure OnAfterDeleteMemberPaymentMethod(var Rec: Record "NPR MM Member Payment Method")
    var
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        if (Rec.IsTemporary()) then
            exit;

        MembershipPmtMethodMap.SetRange(PaymentMethodId, Rec.SystemId);
        MembershipPmtMethodMap.DeleteAll();
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
            // TODO: Check if this refactor is correct
            Customer.SetLoadFields("No.");
            if Customer.Get(SalePOS."Customer No.") then begin
                Membership.Reset();
                Membership.SetCurrentKey("Customer No.");
                Membership.SetRange("Customer No.", Customer."No.");
                Membership.SetLoadFields("Entry No.");
                if Membership.FindFirst() then
                    if FindMemberPaymentMethod(EFTTransactionRequest, MemberPaymentMethod) then
                        SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
            end;
        until EFTTransactionRequest.Next() = 0;
    end;

    internal procedure SetMemberPaymentMethodAsDefault(Membership: Record "NPR MM Membership"; MemberPaymentMethodEntryNo: Integer)
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        MemberPaymentMethod.Get(MemberPaymentMethodEntryNo);
        SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
    end;

    internal procedure SetMemberPaymentMethodAsDefault(var Membership: Record "NPR MM Membership"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        if (not MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId)) then begin
            MembershipPmtMethodMap.Init();
            MembershipPmtMethodMap.PaymentMethodId := MemberPaymentMethod.SystemId;
            MembershipPmtMethodMap.MembershipId := Membership.SystemId;
            MembershipPmtMethodMap.Insert(true);
        end;

        if not MembershipPmtMethodMap.Default then begin
            MembershipPmtMethodMap.Validate(Default, true);
            MembershipPmtMethodMap.Modify(true);
        end;

        if MemberPaymentMethod.Status <> MemberPaymentMethod.Status::Active then begin
            MemberPaymentMethod.Validate(Status, MemberPaymentMethod.Status::Active);
            MemberPaymentMethod.Modify(true);
        end;

        MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, true, false);
    end;

    internal procedure FindMemberPaymentMethod(EftTransactionRequest: Record "NPR EFT Transaction Request"; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        SubscriptionPSP: Enum "NPR MM Subscription PSP";
    begin
        if EftTransactionRequest."Recurring Detail Reference" = '' then
            exit;

        case EftTransactionRequest."Integration Type" of
            EFTAdyenIntegration.CloudIntegrationType(),
            EFTAdyenIntegration.HWCIntegrationType():
                SubscriptionPSP := SubscriptionPSP::Adyen;
        end;

        Found := FindMemberPaymentMethod(EftTransactionRequest."Recurring Detail Reference", EftTransactionRequest."Internal Customer ID", SubscriptionPSP, MemberPaymentMethod);
    end;

    internal procedure FindMemberPaymentMethod(PaymentLine: Record "NPR Magento Payment Line"; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        SubscriptionPSP: Enum "NPR MM Subscription PSP";
    begin
        if PaymentLine."Payment Token" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;

        case PaymentGateway."Integration Type" of
            PaymentGateway."Integration Type"::Adyen:
                SubscriptionPSP := SubscriptionPSP::Adyen;
        end;

        Found := FindMemberPaymentMethod(PaymentLine."Payment Token", PaymentLine."Payment Gateway Shopper Ref.", SubscriptionPSP, MemberPaymentMethod);
    end;

    internal procedure FindMemberPaymentMethod(PaymentToken: Text[64]; ShopperReference: Text[50]; SubscriptionPSP: Enum "NPR MM Subscription PSP"; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean
    begin
        if (PaymentToken = '') then
            exit;

        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetCurrentKey(PSP, "Payment Token", "Shopper Reference");
        MemberPaymentMethod.SetRange("Payment Token", PaymentToken);
        MemberPaymentMethod.SetRange("Shopper Reference", ShopperReference);
        MemberPaymentMethod.SetRange(PSP, SubscriptionPSP);

        Found := MemberPaymentMethod.FindFirst();
    end;

    internal procedure FindPaymentMethod(PaymentToken: Text[64]; ShopperReference: Text[50]; SubscriptionPSP: Enum "NPR MM Subscription PSP"; UserAccount: Record "NPR UserAccount"; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean
    begin
        if PaymentToken = '' then
            exit;

        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetCurrentKey("Table No.", "BC Record ID", PSP, "Payment Token", "Shopper Reference");
        MemberPaymentMethod.SetRange("BC Record ID", UserAccount.RecordId());
        MemberPaymentMethod.SetRange("Table No.", UserAccount.RecordId().TableNo);
        MemberPaymentMethod.SetRange("Payment Token", PaymentToken);
        MemberPaymentMethod.SetRange("Shopper Reference", ShopperReference);
        MemberPaymentMethod.SetRange(PSP, SubscriptionPSP);

        Found := MemberPaymentMethod.FindFirst();
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

    /// <summary>
    /// Try to get payment method for a subscription
    /// </summary>
    /// <param name="Subscription">The subscription record to get payment method for</param>
    /// <param name="IncludeNonDefault">Determines if the code should fetch non-default payment methods in case it can't find a default.</param>
    /// <param name="MemberPaymentMethod">The record to be filled out with the found method.</param>
    /// <returns></returns>
    [TryFunction]
    internal procedure TryGetMemberPaymentMethod(Subscription: Record "NPR MM Subscription"; IncludeNonDefault: Boolean; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    begin
        Subscription.TestField("Membership Entry No.");
        TryGetMemberPaymentMethod(Subscription."Membership Entry No.", IncludeNonDefault, MemberPaymentMethod);
    end;

    internal procedure GetMemberPaymentMethod(MembershipEntryNo: Integer; var MemberPaymentMethod: Record "NPR MM Member Payment Method") Found: Boolean;
    begin
        Found := TryGetMemberPaymentMethod(MembershipEntryNo, false, MemberPaymentMethod);
    end;

    [TryFunction]
    internal procedure TryGetMemberPaymentMethod(MembershipEntryNo: Integer; IncludeNonDefault: Boolean; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Membership: Record "NPR MM Membership";
        FailedToFindMembershipErr: Label 'The system could not find membership %1', Comment = '%1 = membership entry no.';
        FailedToFindDefaultPaymentMethodForMembershipErr: Label 'The system could not find a default payment method for membership %1', Comment = '%1 = membership entry no.';
        FailedToFindPaymentMethodForMembershipErr: Label 'The system could not find a payment method for membership %1', Comment = '%1 = membership entry no.';
    begin
        Membership.SetLoadFields(SystemId);
        if not Membership.Get(MembershipEntryNo) then
            Error(FailedToFindMembershipErr, MembershipEntryNo);

        MembershipPmtMethodMap.SetRange(MembershipId, Membership.SystemId);
        MembershipPmtMethodMap.SetRange(Default, true);
        if (not MembershipPmtMethodMap.FindFirst()) then begin
            if (not IncludeNonDefault) then
                Error(FailedToFindDefaultPaymentMethodForMembershipErr, MembershipEntryNo);

            MembershipPmtMethodMap.SetRange(Default);
            if (not MembershipPmtMethodMap.FindFirst()) then
                Error(FailedToFindPaymentMethodForMembershipErr, MembershipEntryNo);
        end;

        MemberPaymentMethod.GetBySystemId(MembershipPmtMethodMap.PaymentMethodId);
    end;

    internal procedure AddMemberPaymentMethod(UserAccount: Record "NPR UserAccount"; PaymentLine: Record "NPR Magento Payment Line"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");

        Clear(MemberPaymentMethod);
        MemberPaymentMethod.Init();
        MemberPaymentMethod."BC Record ID" := UserAccount.RecordId();
        MemberPaymentMethod."Table No." := UserAccount.RecordId().TableNo();
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
        MemberPaymentMethod."Payment Instrument Type" := PaymentLine."Payment Instrument Type";
        MemberPaymentMethod."Payment Brand" := PaymentLine.Brand;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        MemberPaymentMethod."Payment Method Alias" := PaymentLine."Card Alias Token";
        MemberPaymentMethod."Masked PAN" := PaymentLine."Masked PAN";
#endif
        MemberPaymentMethod."Created from System Id" := PaymentLine.SystemId;
        MemberPaymentMethod.Modify(true);
    end;

    internal procedure AddMemberPaymentMethod(UserAccount: Record "NPR UserAccount"; EFTTransactionRequest: Record "NPR EFT Transaction Request"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        SubscriptionPSP: Enum "NPR MM Subscription PSP";
    begin
        Clear(MemberPaymentMethod);

        case EFTTransactionRequest."Integration Type" of
            EFTAdyenIntegration.CloudIntegrationType(),
            EFTAdyenIntegration.HWCIntegrationType():
                SubscriptionPSP := SubscriptionPSP::Adyen;
            else
                exit;
        end;

        MemberPaymentMethod.Init();
        MemberPaymentMethod."BC Record ID" := UserAccount.RecordId();
        MemberPaymentMethod."Table No." := UserAccount.RecordId().TableNo();
        MemberPaymentMethod.Insert(true);
        MemberPaymentMethod."Payment Token" := EFTTransactionRequest."Recurring Detail Reference";
        MemberPaymentMethod."Shopper Reference" := EFTTransactionRequest."Internal Customer ID";
        MemberPaymentMethod."Masked PAN" := EftTransactionRequest."Card Number";
        MemberPaymentMethod."PAN Last 4 Digits" := CopyStr(DELSTR(EFTTransactionRequest."Card Number", 1, STRLEN(EFTTransactionRequest."Card Number") - 4), 1, MaxStrLen(MemberPaymentMethod."PAN Last 4 Digits"));
        MemberPaymentMethod."Expiry Date" := GetLastDayOfMonth(EFTTransactionRequest."Card Expiry Year", EFTTransactionRequest."Card Expiry Month");
        MemberPaymentMethod.PSP := MemberPaymentMethod.PSP::Adyen;
        MemberPaymentMethod.Validate(Status, MemberPaymentMethod.Status::Active);
        MemberPaymentMethod."Payment Instrument Type" := EFTTransactionRequest."Payment Instrument Type";
        MemberPaymentMethod."Payment Brand" := EFTTransactionRequest."Payment Brand";
        MemberPaymentMethod."Created from System Id" := EFTTransactionRequest.SystemId;
        MemberPaymentMethod.Modify(true);
    end;

    local procedure GetLastDayOfMonth(ParamYear: Text[4]; ParamMonth: Text[2]): Date
    var
        FirstDayOfMonth: Date;
        Year: integer;
        Month: integer;
    begin
        Evaluate(Year, ParamYear);
        Evaluate(Month, ParamMonth);

        FirstDayOfMonth := DMY2Date(1, Month, Year);

        exit(CalcDate('<1M>', FirstDayOfMonth) - 1);
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