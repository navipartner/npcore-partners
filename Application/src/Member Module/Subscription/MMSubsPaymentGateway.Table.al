table 6150961 "NPR MM Subs. Payment Gateway"
{
    Access = Internal;
    Caption = 'Subscriptions Payment Gateway';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM Subs. Payment Gateways";
    DrillDownPageId = "NPR MM Subs. Payment Gateways";


    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Integration Type"; Enum "NPR MM Subscription PSP")
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
            InitValue = Adyen;
        }

        field(4; Status; Enum "NPR MM Subs Pmt Gateway Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = Disabled;
            trigger OnValidate()
            begin
                if xRec.Status <> Rec.Status then
                    CheckStatus();

                if Rec."Integration Type" = Rec."Integration Type"::Adyen then begin
                    if Rec.Status = Rec.Status::Enabled then begin
                        CheckAdyenSetup();
                        CreateRefundWebhook();
                    end;
                    CreateRefundWebhookJob();
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
    trigger OnInsert()
    begin
        CheckStatus();
    end;

    trigger OnDelete()
    begin
        DeleteGatewaySetup();
    end;

    local procedure CheckStatus()
    var
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        GatewayAlreadyExistsLbl: Label 'There is an active subscription payment gateway for integration type %1 - Code = %2. Please disable it and try again. ', Comment = '%1 - Integration Type, %2 - Code';
    begin
        if Rec.Status <> Rec.Status::Enabled then
            exit;

        SubsPaymentGateway.Setfilter(Code, '<> %1', Rec.Code);
        SubsPaymentGateway.Setrange("Integration Type", REc."Integration Type");
        SubsPaymentGateway.SetRange(Status, SubsPaymentGateway.Status::Enabled);
        SubsPaymentGateway.SetloadFields(Code, "Integration Type", Status);
        if not SubsPaymentGateway.FindFirst() then
            exit;

        Error(GatewayAlreadyExistsLbl, SubsPaymentGateway."Integration Type", SubsPaymentGateway.Code);
    end;

    local procedure DeleteGatewaySetup()
    var
        ISubscrPaymentIHandler: Interface "NPR MM Subscr.Payment IHandler";
    begin
        ISubscrPaymentIHandler := Rec."Integration Type";
        ISubscrPaymentIHandler.DeleteSetupCard(Rec.Code);
    end;

    local procedure CheckAdyenSetup()
    var
        NPPaySetup: Record "NPR Adyen Setup";
    begin
        if not NPPaySetup.Get() then begin
            NPPaySetup.Init();
            NPPaySetup.Insert();
        end;

        if not NPPaySetup."Enable Reconciliation" then begin
            NPPaySetup.Validate("Enable Reconciliation", true);
            NPPaySetup.Modify();
        end;
    end;

    local procedure CreateRefundWebhook()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        RefundEventFilter: Label 'REFUND', Locked = true;
        AdyenWebhookType: Enum "NPR Adyen Webhook Type";
        MMSubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        if MMSubsAdyenPGSetup.Get(Rec.Code) then
            If not WebhookExist(MMSubsAdyenPGSetup."Merchant Name", RefundEventFilter) then begin
                AdyenManagement.InitWebhookSetup(WebhookSetup, RefundEventFilter, MMSubsAdyenPGSetup."Merchant Name", AdyenWebhookType::standard);
                AdyenManagement.CreateWebhook(WebhookSetup);
            end;
    end;

    local procedure WebhookExist(MerchantName: Text[50]; RefundEventFilter: Text) WebhookExist: Boolean
    var
        AdyenWebhookSetup: Record "NPR Adyen Webhook Setup";
        LikeFilterLbl: Label '*%1*', Locked = true;
    begin
        AdyenWebhookSetup.SetRange(Active, true);
        AdyenWebhookSetup.SetRange("Merchant Account", MerchantName);
        AdyenWebhookSetup.SetRange(Type, AdyenWebhookSetup.Type::standard);
        AdyenWebhookSetup.SetFilter("Include Events Filter", '%1', StrSubstNo(LikeFilterLbl, RefundEventFilter));
        WebhookExist := not AdyenWebhookSetup.IsEmpty;
    end;

    local procedure CreateRefundWebhookJob()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        ProccessRefundStatus: Label 'Process Refund Status for Adyen';
    begin
        If Rec.Status = Rec.Status::Enabled then
            AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen Refund Status JQ", ProccessRefundStatus, 1, 30) //Reschedule to run again in 30 seconds on error

    end;
}
