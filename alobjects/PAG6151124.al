page 6151124 "GDPR Consent Log"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Consent Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GDPR Consent Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Entry Approval State";"Entry Approval State")
                {
                }
                field("State Change";"State Change")
                {
                }
                field("Valid From Date";"Valid From Date")
                {
                }
                field("Agreement No.";"Agreement No.")
                {
                }
                field("Agreement Version";"Agreement Version")
                {
                }
                field("Data Subject Id";"Data Subject Id")
                {
                }
                field("Last Changed By";"Last Changed By")
                {
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
                    FilterGroup (2);
                    if ("Agreement No." = '') then
                      "Agreement No." := GetFilter ("Agreement No.");

                    if ("Data Subject Id" = '') then
                      "Data Subject Id" := GetFilter ("Data Subject Id");
                    FilterGroup (0);

                    GDPRManagement.CreateAgreementAcceptEntry ("Agreement No.", 0, "Data Subject Id");
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

                    FilterGroup (2);
                    if ("Agreement No." = '') then
                      "Agreement No." := GetFilter ("Agreement No.");

                    if ("Data Subject Id" = '') then
                      "Data Subject Id" := GetFilter ("Data Subject Id");
                    FilterGroup (0);

                    GDPRManagement.CreateAgreementRejectEntry ("Agreement No.", 0, "Data Subject Id");
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

                    FilterGroup (2);
                    if ("Agreement No." = '') then
                      "Agreement No." := GetFilter ("Agreement No.");

                    if ("Data Subject Id" = '') then
                      "Data Subject Id" := GetFilter ("Data Subject Id");
                    FilterGroup (0);

                    GDPRManagement.CreateAgreementPendingEntry ("Agreement No.", 0, "Data Subject Id");
                end;
            }
        }
    }

    var
        GDPRManagement: Codeunit "GDPR Management";
}

