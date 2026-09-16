page 6151227 "NPR Spfy Change Tracker"
{
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Change Tracker';
    PageType = List;
    SourceTable = "NPR Change Tracker";
    UsageCategory = None;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    ToolTip = 'Specifies the integration this high-water mark belongs to.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the table that is tracked by SQL row version.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    ToolTip = 'Specifies the name of the table that is tracked by SQL row version.';
                }
                field("Last Row Version"; Rec."Last Row Version")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the detection high-water mark: only rows with a SystemRowVersion above this value are picked up by the next poll. The value is a GLOBAL database counter shared by all tables — every committed write in any table increments it — so lowering it by N replays the last N database changes, not the last N rows of this table. Re-scanned rows whose baselines still match are skipped as no-ops. Lower it slightly below the current value for a cheap surgical replay window. The value cannot be negative.';

                    trigger OnValidate()
                    begin
                        if Rec."Last Row Version" < 0 then
                            Rec."Last Row Version" := 0;
                    end;
                }
                field(ResetPolicy; _ResetPolicyText)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Reset Policy';
                    Editable = false;
                    ToolTip = 'Specifies what the reset action does for this table. Baseline Reset = clears stored baselines and re-scans (true re-sync). Mark-Only Requeue = re-scans and re-sends without baselines. Fast-Forward Only = the mark can only be moved forward (Item Ledger Entry). Blocked = reset is not allowed for this table (Retail Vouchers, Item Prices).';
                }
                field("Last Detection At"; Rec.SystemModifiedAt)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Last Detection At';
                    Editable = false;
                    ToolTip = 'Specifies when this high-water mark was last advanced.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetMarkAndBaselines)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Reset Mark && Baselines (full re-sync)';
                Image = Reuse;
                ToolTip = 'Re-syncs this table to Shopify: clears its stored sync baselines and resets the mark to 0 so the next detection cycle re-scans every row and re-sends the current state. For inventory trigger tables (Sales Line, Transfer Line, Stockkeeping Unit) this recomputes open-line inventory and rebuilds move-key tracking — only changed quantities are re-sent. For mark-only tables (Item Reference, Inventory Level) it re-scans and re-sends without baselines. Blocked for Retail Voucher tables (a baseline wipe would silently swallow the next real change), for Item Prices (no baseline exists) and for Item Ledger Entry (use Fast-forward instead). Values that equal their default (for example a zero cost) are not re-pushed by a reset — only a real change re-sends them.';

                trigger OnAction()
                var
                    SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
                begin
                    SpfyResyncMgt.StartTableResync(Rec."Table No.");
                    CurrPage.Update(false);
                end;
            }
            action(FastForwardMark)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Fast-forward Mark to Current Max';
                Image = NextRecord;
                ToolTip = 'Sets the mark to the current maximum row version, skipping the pending backlog. Use it to recover a mis-edited or mistakenly reset mark, or to deliberately skip processing old changes. Changes committed before this moment will not be detected. Takes effect from the next detection cycle; an in-flight detection cycle may still process up to its row cap from the old backlog. Allowed for every table, including Item Ledger Entry.';

                trigger OnAction()
                var
                    ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
                    ConfirmFastForwardQst: Label 'Skip the pending backlog and set the mark for table %1 to the current maximum row version? Changes committed before this moment will not be detected.', Comment = '%1 = table caption';
                begin
                    // No resync marker needed: this only RAISES the mark, which AdvanceMark treats as a monotonic no-op.
                    Rec.CalcFields("Table Name");
                    if not Confirm(ConfirmFastForwardQst, false, Rec."Table Name") then
                        exit;
                    ChangeTrackerMgt.SeedToCurrentMax(Rec, ChangeTrackerMgt.CurrentMaxRowVersion(Rec."Table No."));
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        Rec.FilterGroup(0);
    end;

    trigger OnAfterGetRecord()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        BaselineResetLbl: Label 'Baseline Reset';
        MarkOnlyLbl: Label 'Mark-Only Requeue';
        FastForwardOnlyLbl: Label 'Fast-Forward Only';
        BlockedLbl: Label 'Blocked';
    begin
        case SpfyResyncMgt.GetTablePolicy(Rec."Table No.") of
            "NPR Spfy Resync Table Policy"::"Baseline Reset":
                _ResetPolicyText := BaselineResetLbl;
            "NPR Spfy Resync Table Policy"::"Mark-Only Requeue":
                _ResetPolicyText := MarkOnlyLbl;
            "NPR Spfy Resync Table Policy"::"Fast-Forward Only":
                _ResetPolicyText := FastForwardOnlyLbl;
            "NPR Spfy Resync Table Policy"::Blocked:
                _ResetPolicyText := BlockedLbl;
        end;
    end;

    var
        _ResetPolicyText: Text;
}
