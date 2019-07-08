page 6060070 "MM Membership Auto Renew List"
{
    // MM1.22/NPKNAV/20170914  CASE 286922 Transport MM1.22 - 13 September 2017
    // MM1.25/NPKNAV/20180122  CASE 301463 Transport MM1.25 - 22 January 2018
    // #334163/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Membership Auto Renew List';
    CardPageID = "MM Membership Auto Renew Card";
    PageType = List;
    SourceTable = "MM Membership Auto Renew";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Community Code";"Community Code")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Valid Until Date";"Valid Until Date")
                {
                }
                field("Document Date";"Document Date")
                {
                }
                field("Payment Terms Code";"Payment Terms Code")
                {
                }
                field("Payment Method Code";"Payment Method Code")
                {
                }
                field("Post Invoice";"Post Invoice")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Started At";"Started At")
                {
                }
                field("Completed At";"Completed At")
                {
                }
                field("Started By";"Started By")
                {
                }
                field("Selected Membership Count";"Selected Membership Count")
                {
                }
                field("Auto-Renew Success Count";"Auto-Renew Success Count")
                {
                }
                field("Auto-Renew Fail Count";"Auto-Renew Fail Count")
                {
                }
                field("Invoice Create Fail Count";"Invoice Create Fail Count")
                {
                }
                field("Invoice Posting Fail Count";"Invoice Posting Fail Count")
                {
                }
                field("First Invoice No.";"First Invoice No.")
                {
                }
                field("Last Invoice No.";"Last Invoice No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Start Auto-Renew")
            {
                Caption = 'Start Auto-Renew';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    StartAutoRenew ();
                end;
            }
        }
        area(navigation)
        {
            action("Auto-Renew Log")
            {
                Caption = 'Auto-Renew Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Auto-Renew Log";
                RunPageLink = "Auto-Renew Entry No."=FIELD("Entry No.");
            }
        }
    }

    var
        COMPLETE: Label 'This Auto Renew batch is complete and can not be restarted.';

    local procedure StartAutoRenew()
    var
        MembershipAutoRenew: Codeunit "MM Membership Auto Renew";
    begin

        if "Completed At" <> CreateDateTime (0D, 0T) then
          Error (COMPLETE);

        MembershipAutoRenew.AutoRenewBatch (Rec."Entry No.");
    end;
}

