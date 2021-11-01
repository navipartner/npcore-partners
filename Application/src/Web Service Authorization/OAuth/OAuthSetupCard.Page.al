page 6059773 "NPR OAuth Setup Card"
{

    Caption = 'OAuth Setup';
    PageType = Card;
    SourceTable = "NPR OAuth Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("AAD Tenant Id"; Rec."AAD Tenant Id")
                {
                    ToolTip = 'Specifies the value of the AAD Tenant Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Get Access Token URL"; Rec."Get Access Token URL")
                {
                    ToolTip = 'Specifies the value of the Access Token URL Path field';
                    ApplicationArea = NPRRetail;
                    MultiLine = true;
                }
                field(ClientId; ClientIdGlobal)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Client Id';
                    Tooltip = 'Specifies the CLient Id.';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        if ClientIdGlobal <> '' Then
                            Rec.SetSecret(Rec.FieldNo("Client ID"), ClientIdGlobal)
                        Else begin
                            if Rec.HasSecret(Rec.FieldNo("Client ID")) then
                                Rec.RemoveSecret(Rec.FieldNo("Client ID"));
                        end;
                    end;
                }

                field(ClientSecret; ClientSecretGlobal)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Client Secret';
                    Tooltip = 'Specifies the Client Secret.';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        if ClientSecretGlobal <> '' Then
                            Rec.SetSecret(Rec.FieldNo("Client Secret"), ClientSecretGlobal)
                        Else begin
                            if Rec.HasSecret(Rec.FieldNo("Client Secret")) then
                                Rec.RemoveSecret(Rec.FieldNo("Client Secret"));
                        end;
                    end;
                }
                field(Scope; Rec.Scope)
                {
                    ToolTip = 'Specifies the value of the Scope field';
                    ApplicationArea = NPRRetail;
                }
                field("Access Token Duration Offset"; Rec."Access Token Duration Offset")
                {
                    ToolTip = 'Specifies the value of the Access Token Duration Offset field';
                    ApplicationArea = NPRRetail;
                }
                field("Access Token Due DateTime"; Rec."Access Token Due DateTime")
                {
                    ToolTip = 'Specifies the value of the Access Token Due DateTime field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateToken)
            {
                Caption = 'Generate Token';
                ApplicationArea = NPRRetail;
                Image = CreateElectronicReminder;
                ToolTip = 'Generates a Token.';
                trigger OnAction()
                var
                begin
                    Rec.GetOauthToken();
                end;
            }

            action(ClearToken)
            {
                Caption = 'Clear Token';
                ApplicationArea = NPRRetail;
                Image = ClearLog;
                ToolTip = 'Clear an existing Token.';
                trigger OnAction()
                var
                begin
                    if not Rec.HasSecret(Rec.FieldNo("Access Token")) then
                        Error('Token does not exist.');
                    Rec.RemoveSecret(Rec.FieldNo("Access Token"));
                    Rec."Access Token Due DateTime" := 0DT;
                    Rec.Modify();
                end;
            }
        }

        area(Navigation)
        {
            action(ReadToken)
            {
                Caption = 'Read Token';
                ApplicationArea = NPRRetail;
                Image = GetEntries;
                ToolTip = 'Reads a Token.';
                trigger OnAction()
                var
                begin
                    Message(Rec.GetSecret(Rec.FieldNo("Access Token")));
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Get Access Token URL" := 'https://login.microsoftonline.com/{AadTenantId}/oauth2/v2.0/token';
        Rec.Scope := 'api://{ClientId}/.default';
    end;

    var
        [InDataSet]
        ClientIdGlobal: Text[200];
        [InDataSet]
        ClientSecretGlobal: Text[200];

    trigger OnAfterGetRecord()
    begin
        ClientIdGlobal := Rec.GetSecret(Rec.FieldNo("Client Id"));
        ClientSecretGlobal := Rec.GetSecret(Rec.FieldNo("Client Secret"));
    end;

}
