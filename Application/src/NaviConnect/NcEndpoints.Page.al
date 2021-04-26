page 6151539 "NPR Nc Endpoints"
{
    Caption = 'Nc Endpoints';
    PageType = List;
    SourceTable = "NPR Nc Endpoint";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Endpoint Type"; Rec."Endpoint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Setup Summary"; Rec."Setup Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup Summary field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Linked Endpoints"; Rec."Linked Endpoints")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Linked Endpoints field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Trigger Links action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Init Endpoint action';

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

