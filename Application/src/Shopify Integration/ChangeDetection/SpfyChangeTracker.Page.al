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
                    ToolTip = 'Specifies the highest SystemRowVersion processed so far for this table. The next detection run picks up rows with a higher row version.';
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
            action(ResetMark)
            {
                ApplicationArea = NPRShopify;
                Caption = 'Reset Mark (full re-sync)';
                Image = Reuse;
                ToolTip = 'Resets the selected high-water mark to 0 so the next detection run re-scans the whole table and re-sends everything. Use with care on large tables.';

                trigger OnAction()
                begin
                    Rec."Last Row Version" := 0;
                    Rec.Modify(true);
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
}
