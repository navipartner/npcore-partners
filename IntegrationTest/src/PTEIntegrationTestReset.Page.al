page 61000 "NPR PTE Integration Test Reset"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Integration Test Reset';

    actions
    {
        area(Processing)
        {
            action(ResetState)
            {
                ApplicationArea = All;
                ToolTip = 'Reset all state necessary for running test suite';
                Caption = 'Reset State';
                trigger OnAction()
                var
                    IntegrationTestReset: Codeunit "NPRPTE Integration Test Reset";
                begin
                    IntegrationTestReset.ResetState();
                end;
            }
        }
    }
}