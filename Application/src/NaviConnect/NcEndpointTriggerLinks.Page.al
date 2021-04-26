page 6151538 "NPR Nc Endpoint Trigger Links"
{
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

