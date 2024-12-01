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
}
