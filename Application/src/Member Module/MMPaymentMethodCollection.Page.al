page 6185043 "NPR MM PaymentMethodCollection"
{
    Extensible = false;
    PageType = ConfirmationDialog;
    InstructionalText = 'Please select the Payment Gateway';
    Caption = 'Collect Payment Method';
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

            field(PaymentGatewayCode; _PaymentGatewayCode)
            {
                Caption = 'Payment Gateway';
                ToolTip = 'Scpecify the payment gateway';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                trigger OnLookup(var Text: Text): Boolean
                var
                    SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
                    SubsPaymentGateways: Page "NPR MM Subs. Payment Gateways";
                begin
                    Clear(SubsPaymentGateways);
                    SubsPaymentGateway.SetRange(Status, SubsPaymentGateway.Status::Enabled);
                    If Page.RunModal(Page::"NPR MM Subs. Payment Gateways", SubsPaymentGateway) = Action::LookupOK then begin
                        _PaymentGatewayCode := SubsPaymentGateway.Code;
                        _PSP := SubsPaymentGateway."Integration Type";
                    end;
                end;
            }
            field(SetAutoRenew; _SetAutoRenew)
            {
                Caption = 'Set Membership to Auto-Renew';
                ToolTip = 'Specify the auto-renew status for the membership';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = not HideSetAutoRenew;
            }
        }
    }

    var
        _Membership: Record "NPR MM Membership";
        _SetAutoRenew: Boolean;
        _PaymentGatewayCode: Code[10];
        SubscrRenewRequest: Codeunit "NPR MM Subscr. Renew: Request";
        _PSP: Enum "NPR MM Subscription PSP";
        HideSetAutoRenew: Boolean;

    trigger OnOpenPage()
    var
        MemebrshipNotSelectedLbl: Label 'A membership must be selected.';
    begin
        if _Membership."Entry No." = 0 then
            Error(MemebrshipNotSelectedLbl);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        PaymentGatewayErr: Label 'You must specify a payment gateway before sending Pay By Link.';
    begin
        if CloseAction = Action::Yes then begin
            if _PaymentGatewayCode = '' then
                Error(PaymentGatewayErr);

            ProcessResponse(_Membership, _SetAutoRenew, _PSP);
        end;
        exit(true);
    end;

    internal procedure SetMembership(Membership: Record "NPR MM Membership")
    begin
        _Membership := Membership;
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::NO then
            HideSetAutoRenew := true;
    end;

    local procedure ProcessResponse(var Membership: Record "NPR MM Membership"; AutoRenewStatus: Boolean; PSP: Enum "NPR MM Subscription PSP")
    var
        Subscription: Record "NPR MM Subscription";
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Subscription.FindLast();
        SubscrRenewRequest.CreateSubscriptionPaymentMethodCollectionRequest(Subscription, PSP, SubscrPaymentRequest, AutoRenewStatus);
        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        SubscrPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, false, false);
    end;
}