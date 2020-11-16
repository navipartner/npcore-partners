page 6151016 "NPR NpRv Voucher Entries"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Renamed field 55 "Sales Ticket No." to "Document No." and added fields 53 "Document Type", 60 "External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.54/ALST/20200220  CASE 387465 added navigation action
    // NPR5.55/MHA /20200512  CASE 404116 Added SetDoc() to Navigation action

    Caption = 'Retail Voucher Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Partner Code"; "Partner Code")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Closed by Partner Code"; "Closed by Partner Code")
                {
                    ApplicationArea = All;
                }
                field("Partner Clearing"; "Partner Clearing")
                {
                    ApplicationArea = All;
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

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    //-NPR5.55 [404116]
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                    //+NPR5.55 [404116]
                end;
            }
        }
    }
}

