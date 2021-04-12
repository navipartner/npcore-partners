page 6151538 "NPR Nc Endpoint Trigger Links"
{
    // NC2.01\BR\20160921  CASE 247479 Object created

    Caption = 'Nc Endpoint Trigger Links';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Endpoint Trigger Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; Rec."Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Code field';
                }
                field("Trigger Code"; Rec."Trigger Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trigger Code field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Endpoint Setup action';
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    NcEndpoint: Record "NPR Nc Endpoint";
                begin
                    NcEndpoint.Get(Rec."Endpoint Code");
                    NcEndpoint.SetupEndpoint();
                end;
            }
        }
    }
}

