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
            group(General)
            {
                Caption = 'General';
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field';
                }
            }
            group("System")
            {
                Caption = 'System';
                field("Data Model Build"; "Data Model Build")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Data Model Upg.Log";
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Model Build field';
                }
                field("Last Data Model Build Upgrade"; "Last Data Model Build Upgrade")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Model Build Upgrade field';
                }
                field("Prev. Data Model Build"; "Prev. Data Model Build")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Prev. Data Model Build field';
                }
                field("Advanced POS Entries Activated"; "Advanced POS Entries Activated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Advanced POS Entries Activated field';
                }
                field("Advanced Posting Activated"; "Advanced Posting Activated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Advanced Posting Activated field';
                }
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

