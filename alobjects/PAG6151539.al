page 6151539 "Nc Endpoints"
{
    // NC2.01/BR  /20160921  CASE 247479 Object created
    // NC2.13/MHA /20180613  CASE 318934 Added Action "Init Endpoint"

    Caption = 'Nc Endpoints';
    PageType = List;
    SourceTable = "Nc Endpoint";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Endpoint Type";"Endpoint Type")
                {
                }
                field(Description;Description)
                {
                }
                field("Setup Summary";"Setup Summary")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field("Linked Endpoints";"Linked Endpoints")
                {
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
                RunObject = Page "Nc Endpoint Trigger Links";
                RunPageLink = "Endpoint Code"=FIELD(Code);
                RunPageView = SORTING("Endpoint Code","Trigger Code")
                              ORDER(Ascending);
            }
            action("Init Endpoint")
            {
                Caption = 'Init Endpoint';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = EndpointHasInit;

                trigger OnAction()
                var
                    NcEndpointMgt: Codeunit "Nc Endpoint Mgt.";
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
        NcEndpointMgt: Codeunit "Nc Endpoint Mgt.";
    begin
        //-NC2.13 [318934]
        EndpointHasInit := NcEndpointMgt.HasInitEndpoint(Rec);
        //+NC2.13 [318934]
    end;

    var
        EndpointHasInit: Boolean;
}

