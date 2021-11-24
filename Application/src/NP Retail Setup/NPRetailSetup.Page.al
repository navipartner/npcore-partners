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
                field("Last Data Model Build User ID"; "Last Data Model Build User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Model Build User ID field';
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
                field("Default POS Posting Profile"; "Default POS Posting Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Posting Profile field';
                }
            }
            group(Legal)
            {
                field("Standard Conditions"; "Standard Conditions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Standard Conditions field';
                }
                field(Privacy; Privacy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Privacy field';
                }
                field("License Agreement"; "License Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Agreement field';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpgradeBalV3Setup)
            {
                Caption = 'Upgrade Audit Roll to POS Entry';
                Image = TransferToLines;
                ToolTip = 'Start upgrade audit roll entries to POS entries.';
                ApplicationArea = All;

                trigger OnAction()
                var
                    RetDataModARUpgr: codeunit "NPR UPG RetDataMod AR Upgr.";
                begin
                    RetDataModARUpgr.UpgradeSetupsBalancingV3();
                end;
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

