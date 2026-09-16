page 6150972 "NPR Spfy Resync Runs"
{
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Re-sync Runs';
    PageType = List;
    SourceTable = "NPR Spfy Resync Run";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = None;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the entry number of the re-sync run.';
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies what the run targeted: Full Re-sync (every table and store), Area (one integration area), Store (one Shopify store), Table (one polled table), or Quiet Seed (adopts current state as the new baseline without re-sending).';
                }
                field("Integration Area"; Rec."Integration Area")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the integration area the run targeted, when Scope is Area.';
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Shopify store the run targeted, when Scope is Store.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Business Central table the run targeted, when Scope is Table.';
                }
                field("Include Store-Agnostic"; Rec."Include Store-Agnostic")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies whether the run also cleared store-agnostic baselines (variant structural data and inventory move-keys), which affect all stores.';
                }
                field("Launch Mode"; Rec."Launch Mode")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies whether the run was executed directly in the operator''s session (Foreground) or claimed by the one-time background job (Background).';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies whether the run is still in progress (Running), finished successfully (Completed), or ended in error (Failed).';
                }
                field("Started At"; Rec."Started At")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the run started.';
                }
                field("Heartbeat At"; Rec."Heartbeat At")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the run last confirmed it is still alive. A Running row with a heartbeat older than 15 minutes is treated as crashed and marked Failed.';
                }
                field("Completed At"; Rec."Completed At")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the run finished, successfully or with an error.';
                }
                field("Baselines Cleared"; Rec."Baselines Cleared")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies how many Shopify Sync State baseline rows the run cleared, forcing the next poll to re-detect and re-send those entities.';
                }
                field("Marks Reset"; Rec."Marks Reset")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies how many Change Tracker high-water marks the run reset, causing the affected tables to be re-scanned. The Item Ledger Entry mark is left untouched by a re-sync and is not counted here.';
                }
                field("Entities Processed"; Rec."Entities Processed")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies how many entities the quiet-seed re-baselined. Only filled by Quiet Seed runs; re-sync scopes report Baselines Cleared and Marks Reset instead.';
                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the error message if the run failed, or why it was reaped as stale.';
                }
                field("Run By"; Rec."Run By")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the user who started the run.';
                }
            }
        }
    }

    var
        _SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";

    trigger OnOpenPage()
    begin
        _SpfyResyncMgt.ReapStaleRuns();
    end;
}
