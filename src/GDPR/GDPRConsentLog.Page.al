page 6151124 "NPR GDPR Consent Log"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Consent Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR GDPR Consent Log";

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
                field("Entry Approval State"; "Entry Approval State")
                {
                    ApplicationArea = All;
                }
                field("State Change"; "State Change")
                {
                    ApplicationArea = All;
                }
                field("Valid From Date"; "Valid From Date")
                {
                    ApplicationArea = All;
                }
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("Agreement Version"; "Agreement Version")
                {
                    ApplicationArea = All;
                }
                field("Data Subject Id"; "Data Subject Id")
                {
                    ApplicationArea = All;
                }
                field("Last Changed By"; "Last Changed By")
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
            action(Accept)
            {
                Caption = 'Accept';
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    FilterGroup(2);
                    if ("Agreement No." = '') then
                        "Agreement No." := GetFilter("Agreement No.");

                    if ("Data Subject Id" = '') then
                        "Data Subject Id" := GetFilter("Data Subject Id");
                    FilterGroup(0);

                    GDPRManagement.CreateAgreementAcceptEntry("Agreement No.", 0, "Data Subject Id");
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    FilterGroup(2);
                    if ("Agreement No." = '') then
                        "Agreement No." := GetFilter("Agreement No.");

                    if ("Data Subject Id" = '') then
                        "Data Subject Id" := GetFilter("Data Subject Id");
                    FilterGroup(0);

                    GDPRManagement.CreateAgreementRejectEntry("Agreement No.", 0, "Data Subject Id");
                end;
            }
            action(Pending)
            {
                Caption = 'Pending';
                Image = Questionaire;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    FilterGroup(2);
                    if ("Agreement No." = '') then
                        "Agreement No." := GetFilter("Agreement No.");

                    if ("Data Subject Id" = '') then
                        "Data Subject Id" := GetFilter("Data Subject Id");
                    FilterGroup(0);

                    GDPRManagement.CreateAgreementPendingEntry("Agreement No.", 0, "Data Subject Id");
                end;
            }
        }
    }

    var
        GDPRManagement: Codeunit "NPR GDPR Management";
}

