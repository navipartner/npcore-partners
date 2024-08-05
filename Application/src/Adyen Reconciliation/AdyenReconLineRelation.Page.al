page 6184657 "NPR Adyen Recon. Line Relation"
{
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    Caption = 'NP Pay Recon. Line Relation';
    PageType = List;
    SourceTable = "NPR Adyen Recon. Line Relation";
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Amount Type"; Rec."Amount Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the corresponding Entry''s Amount Type';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the corresponding Entry''s Amount';
                }
                field("GL Entry No."; Rec."GL Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the General Ledger Entry No.';
                }
                field("Posting Document No."; Rec."Posting Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Posting Document No.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Posting Date.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Find Entries")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                ToolTip = 'Executes the Find entries action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Posting Document No.");
                    Navigate.Run();
                end;
            }
        }
    }
}
