page 6151054 "NPR POS Paym. View Event Setup"
{
    Extensible = False;
    Caption = 'POS Payment View Event Setup';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/reference/payment_view_ref/';
    PageType = Card;
    SourceTable = "NPR POS Paym. View Event Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Dimension Popup Enabled"; Rec."Dimension Popup Enabled")
                {
                    ToolTip = 'Enable the Dimension Popup option when going to the Payment View in the POS. The Dimension popup is an invocation of the POS action SALE_DIMENSION.';
                    ApplicationArea = NPRRetail;
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the Dimension which will be used.';
                    ApplicationArea = NPRRetail;
                }
                field("Popup per"; Rec."Popup per")
                {
                    ToolTip = 'Specifies whether the popup will be triggered per a POS Store, POS Unit, or in all cases.';
                    ApplicationArea = NPRRetail;
                }
                field("Popup every"; Rec."Popup every")
                {
                    ToolTip = 'Specifies after how many sales the popup will reoccur.';
                    ApplicationArea = NPRRetail;
                }
                field("Popup Start Time"; Rec."Popup Start Time")
                {
                    ToolTip = 'Specifies the starting time for the popup.';
                    ApplicationArea = NPRRetail;
                }
                field("Popup End Time"; Rec."Popup End Time")
                {
                    ToolTip = 'Specifies the ending time for the popup.';
                    ApplicationArea = NPRRetail;
                }
                field("Popup Mode"; Rec."Popup Mode")
                {
                    ToolTip = 'Specifies whether to use the List, Numpad or Input mode for the popup.';
                    ApplicationArea = NPRRetail;
                }
                field("Create New Dimension Values"; Rec."Create New Dimension Values")
                {
                    ToolTip = 'Specifies whether the new dimension will be automatically created if it doesn''t exist in the dimension values list when the user provides the value in the dimension popup.';
                    ApplicationArea = NPRRetail;
                }
                field("Skip Popup on Dimension Value"; Rec."Skip Popup on Dimension Value")
                {
                    ToolTip = 'Specifies whether the popup will be skipped if a value for the dimension has already been assigned to the POS sale.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(FilterGr)
            {
                Caption = 'Popup Filter';
                part("NPR Popup Dim. Filter"; "NPR Popup Dim. Filter")
                {
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Payment View Log Entries")
            {
                Caption = 'POS Payment View Log Entries';
                Image = History;
                RunObject = Page "NPR POS Paym. View Log Entries";
                ToolTip = 'Opens the POS Payment View Log Entries List';
                ApplicationArea = NPRRetail;
            }
            action("POS Scenarios")
            {
                Caption = 'POS Scenarios';
                Image = Setup;
                RunObject = Page "NPR POS Scenarios";
                ToolTip = 'Opens the POS Scenarios List';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnInit()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
