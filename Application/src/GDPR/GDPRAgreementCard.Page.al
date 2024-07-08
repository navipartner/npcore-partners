page 6151123 "NPR GDPR Agreement Card"
{
    Extensible = False;

    Caption = 'GDPR Agreement Card';
    DelayedInsert = true;
    PageType = Card;
    UsageCategory = None;

    SourceTable = "NPR GDPR Agreement";

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
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control6014407)
            {
                ShowCaption = false;
                field("Anonymize After"; Rec."Anonymize After")
                {
                    ToolTip = 'Specifies the amount of time that needs to pass from membership expiry until the member and membership is anonymized';
                    ApplicationArea = NPRRetail;
                }

                field(KeepAnonymizedFor; Rec.KeepAnonymizedFor)
                {
                    Tooltip = 'Specifies the amount of time a membership needs to be anonymized until it will be deleted.';
                    ApplicationArea = NPRRetail;
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

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NPR GDPR Management";
                begin

                    GDPRManagement.OnNewAgreementVersion(Rec."No.");
                end;
            }
        }
    }
}

