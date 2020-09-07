page 6151538 "NPR Nc Endpoint Trigger Links"
{
    // NC2.01\BR\20160921  CASE 247479 Object created

    Caption = 'Nc Endpoint Trigger Links';
    PageType = List;
    SourceTable = "NPR Nc Endpoint Trigger Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                }
                field("Trigger Code"; "Trigger Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Endpoint Setup")
            {
                Caption = 'Endpoint Setup';
                Image = InteractionTemplateSetup;
                ApplicationArea=All;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    NcEndpoint: Record "NPR Nc Endpoint";
                begin
                    NcEndpoint.Get("Endpoint Code");
                    NcEndpoint.SetupEndpoint();
                end;
            }
        }
    }
}

