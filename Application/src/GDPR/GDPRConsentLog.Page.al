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
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Entry Approval State"; Rec."Entry Approval State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Approval State field';
                }
                field("State Change"; Rec."State Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the State Change field';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Date field';
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement No. field';
                }
                field("Agreement Version"; Rec."Agreement Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Agreement Version field';
                }
                field("Data Subject Id"; Rec."Data Subject Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Subject Id field';
                }
                field("Last Changed By"; Rec."Last Changed By")
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Accept action';

                trigger OnAction()
                begin
                    Rec.FilterGroup(2);
                    if (Rec."Agreement No." = '') then
                        Rec."Agreement No." := Rec.GetFilter("Agreement No.");

                    if (Rec."Data Subject Id" = '') then
                        Rec."Data Subject Id" := Rec.GetFilter("Data Subject Id");
                    Rec.FilterGroup(0);

                    GDPRManagement.CreateAgreementAcceptEntry(Rec."Agreement No.", 0, Rec."Data Subject Id");
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Reject action';

                trigger OnAction()
                begin

                    Rec.FilterGroup(2);
                    if (Rec."Agreement No." = '') then
                        Rec."Agreement No." := Rec.GetFilter("Agreement No.");

                    if (Rec."Data Subject Id" = '') then
                        Rec."Data Subject Id" := Rec.GetFilter("Data Subject Id");
                    Rec.FilterGroup(0);

                    GDPRManagement.CreateAgreementRejectEntry(Rec."Agreement No.", 0, Rec."Data Subject Id");
                end;
            }
            action(Pending)
            {
                Caption = 'Pending';
                Image = Questionaire;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Pending action';

                trigger OnAction()
                begin

                    Rec.FilterGroup(2);
                    if (Rec."Agreement No." = '') then
                        Rec."Agreement No." := Rec.GetFilter("Agreement No.");

                    if (Rec."Data Subject Id" = '') then
                        Rec."Data Subject Id" := Rec.GetFilter("Data Subject Id");
                    Rec.FilterGroup(0);

                    GDPRManagement.CreateAgreementPendingEntry(Rec."Agreement No.", 0, Rec."Data Subject Id");
                end;
            }
        }
    }

    var
        GDPRManagement: Codeunit "NPR GDPR Management";
}

