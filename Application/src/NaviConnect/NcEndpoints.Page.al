page 6151539 "NPR Nc Endpoints"
{
    // NC2.01/BR  /20160921  CASE 247479 Object created
    // NC2.13/MHA /20180613  CASE 318934 Added Action "Init Endpoint"

    Caption = 'Nc Endpoints';
    PageType = List;
    SourceTable = "NPR Nc Endpoint";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Endpoint Type"; "Endpoint Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Setup Summary"; "Setup Summary")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Linked Endpoints"; "Linked Endpoints")
                {
                    ApplicationArea = All;
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

