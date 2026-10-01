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
                    Enabled = not IsManagedEntraApp;

                    trigger OnAction()
                    begin
                        RegenerateEntraAppSecret();
                    end;
                }
                action("NPR BI Allowed Tables")
                {
                    Caption = 'BI API Allowed Tables';
                    ToolTip = 'Opens the list of tables that this Entra ID application is allowed to read through the BI API. An application that belongs to a NaviPartner API Key uses the list of that key instead.';
                    ApplicationArea = NPRRetail;
                    Image = Table;
                    Enabled = not IsManagedEntraApp;
                    AccessByPermission = tabledata "NPR API BI Allowed Table" = R;

                    trigger OnAction()
                    begin
                        ShowBIAllowedTables();
                    end;
                }
            }
        }
    }

    var
        IsManagedEntraApp: Boolean;

    trigger OnAfterGetRecord()
    begin
        UpdateRecControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateRecControls();
    end;

    local procedure RegenerateEntraAppSecret()
    var
        AadApplicationMgt: Codeunit "NPR AAD Application Mgt.";
    begin
        AadApplicationMgt.RegenerateEntraAppSecret(Rec, true);
    end;

    local procedure ShowBIAllowedTables()
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
    begin
        Rec.TestField("Client Id");

        BIAllowedTable.FilterGroup(2);
        BIAllowedTable.SetRange("Principal Type", BIAllowedTable."Principal Type"::"Entra App");
        BIAllowedTable.SetRange("Principal Id", Rec."Client Id");
        BIAllowedTable.FilterGroup(0);
        Page.Run(Page::"NPR API BI Allowed Tables", BIAllowedTable);
    end;

    local procedure UpdateRecControls()
    begin
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        IsManagedEntraApp := Rec.IsManagedEntraApp();
#endif
    end;
}