page 6151539 "NPR Nc Endpoints"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Nc Endpoints';
    PageType = List;
    SourceTable = "NPR Nc Endpoint";
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {

                    ToolTip = 'Specifies the value of the Endpoint Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Setup Summary"; Rec."Setup Summary")
                {

                    ToolTip = 'Specifies the value of the Setup Summary field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Setup)
            {
                Caption = 'Setup';
                Image = InteractionTemplateSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Setup action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    Rec.SetupEndpoint();
                end;
            }
            action("Init Endpoint")
            {
                Caption = 'Init Endpoint';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = EndpointHasInit;

                ToolTip = 'Executes the Init Endpoint action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
                begin
                    NcEndpointMgt.InitEndpoint(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
    begin
        EndpointHasInit := NcEndpointMgt.HasInitEndpoint(Rec);
    end;

    var
        EndpointHasInit: Boolean;
}

