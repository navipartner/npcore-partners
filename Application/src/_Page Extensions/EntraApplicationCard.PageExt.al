pageextension 6014534 "NPR Entra Application Card" extends "AAD Application Card"
{
    actions
    {
        addlast(Processing)
        {
            group("NPR Entra App Management")
            {
                Caption = 'Entra Application Management';
                Image = WarehouseSetup;

                action("NPR Regenerate Entra App Secret")
                {
                    Caption = 'Regenerate Entra Application Secret';
                    ToolTip = 'The action regenerates Microsoft Entra Application Secret and displays the new secret on the screen.';
                    ApplicationArea = NPRRetail;
                    Image = EncryptionKeys;
                    Ellipsis = true;

                    trigger OnAction()
                    begin
                        RegenerateEntraAppSecret();
                    end;
                }
            }
        }
    }

    local procedure RegenerateEntraAppSecret()
    var
        AadApplicationMgt: Codeunit "NPR AAD Application Mgt.";
    begin
        AadApplicationMgt.RegenerateEntraAppSecret(Rec, true);
    end;
}