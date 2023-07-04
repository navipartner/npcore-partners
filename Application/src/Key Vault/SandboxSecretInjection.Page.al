page 6150806 "NPR Sandbox Secret Injection"
{
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Extensible = false;
    layout
    {
        area(Content)
        {
            field(SecretName; _SecretName)
            {
                ShowMandatory = true;
                Caption = 'Secret Name';
                ToolTip = 'The name of the secret you wish to inject in your sandbox';
                ApplicationArea = NPRRetail;
            }
            field(SecretValue; _SecretValue)
            {
                ShowMandatory = true;
                Caption = 'Secret Value';
                ToolTip = 'The value of the secret you wish to inject in your sandbox';
                ExtendedDatatype = Masked;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InjectSecret)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Inject Secret';
                ToolTip = 'Injects the secret you have filled out.';
                Image = Create;

                trigger OnAction()
                var
                    SandboxSecretInjection: Codeunit "NPR Sandbox Secret Injection";
                    MissingSecretValuesErr: Label 'Both name and value must be filled out to inject a secret';
                    SecretInjctedLbl: Label 'Secret injected in current environment successfully!';
                begin
                    if (_SecretName = '') or (_SecretValue = '') then
                        Error(MissingSecretValuesErr);

                    SandboxSecretInjection.AddSecret(_SecretName, _SecretValue);
                    Message(SecretInjctedLbl);
                    Clear(_SecretName);
                    Clear(_SecretValue);
                end;
            }
        }
    }

    var
        [NonDebuggable]
        _SecretName: Text;
        [NonDebuggable]
        _SecretValue: Text;
}