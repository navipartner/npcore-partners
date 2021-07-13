page 6151124 "NPR GDPR Consent Log"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Consent Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR GDPR Consent Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Approval State"; Rec."Entry Approval State")
                {

                    ToolTip = 'Specifies the value of the Entry Approval State field';
                    ApplicationArea = NPRRetail;
                }
                field("State Change"; Rec."State Change")
                {

                    ToolTip = 'Specifies the value of the State Change field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {

                    ToolTip = 'Specifies the value of the Valid From Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Agreement No."; Rec."Agreement No.")
                {

                    ToolTip = 'Specifies the value of the Agreement No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Agreement Version"; Rec."Agreement Version")
                {

                    ToolTip = 'Specifies the value of the Agreement Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Subject Id"; Rec."Data Subject Id")
                {

                    ToolTip = 'Specifies the value of the Data Subject Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Changed By"; Rec."Last Changed By")
                {

                    ToolTip = 'Specifies the value of the Last Changed By field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Accept action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Reject action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Pending action';
                ApplicationArea = NPRRetail;

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

