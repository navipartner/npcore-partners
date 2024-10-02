pageextension 6014533 "NPR Entra Application List" extends "AAD Application List"
{
    actions
    {
        addlast(Processing)
        {
            group("NPR Entra App Management")
            {
                Caption = 'Entra Application Management';
                Image = WarehouseSetup;

                action("NPR Create Entra App")
                {
                    Caption = 'Create Entra Application';
                    ToolTip = 'The action creates new Microsoft Entra Application in Entra ID directory and registers it in Business Central.';
                    ApplicationArea = NPRRetail;
                    Image = CreateForm;

                    trigger OnAction()
                    var
                        EntraAppRegistration: Page "NPR Entra App Registration";
                    begin
                        EntraAppRegistration.RunModal();
                    end;
                }

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