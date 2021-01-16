page 6151124 "NPR GDPR Consent Log"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Consent Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Approval State"; "Entry Approval State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Approval State field';
                }
                field("State Change"; "State Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the State Change field';
                }
                field("Valid From Date"; "Valid From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Date field';
                }
                field("Agreement No."; "Agreement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement No. field';
                }
                field("Agreement Version"; "Agreement Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement Version field';
                }
                field("Data Subject Id"; "Data Subject Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Subject Id field';
                }
                field("Last Changed By"; "Last Changed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Changed By field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Accept action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Reject action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Pending action';

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

