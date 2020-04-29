page 6151123 "GDPR Agreement Card"
{
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Action

    Caption = 'GDPR Agreement Card';
    DelayedInsert = true;
    PageType = Card;
    SourceTable = "GDPR Agreement";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
            }
            group(Control6014407)
            {
                ShowCaption = false;
                field("Anonymize After";"Anonymize After")
                {
                }
            }
            part(Control6014404;"GDPR Agreement Versions")
            {
                SubPageLink = "No."=FIELD("No.");
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    GDPRManagement.OnNewAgreementVersion ("No.");
                end;
            }
        }
    }

    var
        GDPRManagement: Codeunit "GDPR Management";
}

