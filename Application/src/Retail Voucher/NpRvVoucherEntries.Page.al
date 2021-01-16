page 6151016 "NPR NpRv Voucher Entries"
{
    Caption = 'Retail Voucher Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpRv Voucher Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Register No. field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Partner Code"; "Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Code field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                }
                field("Closed by Partner Code"; "Closed by Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed by Partner Code field';
                }
                field("Partner Clearing"; "Partner Clearing")
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
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Navi&gate action';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }
}

