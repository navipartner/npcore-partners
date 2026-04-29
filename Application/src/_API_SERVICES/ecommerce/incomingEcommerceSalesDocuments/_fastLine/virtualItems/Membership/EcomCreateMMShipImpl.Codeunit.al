#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248527 "NPR EcomCreateMMShipImpl"
{
    Access = Internal;

    internal procedure Process(var EcomSalesLine: Record "NPR Ecom Sales Line") Success: Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
        CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);

        EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        if IsNullGuid(EcomSalesLine."Membership Id") then begin
            CreateMembership(EcomSalesLine, EcomSalesHeader);
            EcomVirtualItemEvents.OnAfterMembershipCreatedBeforeCommit(EcomSalesLine);
        end;

        ConfirmMembership(EcomSalesLine, EcomSalesHeader);
        EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
        exit(true);
    end;

    internal procedure CheckIfLineCanBeProcessed(EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        MembershipAlterationNotSupportedErr: Label 'Membership alteration items are currently not supported in ecommerce. Item %1 cannot be processed.', Comment = '%1=Item No.';
    begin
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        if EcommSalesLine.Subtype <> EcommSalesLine.Subtype::Membership then
            EcommSalesLine.FieldError(Subtype);

        if not EcommSalesLine.Captured then
            EcommSalesLine.FieldError(Captured);

        if (EcommSalesLine.Quantity <> 1) then
            EcommSalesLine.FieldError(Quantity);

        if EcommSalesLine."Document Type" = EcommSalesLine."Document Type"::"Return Order" then
            EcommSalesLine.FieldError("Document Type");

        if EcommSalesLine."Virtual Item Process Status" = EcommSalesLine."Virtual Item Process Status"::Processed then
            EcommSalesLine.FieldError(EcommSalesLine."Virtual Item Process Status");
#pragma warning disable AA0139
        if EcomVirtualItemMgt.HasMembershipAlterationSetup(EcommSalesLine."No.") then
            Error(MembershipAlterationNotSupportedErr, EcommSalesLine."No.");
#pragma warning restore
    end;

    local procedure ConfirmMembership(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        SalesHeader: Record "Sales Header";
        SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
        MembershipMissingErr: Label 'Membership with token %1 was not found.';
        MembershipBlockedErr: Label 'Membership %1 is blocked.', Comment = '%1=Membership Entry No.';
        MembershipEntryMissingErr: Label 'No active membership entry found for membership %1.';
        AlreadyConfirmedErr: Label 'Membership entry for membership %1 is already confirmed (Document No. is set).';
    begin
        EcomSalesLine.TestField("Membership Id");
        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Membership.GetBySystemId(EcomSalesLine."Membership Id") then
            Error(MembershipMissingErr, EcomSalesLine."Membership Id");

        if Membership.Blocked then
            Error(MembershipBlockedErr, Membership."Entry No.");

        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetLoadFields(Amount, "Amount Incl VAT", "Document No.", "Source Type", "Document Type");
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        if not MembershipEntry.FindFirst() then
            Error(MembershipEntryMissingErr, Membership."Entry No.");

        if MembershipEntry."Document No." <> '' then begin
            if MembershipEntry."Document No." = EcomSalesHeader."External No." then
                exit; // already confirmed by this order
            Error(AlreadyConfirmedErr, Membership."Entry No.");
        end;

        MembershipEntry."Source Type" := MembershipEntry."Source Type"::SALESHEADER;
        MembershipEntry."Document Type" := SalesHeader."Document Type"::Order;
        MembershipEntry."Document No." := EcomSalesHeader."External No.";

        UpdateMembershipEntryAmounts(MembershipEntry, EcomSalesLine, EcomSalesHeader);
        MembershipEntry.Modify();

        SponsorshipTicketMgmt.OnMembershipPayment(MembershipEntry);

        CreateMembershipPaymentMethods(EcomSalesHeader, Membership);
    end;

    internal procedure CreateMembership(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        ResponseMessage: Text;
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
#pragma warning disable AA0139
        MemberInfoCapture."Item No." := EcomSalesLine."No.";
        MemberInfoCapture."Import Entry Document ID" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
#pragma warning restore AA0139
        MemberInfoCapture.Insert();

        UpdateMemberInfoCaptureFromLine(MemberInfoCapture, EcomSalesLine);
        SetNotificationMethod(MemberInfoCapture);
        MemberInfoCapture.Modify();

        MembershipApiAgent.CreateMembershipWorker(MemberInfoCapture);

        if not MembershipManagement.AddMemberAndCard(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage) then
            Error(ResponseMessage);

        Membership.Get(MemberInfoCapture."Membership Entry No.");
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine.Modify();
        MemberInfoCapture.Delete();
    end;

    local procedure SetNotificationMethod(var MemberInfoCapture: Record "NPR MM Member Info Capture")
    begin
        if (MemberInfoCapture."E-Mail Address" = '') and (MemberInfoCapture."Phone No." <> '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::SMS;

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." = '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;

        if (MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." <> '') then
            MemberInfoCapture."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;
    end;

    local procedure UpdateMemberInfoCaptureFromLine(var MemberInfoCapture: Record "NPR MM Member Info Capture"; EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        MemberApiAgent: Codeunit "NPR MemberApiAgent";
    begin
#pragma warning disable AA0139
        MemberInfoCapture."First Name" := EcomSalesLine."Member First Name";
        MemberInfoCapture."Last Name" := EcomSalesLine."Member Last Name";
        MemberInfoCapture."Middle Name" := EcomSalesLine."Member Middle Name";
        MemberInfoCapture."E-Mail Address" := EcomSalesLine."Member Email";
        MemberInfoCapture."Phone No." := EcomSalesLine."Member Phone No.";
        MemberInfoCapture.Address := EcomSalesLine."Member Address";
        MemberInfoCapture.City := EcomSalesLine."Member City";
        MemberInfoCapture.Country := EcomSalesLine."Member Country";
        MemberInfoCapture."Post Code Code" := EcomSalesLine."Member Post Code";
        MemberInfoCapture.Birthday := EcomSalesLine."Member Birthday";
        MemberInfoCapture.Gender := MemberApiAgent.DecodeGender(EcomSalesLine."Member Gender");
        MemberInfoCapture."News Letter" := MemberApiAgent.DecodeNewsLetter(EcomSalesLine."Member Newsletter");
        MemberInfoCapture."GDPR Approval" := MemberApiAgent.DecodeGdprConsent(EcomSalesLine."Member GDPR Approval");
        MemberInfoCapture."Document Date" := EcomSalesLine."Membership Activation Date";
#pragma warning restore AA0139
        EcomVirtualItemEvents.OnAfterUpdateMemberInfoCaptureFromLine(MemberInfoCapture);
    end;

    internal procedure ValidateMembershipRequestForDirectCreation(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        ItemNoCode: Code[20];
        QuantityErr: Label 'Membership line quantity must be 1.';
        PromptActivationDateRequiredErr: Label 'Membership item %1 is configured with Valid From Base = Prompt. A membershipActivationDate must be provided on the sales line.', Comment = '%1=Item No.', Locked = true;
    begin
        if EcomSalesLine.Quantity <> 1 then
            Error(QuantityErr);
        ItemNoCode := GetItemNoAsCode20(EcomSalesLine);
        GetAndValidateMembershipSalesSetup(EcomSalesLine, ItemNoCode, MembershipSalesSetup);
        if MembershipSalesSetup.Blocked then
            MembershipSalesSetup.FieldError(Blocked);
        if (MembershipSalesSetup."Valid From Base" = MembershipSalesSetup."Valid From Base"::PROMPT) and (EcomSalesLine."Membership Activation Date" = 0D) then
            Error(PromptActivationDateRequiredErr, EcomSalesLine."No.");
        ValidateMembershipSetup(MembershipSalesSetup, MembershipSetup);
        ValidateMemberIdentityRequirements(EcomSalesLine, MembershipSetup);
        ValidateMemberDataForDirectCreation(EcomSalesLine, MembershipSalesSetup, MembershipSetup);
    end;

    local procedure ValidateMemberIdentityRequirements(EcomSalesLine: Record "NPR Ecom Sales Line"; MembershipSetup: Record "NPR MM Membership Setup")
    var
        Community: Record "NPR MM Member Community";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberApiAgent: Codeunit "NPR MemberApiAgent";
        UniqueIdentityEmailRequiredErr: Label 'Membership community requires member email (Member Unique Identity = E-Mail). Member Email must be provided.', Locked = true;
        UniqueIdentityPhoneRequiredErr: Label 'Membership community requires member phone number (Member Unique Identity = Phone No.). Member Phone No. must be provided.', Locked = true;
        UniqueIdentitySsnNotSupportedErr: Label 'Membership community requires Social Security No. (Member Unique Identity = SSN). This is not supported via ecommerce.', Locked = true;
        UniqueIdentityEmailAndPhoneRequiredErr: Label 'Membership community requires both member email and phone number (Member Unique Identity = E-Mail and Phone No.). Both Member Email and Member Phone No. must be provided.', Locked = true;
        UniqueIdentityEmailOrPhoneRequiredErr: Label 'Membership community requires member email or phone number (Member Unique Identity = E-Mail or Phone No.). Member Email or Member Phone No. must be provided.', Locked = true;
        UniqueIdentityEmailAndFirstNameRequiredErr: Label 'Membership community requires member email and first name (Member Unique Identity = E-Mail and First Name). Both Member Email and Member First Name must be provided.', Locked = true;
        GdprApprovalRequiredErr: Label 'Membership %1 has GDPR Mode = Required. memberGdprApproval must be set to "accepted".', Comment = '%1=Membership Code', Locked = true;
        InvalidEmailErr: Label 'memberEmail "%1" is not a valid email address.', Comment = '%1=Email address', Locked = true;
    begin
        Community.Get(MembershipSetup."Community Code");

        case Community."Member Unique Identity" of
            Community."Member Unique Identity"::EMAIL:
                if EcomSalesLine."Member Email" = '' then
                    Error(UniqueIdentityEmailRequiredErr);
            Community."Member Unique Identity"::PHONENO:
                if EcomSalesLine."Member Phone No." = '' then
                    Error(UniqueIdentityPhoneRequiredErr);
            Community."Member Unique Identity"::SSN:
                Error(UniqueIdentitySsnNotSupportedErr);
            Community."Member Unique Identity"::EMAIL_AND_PHONE:
                if (EcomSalesLine."Member Email" = '') or (EcomSalesLine."Member Phone No." = '') then
                    Error(UniqueIdentityEmailAndPhoneRequiredErr);
            Community."Member Unique Identity"::EMAIL_OR_PHONE:
                if (EcomSalesLine."Member Email" = '') and (EcomSalesLine."Member Phone No." = '') then
                    Error(UniqueIdentityEmailOrPhoneRequiredErr);
            Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME:
                if (EcomSalesLine."Member Email" = '') or (EcomSalesLine."Member First Name" = '') then
                    Error(UniqueIdentityEmailAndFirstNameRequiredErr);
        end;

        if EcomSalesLine."Member Email" <> '' then
            if not TryCheckValidEmailAddress(EcomSalesLine."Member Email") then
                Error(InvalidEmailErr, EcomSalesLine."Member Email");

        if MembershipSetup."GDPR Mode" = MembershipSetup."GDPR Mode"::REQUIRED then
            if MemberApiAgent.DecodeGdprConsent(EcomSalesLine."Member GDPR Approval") <> MemberInfoCapture."GDPR Approval"::ACCEPTED then
                Error(GdprApprovalRequiredErr, MembershipSetup.Code);
    end;

    local procedure ValidateMemberDataForDirectCreation(EcomSalesLine: Record "NPR Ecom Sales Line"; MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MembershipSetup: Record "NPR MM Membership Setup")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        MemberBirthdayRequiredErr: Label 'Member birthday is required for membership %1 due to configured age constraints (SKU: %2).', Comment = '%1=Membership Code;%2=Item No.';
        MemberAgeConstraintErr: Label 'Member does not meet the age requirement for membership %1.', Comment = '%1=Membership Code';
    begin
        if MembershipSetup."Enable Age Verification" and (EcomSalesLine."Member Birthday" = 0D) then
            Error(MemberBirthdayRequiredErr, MembershipSalesSetup."Membership Code", EcomSalesLine."No.");

        if MembershipSalesSetup."Age Constraint Type" = MembershipSalesSetup."Age Constraint Type"::NA then
            exit;

        if EcomSalesLine."Member Birthday" = 0D then
            Error(MemberBirthdayRequiredErr, MembershipSalesSetup."Membership Code", EcomSalesLine."No.");

        if not MembershipMgtInternal.CheckAgeConstraint(EcomSalesLine."Member Birthday", EcomSalesLine."Member Birthday", MembershipSetup."Validate Age Against", MembershipSalesSetup."Age Constraint Type", MembershipSalesSetup."Age Constraint (Years)") then
            Error(MemberAgeConstraintErr, MembershipSalesSetup."Membership Code");
    end;

    local procedure GetItemNoAsCode20(EcomSalesLine: Record "NPR Ecom Sales Line") ItemNoCode: Code[20]
    var
        ItemNoInvalidErr: Label 'Invalid item number "%1". Expected a value that can be converted to Code[20].', Comment = '%1=EcomSalesLine."No."', Locked = true;
    begin
        if not Evaluate(ItemNoCode, EcomSalesLine."No.") then
            Error(ItemNoInvalidErr, EcomSalesLine."No.");
    end;

    local procedure GetAndValidateMembershipSalesSetup(EcomSalesLine: Record "NPR Ecom Sales Line"; ItemNoCode: Code[20]; var MembershipSalesSetup: Record "NPR MM Members. Sales Setup")
    var
        MMNPRMembership: Codeunit "NPR MM NPR Membership";
        ItemNotMembershipErr: Label 'Item %1 is not set up as a membership item.', Comment = '%1=Item No.', Locked = true;
        ForeignMembershipErr: Label 'Membership for an external membership community cannot be created here. Use the Membership APIs.', Locked = true;
        BusinessFlowTypeErr: Label 'Membership item is not set up as Membership Business Flow Type. Use the Membership APIs.', Locked = true;
    begin
        if not GetMembershipSaleSetup(MembershipSalesSetup, ItemNoCode) then
            Error(ItemNotMembershipErr, EcomSalesLine."No.");

        if MMNPRMembership.IsForeignMembershipCommunity(MembershipSalesSetup."Membership Code") then
            Error(ForeignMembershipErr);

        if MembershipSalesSetup."Business Flow Type" <> MembershipSalesSetup."Business Flow Type"::MEMBERSHIP then
            Error(BusinessFlowTypeErr);
    end;

    local procedure ValidateMembershipSetup(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MembershipSetup: Record "NPR MM Membership Setup")
    var
        NotIndividualTypeErr: Label 'Membership %1 is not of type Individual and cannot be created via ecommerce. This is a programming bug.', Comment = '%1=Membership Code', Locked = true;
        NotNamedErr: Label 'Membership %1 does not require named member information and cannot be created via ecommerce. This is a programming bug.', Comment = '%1=Membership Code', Locked = true;
    begin
        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        if MembershipSetup."Membership Type" <> MembershipSetup."Membership Type"::INDIVIDUAL then
            Error(NotIndividualTypeErr, MembershipSalesSetup."Membership Code");

        if MembershipSetup."Member Information" <> MembershipSetup."Member Information"::NAMED then
            Error(NotNamedErr, MembershipSalesSetup."Membership Code");
    end;

    internal procedure ValidateMembershipForToken(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        ValidateMembershipForToken(EcomSalesLine, EcomSalesHeader, Membership, MembershipEntry);
    end;

    local procedure ValidateMembershipForToken(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; var Membership: Record "NPR MM Membership"; var MembershipEntry: Record "NPR MM Membership Entry")
    var
        MembershipNotFoundErr: Label 'Membership with Id %1 not found.';
        MembershipBlockedErr: Label 'Membership %1 is blocked.';
        QuantityErr: Label 'Membership line quantity must be 1.';
        AlreadyClaimedErr: Label 'Membership %1 is already linked to another document.', Comment = '%1=External Membership No.';
        MembershipEntryMissingErr: Label 'No active membership entry found for membership %1.';
    begin
        if EcomSalesLine.Quantity <> 1 then
            Error(QuantityErr);
        if not Membership.GetBySystemId(EcomSalesLine."Membership Id") then
            Error(MembershipNotFoundErr, EcomSalesLine."Membership Id");

        if Membership.Blocked then
            Error(MembershipBlockedErr, Membership."Entry No.");

        MembershipEntry.Reset();
        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetLoadFields("Document No.");
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        if not MembershipEntry.FindFirst() then
            Error(MembershipEntryMissingErr, Membership."Entry No.");

        if (MembershipEntry."Document No." <> '') and (MembershipEntry."Document No." <> EcomSalesHeader."External No.") then
            Error(AlreadyClaimedErr, Membership."External Membership No.");
    end;

    internal procedure GetMembershipSaleSetup(var MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup"; ItemNo: Code[20]): Boolean
    begin
        exit(MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, ItemNo));
    end;

    internal procedure ShowRelatedMembershipsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Membership: Record "NPR MM Membership";
        TempMembership: Record "NPR MM Membership" temporary;
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EmptyGuid: Guid;
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
        EcomSalesLine.SetFilter("Membership Id", '<>%1', EmptyGuid);
        EcomSalesLine.SetLoadFields("Membership Id");
        if EcomSalesLine.FindSet() then
            repeat
                if Membership.GetBySystemId(EcomSalesLine."Membership Id") then begin
                    TempMembership := Membership;
                    if TempMembership.Insert() then;
                end;
            until EcomSalesLine.Next() = 0;
        if not TempMembership.IsEmpty() then
            PAGE.Run(0, TempMembership);
    end;

    internal procedure ShowRelatedMembershipsAction(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        Membership: Record "NPR MM Membership";
    begin
        if IsNullGuid(EcomSalesLine."Membership Id") then
            exit;
        if not Membership.GetBySystemId(EcomSalesLine."Membership Id") then
            exit;
        Membership.SetRecFilter();
        Page.Run(Page::"NPR MM Membership Card", Membership);
    end;

    local procedure CreateMembershipPaymentMethods(EcomSalesHeader: Record "NPR Ecom Sales Header"; Membership: Record "NPR MM Membership")
    var
        TempPaymentLine: Record "NPR Magento Payment Line" temporary;
        PaymentLine: Record "NPR Magento Payment Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        UserAccountMgt: Codeunit "NPR UserAccountMgtImpl";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        UserAccount: Record "NPR UserAccount";
        NameParts: List of [Text];
    begin
        if EcomSalesHeader."Sell-to Email" = '' then
            exit;

        PaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        PaymentLine.SetFilter("Payment Token", '<>%1', '');
        PaymentLine.SetFilter("Payment Gateway Shopper Ref.", '<>%1', '');
        PaymentLine.SetFilter("Date Captured", '<>%1', 0D);
        PaymentLine.SetLoadFields("Payment Token", "Payment Gateway Shopper Ref.", "Payment Gateway Code", "Card Summary", "Expiry Date Text", "Payment Instrument Type", Brand, "Card Alias Token", "Masked PAN");
        if not PaymentLine.FindSet() then
            exit;

        repeat
            TempPaymentLine.Reset();
            TempPaymentLine.SetRange("Payment Token", PaymentLine."Payment Token");
            TempPaymentLine.SetRange("Payment Gateway Shopper Ref.", PaymentLine."Payment Gateway Shopper Ref.");
            if TempPaymentLine.IsEmpty() then begin
                TempPaymentLine.Init();
                TempPaymentLine := PaymentLine;
                TempPaymentLine.SystemId := PaymentLine.SystemId;
                TempPaymentLine.Insert();

                if not PaymentMethodMgt.FindMemberPaymentMethod(TempPaymentLine, MemberPaymentMethod) then begin
#pragma warning disable AA0139
                    if not UserAccountMgt.FindAccountByEmail(EcomSalesHeader."Sell-to Email".Trim().ToLower(), UserAccount) then begin
#pragma warning restore
                        UserAccount.Init();
                        UserAccount.EmailAddress := EcomSalesHeader."Sell-to Email";
                        if EcomSalesHeader."Sell-to Name" <> '' then begin
                            NameParts := EcomSalesHeader."Sell-to Name".Trim().Split(' ');
#pragma warning disable AA0139
                            if not (NameParts.Get(1, UserAccount.FirstName)) then;
                            if not (NameParts.Get(2, UserAccount.LastName)) then;
#pragma warning restore
                        end;
                        UserAccount.PhoneNo := EcomSalesHeader."Sell-to Phone No.";
                        UserAccountMgt.CreateAccount(UserAccount);
                    end;
                    PaymentMethodMgt.AddMemberPaymentMethod(UserAccount, TempPaymentLine, MemberPaymentMethod);
                end;

                PaymentMethodMgt.SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
                MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, true, false);
            end;
        until PaymentLine.Next() = 0;
    end;

    local procedure UpdateMembershipEntryAmounts(var MembershipEntry: Record "NPR MM Membership Entry"; EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        if EcomSalesHeader."Price Excl. VAT" then begin
            MembershipEntry.Amount := EcomSalesLine."Line Amount";
            MembershipEntry."Amount Incl VAT" := Round(EcomSalesLine."Line Amount" * (1 + EcomSalesLine."VAT %" / 100), 0.01);
        end else begin
            MembershipEntry."Amount Incl VAT" := EcomSalesLine."Line Amount";
            MembershipEntry.Amount := Round(EcomSalesLine."Line Amount" / (1 + EcomSalesLine."VAT %" / 100), 0.01);
        end;
    end;

    [TryFunction]
    local procedure TryCheckValidEmailAddress(_Email: Text)
    var
        MailManagement: Codeunit "Mail Management";
    begin
        MailManagement.CheckValidEmailAddresses(_Email);
    end;

    var
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
}
#endif
