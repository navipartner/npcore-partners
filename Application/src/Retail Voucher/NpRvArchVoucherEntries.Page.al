page 6151023 "NPR NpRv Arch. Voucher Entries"
{
    Caption = 'Archived Retail Voucher Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpRv Arch. Voucher Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Register No. field';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Partner Code"; Rec."Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Code field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                }
                field("Closed by Partner Code"; Rec."Closed by Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Partner Code field';
                }
                field("Partner Clearing"; Rec."Partner Clearing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Clearing field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Navi&gate")
            {
                Caption = 'Navi&gate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Navi&gate action';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
    }
}

