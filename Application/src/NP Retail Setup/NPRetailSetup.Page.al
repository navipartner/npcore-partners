page 6150613 "NPR NP Retail Setup"
{

    Caption = 'NP Retail Setup';
    SourceTable = "NPR NP Retail Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {

            group("System")
            {
                Caption = 'System';

            }
        }
    }

    trigger OnOpenPage()
    begin
        ActiveSession.Get(ServiceInstanceId, SessionId);
        if not InventorySetup.Get then
            InventorySetup.Init;
        PostToGLAfterItemPostingEditable := (not InventorySetup."Automatic Cost Posting");
        AdjCostAfterItemPostingEditable := (InventorySetup."Automatic Cost Adjustment" < InventorySetup."Automatic Cost Adjustment"::Day);
    end;

    var
        ActiveSession: Record "Active Session";
        InventorySetup: Record "Inventory Setup";
        [InDataSet]
        PostToGLAfterItemPostingEditable: Boolean;
        [InDataSet]
        AdjCostAfterItemPostingEditable: Boolean;
}

