page 6151538 "NPR Nc Endpoint Trigger Links"
{
    Caption = 'Nc Endpoint Trigger Links';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Endpoint Trigger Link";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint Code"; Rec."Endpoint Code")
                {

                    ToolTip = 'Specifies the value of the Endpoint Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Trigger Code"; Rec."Trigger Code")
                {

                    ToolTip = 'Specifies the value of the Trigger Code field';
                    ApplicationArea = NPRNaviConnect;
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
                ToolTip = 'Executes the Endpoint Setup action';
                ApplicationArea = NPRNaviConnect;

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

