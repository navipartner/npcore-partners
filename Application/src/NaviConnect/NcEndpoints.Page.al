page 6151539 "NPR Nc Endpoints"
{
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
                field("Linked Endpoints"; Rec."Linked Endpoints")
                {

                    ToolTip = 'Specifies the value of the Linked Endpoints field';
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
            action("Trigger Links")
            {
                Caption = 'Trigger Links';
                Image = Links;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Nc Endpoint Trigger Links";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                RunPageView = SORTING("Endpoint Code", "Trigger Code")
                              ORDER(Ascending);

                ToolTip = 'Executes the Trigger Links action';
                ApplicationArea = NPRNaviConnect;
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

