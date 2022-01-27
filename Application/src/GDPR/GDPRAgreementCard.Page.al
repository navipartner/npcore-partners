page 6151123 "NPR GDPR Agreement Card"
{
    Extensible = False;
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Action

    Caption = 'GDPR Agreement Card';
    DelayedInsert = true;
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR GDPR Agreement";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                    ;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                    ;
                }
            }
            group(Control6014407)
            {
                ShowCaption = false;
                field("Anonymize After"; Rec."Anonymize After")
                {

                    ToolTip = 'Specifies the value of the Anonymize After field';
                    ApplicationArea = NPRRetail;
                    ;
                }
            }
            part(Control6014404; "NPR GDPR Agreement Versions")
            {
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRRetail;
                ;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Push Consent Request")
            {
                Caption = 'Push Consent Request';
                Image = Apply;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Push Consent Request action';
                ApplicationArea = NPRRetail;
                ;

                trigger OnAction()
                begin

                    GDPRManagement.OnNewAgreementVersion(Rec."No.");
                end;
            }
        }
    }

    var
        GDPRManagement: Codeunit "NPR GDPR Management";
}

