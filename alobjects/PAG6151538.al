page 6151538 "Nc Endpoint Trigger Links"
{
    // NC2.01\BR\20160921  CASE 247479 Object created

    Caption = 'Nc Endpoint Trigger Links';
    PageType = List;
    SourceTable = "Nc Endpoint Trigger Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code";"Endpoint Code")
                {
                }
                field("Trigger Code";"Trigger Code")
                {
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
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    NcEndpoint: Record "Nc Endpoint";
                begin
                    NcEndpoint.Get("Endpoint Code");
                    NcEndpoint.SetupEndpoint();
                end;
            }
        }
    }
}

