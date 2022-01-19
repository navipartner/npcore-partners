page 6014499 "NPR Replication Setup List"
{

    ApplicationArea = NPRRetail;
    Caption = 'Replication API Setup List';
    CardPageId = "NPR Replication Setup Card";
    ContextSensitiveHelpPage = 'retail/replication/howto/replicationhowto.html';
    Editable = false;
    Extensible = true;
    PageType = List;
    SourceTable = "NPR Replication Service Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Setup Code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Setup Name.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Setup is Enabled. If Disabled system will not execute import for the endpoints related to this Setup ';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Update Custom Endpoints")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Runs code that subscribes to this action with the purpose of modifying standard NP Retail Enpoints path with Custom Paths.';
                Image = UpdateDescription;
                trigger OnAction()
                var
                    ReplicationRegister: Codeunit "NPR Replication Register";
                    Handled: Boolean;
                begin
                    ReplicationRegister.OnUpdateCustomEndpoints(Handled);
                    if Handled then
                        Message(UpdatedCustomEnpointsMsg)
                    else
                        Message(NotUpdatedCustomEnpointsMsg);
                end;
            }
        }
        area(Reporting)
        {
            action("Check Missing Fields")
            {
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                ToolTip = 'Check if there are missing fields from other extensions that are not handled by the replication.';
                Image = CheckList;
                RunObject = report "NPR Rep. Check Missing Fields";
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnRegisterService();
    end;

    var
        UpdatedCustomEnpointsMsg: Label 'Custom Endpoints updated.';
        NotUpdatedCustomEnpointsMsg: Label 'There is no code defined to update Custom Endpoints.';

}
