page 6060131 "NPR MM Member Cards ListPart"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.02/TSA/20151228  CASE 229980 Print Membercard
    // MM1.22/TSA /20170905 CASE 289434 New function GetCurrentEntryNo()
    // MM1.22/NPKNAV/20170914  CASE 284560-01 Transport MM1.22 - 13 September 2017
    // MM1.29/TSA /20180524 CASE 313795 Touched

    Caption = 'Member Cards';
    CardPageID = "NPR MM Member Card Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR MM Member Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("External Card No. Last 4"; "External Card No. Last 4")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Pin Code"; "Pin Code")
                {
                    ApplicationArea = All;
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                }
                field("Card Is Temporary"; "Card Is Temporary")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("Block Reason"; "Block Reason")
                {
                    ApplicationArea = All;
                }
                field("Document ID"; "Document ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Card")
            {
                Caption = 'Print Card';
                Image = PrintVoucher;
                Promoted = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
                begin
                    MemberRetailIntegration.PrintMemberCard("Member Entry No.", "Entry No.");
                end;
            }
            action("Card Card")
            {
                Caption = 'Card Card';
                Image = Voucher;
                Promoted = true;
                RunObject = Page "NPR MM Member Card Card";
                RunPageLink = "Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Entry No.");
                ApplicationArea=All;
            }
        }
    }

    procedure GetCurrentEntryNo() EntryNo: Integer
    begin

        exit(Rec."Entry No.");
    end;
}

