page 6151023 "NPR NpRv Arch. Voucher Entries"
{
    Caption = 'Archived Retail Voucher Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Arch. Voucher Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {

                    ToolTip = 'Specifies the value of the Remaining Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Positive; Rec.Positive)
                {

                    ToolTip = 'Specifies the value of the Positive field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Partner Code"; Rec."Partner Code")
                {

                    ToolTip = 'Specifies the value of the Partner Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {

                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Closed by Partner Code"; Rec."Closed by Partner Code")
                {

                    ToolTip = 'Specifies the value of the Closed by Partner Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Partner Clearing"; Rec."Partner Clearing")
                {

                    ToolTip = 'Specifies the value of the Partner Clearing field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Navi&gate action';
                ApplicationArea = NPRRetail;

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

