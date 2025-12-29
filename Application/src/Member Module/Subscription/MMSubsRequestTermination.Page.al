page 6185077 "NPR MM SubsRequestTermination"
{
    Extensible = false;
    PageType = ConfirmationDialog;
    InstructionalText = 'Please fill out the info to terminate subscription.';
    Caption = 'Request Termination';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("External Membership No."; _Membership."External Membership No.")
            {
                Caption = 'External Membership No.';
                ToolTip = 'The external membership no.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
            }
            field(Description; _Membership.Description)
            {
                Caption = 'Description';
                ToolTip = 'The description of the membership';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
            }
            field(TerminationDate; _TerminationDate)
            {
                Caption = 'Termination Date';
                ToolTip = 'The date to terminate the subscription';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnValidate()
                begin
                    CheckRefundAvailable();
                    CalculateRefundPrice();
                end;
            }
            field(TerminationReason; _TerminationReason)
            {
                Caption = 'Termination Reason';
                ToolTip = 'The date to terminate the subscription';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            group(RefundNotAvailbleGrp)
            {
                Caption = 'Error Message';
                Visible = (not _RefundAvailable);

                field(RefundNotAvailable; _RefundNotAvailable)
                {
                    ShowCaption = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Style = Unfavorable;
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(Refund)
            {
                Caption = 'Refund';
                Visible = _RefundAvailable;

                field(RefundRemaining; _RefundRemaining)
                {
                    Caption = 'Cancel and Refund Remaining';
                    ToolTip = 'If enabled, the system will cancel the membership on the termination and refund according to the rule.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = _RefundAvailable;
                }
                field(NoPaymentRequestWarning; _NoPaymentRequest)
                {
                    ShowCaption = false;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Style = Ambiguous;
                    Editable = false;
                    MultiLine = true;
                    Visible = (_NoPaymentRequest <> '');
                }
                field(RefundItemNoFld; _RefundItemNo)
                {
                    Caption = 'Refund Item No.';
                    ToolTip = 'Specifies which item no. and alteration configuration will be used to cancel the membership.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = _RefundAvailable;
                    ShowMandatory = (_RefundRemaining);

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AlterationSetup: Record "NPR MM Members. Alter. Setup";
                        AlterationSetupPage: Page "NPR MM Membership Alter.";
                    begin
                        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::CANCEL);
                        AlterationSetup.SetRange("From Membership Code", _Membership."Membership Code");
                        AlterationSetup.SetRange("Alteration Activate From", AlterationSetup."Alteration Activate From"::ASAP);

                        AlterationSetupPage.LookupMode := true;
                        AlterationSetupPage.SetTableView(AlterationSetup);
                        if (AlterationSetupPage.RunModal() <> Action::LookupOK) then
                            exit;

                        AlterationSetupPage.GetRecord(AlterationSetup);
                        _RefundItemNo := AlterationSetup."Sales Item No.";
                        _RefundItemDescription := AlterationSetup.Description;

                        // OnValidate() trigger is not triggered after a lookup.
                        CalculateRefundPrice();
                    end;

                    trigger OnValidate()
                    var
                        AlterationSetup: Record "NPR MM Members. Alter. Setup";
                    begin
                        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::CANCEL);
                        AlterationSetup.SetRange("From Membership Code", _Membership."Membership Code");
                        AlterationSetup.SetRange("Alteration Activate From", AlterationSetup."Alteration Activate From"::ASAP);
                        AlterationSetup.SetRange("Sales Item No.", _RefundItemNo);
                        AlterationSetup.FindFirst();

                        CalculateRefundPrice();
                    end;
                }
                field(RefundItemDescription; _RefundItemDescription)
                {
                    Caption = 'Refund Item Description';
                    ToolTip = 'Specifies the description of the item that will be used to cancel the membership.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }
                field(RefundPriceFld; _RefundPrice)
                {
                    Caption = 'Refund Price';
                    ToolTip = 'Specifies the price that will be refunded to the associated card.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }
                field(MemberPaymentMethodPSP; _MemberPaymentMethod.PSP)
                {
                    Caption = 'PSP';
                    ToolTip = 'Specifies the payment service provider of the member payment method.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }
                field(MemberPaymentMethodBrand; _MemberPaymentMethod."Payment Brand")
                {
                    Caption = 'Payment Brand';
                    ToolTip = 'Specifies the payment method brand of the member payment method.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }
                field(MemberPaymentMethodMaskedPAN; _MemberPaymentMethod."Masked PAN")
                {
                    Caption = 'Masked PAN';
                    ToolTip = 'Specifies the masked PAN of the member payment method.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }
                field(MemberPaymentMethodExpiryDate; _MemberPaymentMethod."Expiry Date")
                {
                    Caption = 'Expiry Date';
                    ToolTip = 'Specifies the expiry date of the member payment method.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Editable = false;
                }
            }
        }
    }

    var
        _Subscription: Record "NPR MM Subscription";
        _Membership: Record "NPR MM Membership";
        _MemberPaymentMethod: Record "NPR MM Member Payment Method";
        _MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        _TerminationDate: Date;
        _TerminationReason: Enum "NPR MM Subs Termination Reason";
        _RefundAvailable, _RefundRemaining : Boolean;
        _RefundItemNo: Code[20];
        _RefundItemDescription: Text[100];
        _RefundPrice: Decimal;
        _RefundNotAvailable: Text;
        _NoPaymentRequest: Text;

    trigger OnOpenPage()
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipNotSelectedLbl: Label 'A membership must be selected.';
        RefundNotAvailableLbl: Label 'The required configuration to cancel the membership is not present and therefore a refund cannot be executed automatically.';
        NoPaymentRequestRefundMayNotWorkLbl: Label 'This subscription is yet to be renewed automatically or all existing payments has previously been refunded. Some payment service providers do not allow unreferenced refunds and therefore the refund will fail later on.';
    begin
        if _Membership."Entry No." = 0 then
            Error(MembershipNotSelectedLbl);

        if (not SubscriptionMgtImpl.GetEarliestTerminationDate(_Membership, _TerminationDate)) then
            Clear(_TerminationDate);

        SelectSuggestedItemNo();

        SubscriptionRequest.SetRange("Subscription Entry No.", _Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Renew);
        SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Success);
        SubscriptionRequest.SetRange(Reversed, false);
        if (SubscriptionRequest.IsEmpty()) then
            _NoPaymentRequest := NoPaymentRequestRefundMayNotWorkLbl;

        _RefundNotAvailable := RefundNotAvailableLbl;

        _TerminationReason := _TerminationReason::CUSTOMER_INITIATED;

        if PaymentMethodMgt.TryGetMemberPaymentMethod(_Subscription, false, _MemberPaymentMethod) then;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::Yes then
            ProcessResponse(_Membership, _TerminationDate, _TerminationReason, _RefundItemNo, _RefundPrice);
        exit(true);
    end;

    internal procedure SetMembership(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription")
    begin
        if (Membership."Entry No." <> Subscription."Membership Entry No.") then
            Error('Subscription and provided membership do not match. This is a programming bug. Contact system vendor!');

        _Membership := Membership;
        _Subscription := Subscription;
    end;

    local procedure ProcessResponse(var Membership: Record "NPR MM Membership"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason"; RefundItemNo: Code[20]; RefundPrice: Decimal)
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        SubscriptionReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        Subscription: Record "NPR MM Subscription";
        TerminationRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionMgtImpl.RequestTermination(Membership, RequestedDate, Reason, TerminationRequest);

        if (_RefundRemaining) then begin
            Subscription.Get(_Subscription."Entry No.");
            SubscriptionReversalMgt.RequestPartialRefund(Subscription, Membership, RefundItemNo, RequestedDate, RefundPrice, TerminationRequest);
        end;
    end;

    local procedure SelectSuggestedItemNo()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        RefundAvailable: Boolean;
    begin
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::CANCEL);
        AlterationSetup.SetRange("From Membership Code", _Membership."Membership Code");
        AlterationSetup.SetRange("Alteration Activate From", AlterationSetup."Alteration Activate From"::ASAP);
        if (AlterationSetup.FindSet()) then
            repeat
                _RefundItemNo := AlterationSetup."Sales Item No.";
                _RefundItemDescription := AlterationSetup.Description;
                RefundAvailable := CheckRefundAvailable();
            until (AlterationSetup.Next() = 0) or (RefundAvailable);

        if (not RefundAvailable) then begin
            Clear(_RefundItemNo);
            Clear(_RefundItemDescription);
        end;

        _RefundAvailable := RefundAvailable;
    end;

    local procedure CheckRefundAvailable() RefundAvailable: Boolean
    var
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        StartDateNew, EndDateNew : Date;
    begin
        InitMemberInfoCapture(TempMemberInfoCapture);
        RefundAvailable := _MembershipMgt.CancelMembership(TempMemberInfoCapture, false, false, StartDateNew, EndDateNew, _RefundPrice);
    end;

    local procedure CalculateRefundPrice()
    var
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        StartDate, EndDate : Date;
    begin
        InitMemberInfoCapture(TempMemberInfoCapture);

        if (not _MembershipMgt.CancelMembership(
            TempMemberInfoCapture,
            false,
            false,
            StartDate,
            EndDate,
            _RefundPrice
        )) then
            Clear(_RefundPrice);
    end;

    local procedure InitMemberInfoCapture(var TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary)
    begin
        TempMemberInfoCapture.Init();
        TempMemberInfoCapture."Membership Entry No." := _Membership."Entry No.";
        TempMemberInfoCapture."Item No." := _RefundItemNo;
        TempMemberInfoCapture."Information Context" := TempMemberInfoCapture."Information Context"::CANCEL;
        TempMemberInfoCapture."Document Date" := _TerminationDate;
    end;
}