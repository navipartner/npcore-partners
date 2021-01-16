page 6151539 "NPR Nc Endpoints"
{
    // NC2.01/BR  /20160921  CASE 247479 Object created
    // NC2.13/MHA /20180613  CASE 318934 Added Action "Init Endpoint"

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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Endpoint Type"; "Endpoint Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Setup Summary"; "Setup Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup Summary field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Linked Endpoints"; "Linked Endpoints")
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup action';

                trigger OnAction()
                begin
                    SetupEndpoint();
                end;
            }
            action("Trigger Links")
            {
                Caption = 'Trigger Links';
                Image = Links;
                Promoted = true;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = EndpointHasInit;
                ApplicationArea = All;
                ToolTip = 'Executes the Init Endpoint action';

                trigger OnAction()
                var
                    NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
                begin
                    //-NC2.13 [318934]
                    NcEndpointMgt.InitEndpoint(Rec);
                    //+NC2.13 [318934]
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
    begin
        //-NC2.13 [318934]
        EndpointHasInit := NcEndpointMgt.HasInitEndpoint(Rec);
        //+NC2.13 [318934]
    end;

    var
        EndpointHasInit: Boolean;
}

