#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248527 "NPR EcomCreateMMShipImpl"
{
    Access = Internal;

    internal procedure Process(var EcomSalesLine: Record "NPR Ecom Sales Line") Success: Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomMembershipOperation: Enum "NPR Ecom Membership Operation";
        Sentry: Codeunit "NPR Sentry";
        SentrySpan: Codeunit "NPR Sentry Span";
        OperationName: Text;
        NoOperationErr: Label 'The operation to be performed on the membership could not be determined for line %1. Check that membershipId and operationId are correctly provided for the line and try again.', Comment = '%1 - line number', Locked = true;
        UnknownOperationErr: Label 'Unknown membership operation for line %1.', Comment = '%1 - line number', Locked = true;
    begin
        EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
        CheckIfLineCanBeProcessed(EcomSalesLine, EcomSalesHeader);

        EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
        EcomSalesLine.Get(EcomSalesLine.RecordId);

        EcomMembershipOperation := DetermineMembershipOperation(EcomSalesLine);
        if (EcomSalesLine."Membership Operation" <> EcomMembershipOperation) then begin
            EcomSalesLine."Membership Operation" := EcomMembershipOperation;
            EcomSalesLine.Modify();
        end;

        OperationName := EcomSalesLine."Membership Operation".Names.Get(EcomSalesLine."Membership Operation".Ordinals.IndexOf(EcomSalesLine."Membership Operation".AsInteger())).ToLower().replace(' ', '');
        Sentry.StartSpan(SentrySpan, 'bc.e-com.membership.process.' + OperationName);

        case EcomSalesLine."Membership Operation" of
            EcomMembershipOperation::NoOperationSelected:
                begin
                    SentrySpan.Finish();
                    Error(NoOperationErr, EcomSalesLine."Line No.");
                end;

            EcomMembershipOperation::CreateMembership:
                begin
                    CreateMembership(EcomSalesLine, EcomSalesHeader);
                    _EcomVirtualItemEvents.OnAfterMembershipCreatedBeforeCommit(EcomSalesLine);
                    ConfirmMembership(EcomSalesLine, EcomSalesHeader);
                    _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
                end;
            EcomMembershipOperation::ConfirmMembership:
                begin
                    ConfirmMembership(EcomSalesLine, EcomSalesHeader);
                    _EcomVirtualItemEvents.OnAfterMembershipConfirmedBeforeCommit(EcomSalesLine);
                end;

            EcomMembershipOperation::RenewMembership:
                begin
                    ProcessMembershipAlteration(EcomSalesLine, EcomSalesHeader);
                    _EcomVirtualItemEvents.OnAfterMembershipRenewedBeforeCommit(EcomSalesLine);
                end;

            EcomMembershipOperation::ExtendMembership:
                begin
                    ProcessMembershipAlteration(EcomSalesLine, EcomSalesHeader);
                    _EcomVirtualItemEvents.OnAfterMembershipExtendedBeforeCommit(EcomSalesLine);
                end;

            EcomMembershipOperation::UpgradeMembership:
                begin
                    ProcessMembershipAlteration(EcomSalesLine, EcomSalesHeader);
                    _EcomVirtualItemEvents.OnAfterMembershipUpgradedBeforeCommit(EcomSalesLine);
                end;

            else begin
                SentrySpan.Finish();
                Error(UnknownOperationErr, EcomSalesLine."Line No.");
            end;

        end;

        SentrySpan.Finish();
        exit(true);
    end;


    internal procedure DetermineMembershipOperation(EcomSalesLine: Record "NPR Ecom Sales Line") EcomMembershipOperation: Enum "NPR Ecom Membership Operation"
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        if (EcomSalesLine.Subtype <> EcomSalesLine.Subtype::Membership) then
            exit(EcomMembershipOperation::NoOperationSelected);

        if (IsNullGuid(EcomSalesLine."Membership Id")) then
            exit(EcomMembershipOperation::CreateMembership);

        if (IsMembershipCreateItem(EcomSalesLine)) then
            exit(EcomMembershipOperation::ConfirmMembership);

        if (not IsNullGuid(EcomSalesLine."Alteration Option System Id")) then begin
            if (not MembershipAlterationSetup.GetBySystemId(EcomSalesLine."Alteration Option System Id")) then
                exit(EcomMembershipOperation::NoOperationSelected);

            if (MembershipAlterationSetup."Alteration Type" = MembershipAlterationSetup."Alteration Type"::RENEW) then
                exit(EcomMembershipOperation::RenewMembership);

            if (MembershipAlterationSetup."Alteration Type" = MembershipAlterationSetup."Alteration Type"::UPGRADE) then
                exit(EcomMembershipOperation::UpgradeMembership);

            if (MembershipAlterationSetup."Alteration Type" = MembershipAlterationSetup."Alteration Type"::EXTEND) then
                exit(EcomMembershipOperation::ExtendMembership);
        end;

        exit(EcomMembershipOperation::NoOperationSelected);
    end;


    local procedure IsMembershipCreateItem(EcomSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ItemNoCode: Code[20];
    begin
        ItemNoCode := GetItemNoAsCode20(EcomSalesLine);
        if (not GetMembershipSaleSetup(MembershipSalesSetup, ItemNoCode)) then
            exit(false);

        exit(MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
    end;


    internal procedure CheckIfLineCanBeProcessed(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        if EcomSalesLine.Subtype <> EcomSalesLine.Subtype::Membership then
            EcomSalesLine.FieldError(Subtype);

        if not EcomSalesLine.Captured then
            EcomSalesLine.FieldError(Captured);

        if (EcomSalesLine.Quantity <> 1) then
            EcomSalesLine.FieldError(Quantity);

        if EcomSalesLine."Document Type" = EcomSalesLine."Document Type"::"Return Order" then
            EcomSalesLine.FieldError("Document Type");

        if EcomSalesLine."Virtual Item Process Status" = EcomSalesLine."Virtual Item Process Status"::Processed then
            EcomSalesLine.FieldError(EcomSalesLine."Virtual Item Process Status");

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
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Item No." := GetItemNoAsCode20(EcomSalesLine);
        MemberInfoCapture."Import Entry Document ID" := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(MemberInfoCapture."Import Entry Document ID"));
        MemberInfoCapture.Insert();

        UpdateMemberInfoCaptureFromLine(MemberInfoCapture, EcomSalesLine);
        SetNotificationMethod(MemberInfoCapture);
        MemberInfoCapture.Modify();

        GetMembershipSaleSetup(MembershipSalesSetup, GetItemNoAsCode20(EcomSalesLine));
        MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);

        // TODO - Wrong cardinality. Multiple sales interact with the membership over time.
        // Field will be removed
        Membership.Get(MemberInfoCapture."Membership Entry No.");
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine.Modify();
        MemberInfoCapture.Delete();
    end;

    internal procedure ProcessMembershipAlteration(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        ReshapeMembershipDuration(EcomSalesLine, EcomSalesHeader);
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
        _EcomVirtualItemEvents.OnAfterUpdateMemberInfoCaptureFromLine(MemberInfoCapture);
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

    internal procedure ValidateMembershipOperation(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        NoOperationErr: Label 'Membership operation is not selected for line %1.', Comment = '%1 = line no.';
        MissingOperationIdErr: Label 'Missing or invalid membership operation.';
    begin
        case EcomSalesLine."Membership Operation" of
            EcomSalesLine."Membership Operation"::NoOperationSelected:
                Error(NoOperationErr, EcomSalesLine."Line No.");
            EcomSalesLine."Membership Operation"::CreateMembership:
                EcomCreateMMShipImpl.ValidateMembershipRequestForDirectCreation(EcomSalesLine);
            // TODO - function name! Decide how to handle a not yet paid membership. This is an order after all!
            // Currently the create membership is creating the membership time entry regardless.
            EcomSalesLine."Membership Operation"::ConfirmMembership:
                EcomCreateMMShipImpl.ValidateMembershipForToken(EcomSalesLine, EcomSalesHeader);
            EcomSalesLine."Membership Operation"::RenewMembership,
            EcomSalesLine."Membership Operation"::ExtendMembership,
            EcomSalesLine."Membership Operation"::UpgradeMembership:
                EcomCreateMMShipImpl.ValidateMembershipAlterationRequest(EcomSalesLine, EcomSalesHeader);
            else
                Error(MissingOperationIdErr);
        end;
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
        DistributedMembershipHandler: Codeunit "NPR MM NPR Membership";
        ItemNotMembershipErr: Label 'Item %1 is not set up as a membership sale item.', Comment = '%1=Item No.', Locked = true;
        ForeignMembershipErr: Label 'Membership for an external membership community cannot be created here. Use the Membership APIs.', Locked = true;
        BusinessFlowTypeErr: Label 'Membership item is not set up as Membership Business Flow Type. Use the Membership APIs.', Locked = true;
    begin
        if not GetMembershipSaleSetup(MembershipSalesSetup, ItemNoCode) then
            Error(ItemNotMembershipErr, EcomSalesLine."No.");

        if DistributedMembershipHandler.IsForeignMembershipCommunity(MembershipSalesSetup."Membership Code") then
            Error(ForeignMembershipErr);

        if MembershipSalesSetup."Business Flow Type" <> MembershipSalesSetup."Business Flow Type"::MEMBERSHIP then
            Error(BusinessFlowTypeErr);
    end;

    local procedure ValidateMembershipSetup(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MembershipSetup: Record "NPR MM Membership Setup")
    var
        NotIndividualTypeErr: Label 'Membership %1 is not of type Individual and cannot be created via ecommerce.', Comment = '%1=Membership Code', Locked = true;
        NotNamedErr: Label 'Membership %1 does not require named member information and cannot be created via ecommerce.', Comment = '%1=Membership Code', Locked = true;
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

    internal procedure ValidateMembershipAlterationRequest(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        DocumentDate: Date;
        StartDateNew: Date;
        EndDateNew: Date;
        CardEntryNo: Integer;
        ExternalCardNo: Text[100];
        ReasonText: Text;
        MembershipNotFoundErr: Label 'Membership with Id %1 not found.', Locked = true;
        MembershipBlockedErr: Label 'Membership %1 is blocked.', Locked = true;
        AlterationSetupNotFoundErr: Label 'Membership alteration option %1 not found.', Locked = true;
        AlterationSetupMismatchErr: Label 'Membership alteration option %1 is not valid for membership type %2.', Comment = '%1=Alteration Option SystemId, %2=Membership Code', Locked = true;
        AlterationNotAvailableViaWebServiceErr: Label 'Membership alteration option %1 is not available via web service.', Locked = true;
        AlterationItemMismatchErr: Label 'Item %1 does not match the sales item %2 configured for membership alteration option %3.', Comment = '%1=Line Item No., %2=Setup Sales Item No., %3=Alteration Option SystemId', Locked = true;
        MembershipEntryNotFoundErr: Label 'No active membership entry found for membership %1.', Comment = '%1=External Membership No.', Locked = true;
        MembershipNotActivatedErr: Label 'Membership %1 must be activated before it can be altered.', Comment = '%1=External Membership No.', Locked = true;
        GracePeriodErr: Label 'Membership is outside the grace period for alteration type %1.', Comment = '%1=Alteration Type', Locked = true;
    begin
        if not Membership.GetBySystemId(EcomSalesLine."Membership Id") then
            Error(MembershipNotFoundErr, EcomSalesLine."Membership Id");

        if Membership.Blocked then
            Error(MembershipBlockedErr, Membership."Entry No.");

        if not MembershipAlterationSetup.GetBySystemId(EcomSalesLine."Alteration Option System Id") then
            Error(AlterationSetupNotFoundErr, EcomSalesLine."Alteration Option System Id");

        if MembershipAlterationSetup."From Membership Code" <> Membership."Membership Code" then
            Error(AlterationSetupMismatchErr, EcomSalesLine."Alteration Option System Id", Membership."Membership Code");

        if MembershipAlterationSetup."Not Available Via Web Service" then
            Error(AlterationNotAvailableViaWebServiceErr, EcomSalesLine."Alteration Option System Id");

        if EcomSalesLine."No." <> MembershipAlterationSetup."Sales Item No." then
            Error(AlterationItemMismatchErr, EcomSalesLine."No.", MembershipAlterationSetup."Sales Item No.", EcomSalesLine."Alteration Option System Id");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if not MembershipEntry.FindLast() then
            Error(MembershipEntryNotFoundErr, Membership."External Membership No.");

        if MembershipEntry."Activate On First Use" then
            Error(MembershipNotActivatedErr, Membership."External Membership No.");

        DocumentDate := ResolveAlterationDocumentDate(EcomSalesHeader);

        if not MembershipMgtInternal.ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, DocumentDate) then
            Error(GracePeriodErr, MembershipAlterationSetup."Alteration Type");

        case MembershipAlterationSetup."Alteration Type" of
            MembershipAlterationSetup."Alteration Type"::RENEW:
                ValidateRenewRestrictions(MembershipEntry, MembershipAlterationSetup, Membership."Entry No.", StartDateNew, EndDateNew);
            MembershipAlterationSetup."Alteration Type"::EXTEND:
                ValidateExtendRestrictions(MembershipEntry, MembershipAlterationSetup, DocumentDate, Membership."Entry No.", StartDateNew, EndDateNew);
            MembershipAlterationSetup."Alteration Type"::UPGRADE:
                ValidateUpgradeRestrictions(MembershipEntry, MembershipAlterationSetup, DocumentDate, Membership."External Membership No.", StartDateNew, EndDateNew);
        end;

        if (MembershipAlterationSetup."Alteration Type" = MembershipAlterationSetup."Alteration Type"::UPGRADE) or (MembershipAlterationSetup."To Membership Code" <> '') then
            if not MembershipMgtInternal.ValidateChangeMembershipCode(false, Membership."Entry No.", MembershipAlterationSetup."To Membership Code", ReasonText) then
                Error(ReasonText);

        if not MembershipMgtInternal.CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, DocumentDate, StartDateNew, EndDateNew, ReasonText) then
            Error(ReasonText);

        if not MembershipMgtInternal.CheckExtendMemberCards(false, Membership."Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, ExternalCardNo, CardEntryNo, ReasonText) then
            Error(ReasonText);
    end;

    local procedure ResolveAlterationDocumentDate(EcomSalesHeader: Record "NPR Ecom Sales Header"): Date
    begin
        if EcomSalesHeader."Received Date" <> 0D then
            exit(EcomSalesHeader."Received Date");
        exit(Today());
    end;

    local procedure ValidateRenewRestrictions(var MembershipEntry: Record "NPR MM Membership Entry"; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MembershipNo: Integer; var StartDateNew: Date; var EndDateNew: Date)
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        LedgerEntryNo: Integer;
        ConflictingEntryErr: Label 'New membership period %1..%2 conflicts with the existing one.', Comment = '%1=Start Date, %2=End Date', Locked = true;
        StackingNotAllowedErr: Label 'Stacking membership %1 on %2 is not allowed by alteration setup.', Comment = '%1=Membership Entry No., %2=Date', Locked = true;
    begin
        if (MembershipAlterationSetup."Alteration Activate From" <> MembershipAlterationSetup."Alteration Activate From"::B2B) then
            if (MembershipEntry."Valid Until Date" < Today) then
                MembershipEntry."Valid Until Date" := CalcDate('<-1D>', Today);

        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP,
            MembershipAlterationSetup."Alteration Activate From"::B2B:
                StartDateNew := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
            MembershipAlterationSetup."Alteration Activate From"::DF:
                StartDateNew := CalcDate(MembershipAlterationSetup."Alteration Date Formula", MembershipEntry."Valid Until Date");
        end;

        if (MembershipAlterationSetup."Alteration Activate From" <> MembershipAlterationSetup."Alteration Activate From"::B2B) then
            if (StartDateNew < Today) then
                StartDateNew := Today();

        EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        if (StartDateNew <= MembershipEntry."Valid Until Date") then
            Error(ConflictingEntryErr, StartDateNew, EndDateNew);

        if not MembershipAlterationSetup."Stacking Allowed" then
            if MembershipMgtInternal.GetLedgerEntryForDate(MembershipNo, Today, LedgerEntryNo) then
                if LedgerEntryNo <> MembershipEntry."Entry No." then
                    Error(StackingNotAllowedErr, MembershipNo, Today);
    end;

    local procedure ValidateExtendRestrictions(MembershipEntry: Record "NPR MM Membership Entry"; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; DocumentDate: Date; MembershipNo: Integer; var StartDateNew: Date; var EndDateNew: Date)
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        StartDateLedgerEntryNo: Integer;
        EndDateLedgerEntryNo: Integer;
        InvalidActivationDateErr: Label 'Activation option %1 (%2) is not supported for alteration type %3.', Comment = '%1=Activate From, %2=FieldCaption, %3=Alteration Type', Locked = true;
        ConflictingEntryErr: Label 'New membership period %1..%2 conflicts with the existing one.', Comment = '%1=Start Date, %2=End Date', Locked = true;
        ExtendToShortErr: Label 'Extending the membership to %1 would shorten it below the current end date %2.', Comment = '%1=New End Date, %2=Current End Date', Locked = true;
        MultipleTimeframesErr: Label 'Alteration %1 on membership %2 (%3..%4) spans multiple existing ledger entries (%5, %6).', Comment = '%1=Alteration Type, %2=Membership Entry No., %3=Start, %4=End, %5=Start Entry No., %6=End Entry No.', Locked = true;
    begin
        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                StartDateNew := DocumentDate;
            MembershipAlterationSetup."Alteration Activate From"::DF:
                StartDateNew := CalcDate(MembershipAlterationSetup."Alteration Date Formula", DocumentDate);
            else
                Error(InvalidActivationDateErr, Format(MembershipAlterationSetup."Alteration Activate From"),
                    MembershipAlterationSetup.FieldCaption("Alteration Activate From"), Format(MembershipAlterationSetup."Alteration Type"));
        end;

        EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        if (StartDateNew <= MembershipEntry."Valid From Date") then
            Error(ConflictingEntryErr, StartDateNew, EndDateNew);

        if (EndDateNew < MembershipEntry."Valid Until Date") then
            Error(ExtendToShortErr, EndDateNew, MembershipEntry."Valid Until Date");

        if MembershipMgtInternal.ConflictingLedgerEntries(MembershipNo, StartDateNew, EndDateNew, StartDateLedgerEntryNo, EndDateLedgerEntryNo) then
            Error(MultipleTimeframesErr, MembershipAlterationSetup."Alteration Type", MembershipNo, StartDateNew, EndDateNew, StartDateLedgerEntryNo, EndDateLedgerEntryNo);
    end;

    local procedure ValidateUpgradeRestrictions(MembershipEntry: Record "NPR MM Membership Entry"; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; DocumentDate: Date; ExternalMembershipNo: Code[20]; var StartDateNew: Date; var EndDateNew: Date)
    var
        InvalidActivationDateErr: Label 'Activation option %1 (%2) is not supported for alteration type %3.', Comment = '%1=Activate From, %2=FieldCaption, %3=Alteration Type', Locked = true;
        MembershipEntryMissingErr: Label 'No active membership entry found for membership %1 on the upgrade date.', Comment = '%1=External Membership No.', Locked = true;
        ConflictingEntryErr: Label 'Upgrade start date %1 precedes the current membership entry start date (%2..).', Comment = '%1=Start Date, %2=Valid From Date', Locked = true;
    begin
        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                StartDateNew := DocumentDate;
            else
                Error(InvalidActivationDateErr, Format(MembershipAlterationSetup."Alteration Activate From"),
                    MembershipAlterationSetup.FieldCaption("Alteration Activate From"), Format(MembershipAlterationSetup."Alteration Type"));
        end;

        EndDateNew := MembershipEntry."Valid Until Date";
        if MembershipAlterationSetup."Upgrade With New Duration" then
            EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        if (MembershipEntry."Valid Until Date" < StartDateNew) then
            Error(MembershipEntryMissingErr, ExternalMembershipNo);

        if (StartDateNew < MembershipEntry."Valid From Date") then
            Error(ConflictingEntryErr, StartDateNew, MembershipEntry."Valid From Date");
    end;

    internal procedure GetMembershipSaleSetup(var MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup"; ItemNo: Code[20]): Boolean
    begin
        exit(MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, ItemNo));
    end;

    internal procedure ShowRelatedMembershipsAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        TempMembership: Record "NPR MM Membership" temporary;
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

    local procedure ReshapeMembershipDuration(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Membership: Record "NPR MM Membership";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";

        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        UnitPrice: Decimal;
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        Membership.GetBySystemId(EcomSalesLine."Membership Id");
        MembershipAlterationSetup.GetBySystemId(EcomSalesLine."Alteration Option System Id");

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::SALESHEADER;
        MemberInfoCapture."Document Type" := MemberInfoCapture."Document Type"::"1";
        MemberInfoCapture."Document No." := EcomSalesHeader."External No.";
        MemberInfoCapture."Document Line No." := EcomSalesLine."Line No.";

        if (EcomSalesHeader."Price Excl. VAT") then begin
            // TODO   MemberInfoCapture."Unit Price" := EcomSalesLine."Unit Price";
            MemberInfoCapture.Amount := EcomSalesLine."Line Amount";
            MemberInfoCapture."Amount Incl VAT" := Round(EcomSalesLine."Line Amount" * (1 + EcomSalesLine."VAT %" / 100), 0.01);
        end else begin
            MemberInfoCapture."Amount Incl VAT" := EcomSalesLine."Line Amount";
            //  TODO MemberInfoCapture."Unit Price" := EcomSalesLine."Unit Price"; 
            MemberInfoCapture.Amount := Round(EcomSalesLine."Line Amount" / (1 + EcomSalesLine."VAT %" / 100), 0.01);
        end;

        MemberInfoCapture."Document Date" := Today();
        if (EcomSalesHeader."Received Date" <> 0D) then
            MemberInfoCapture."Document Date" := EcomSalesHeader."Received Date";

        MemberInfoCapture."Import Entry Document ID" := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(MemberInfoCapture."Import Entry Document ID"));

        // Fill in the member info capture record with the relevant info for processing the alteration
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
        case MembershipAlterationSetup."Alteration Type" of
            MembershipAlterationSetup."Alteration Type"::RENEW:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
            MembershipAlterationSetup."Alteration Type"::UPGRADE:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
            MembershipAlterationSetup."Alteration Type"::EXTEND:
                MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
        end;
        MemberInfoCapture.Insert(); // Gets me the auto-increment Entry No. for tracking purposes

        // Execute the alteration logic
        case MemberInfoCapture."Information Context" of
            MemberInfoCapture."Information Context"::RENEW:
                MembershipManagement.RenewMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

            MemberInfoCapture."Information Context"::UPGRADE:
                MembershipManagement.UpgradeMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

            MemberInfoCapture."Information Context"::EXTEND:
                MembershipManagement.ExtendMembership(MemberInfoCapture, true, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
        end;

        MemberInfoCapture.Delete();
    end;

    [TryFunction]
    local procedure TryCheckValidEmailAddress(_Email: Text)
    var
        MailManagement: Codeunit "Mail Management";
    begin
        MailManagement.CheckValidEmailAddresses(_Email);
    end;

    var
        _EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
}
#endif
