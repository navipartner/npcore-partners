page 6151122 "NPR GDPR Agreement Versions"
{
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018

    Caption = 'GDPR Agreement Versions';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR GDPR Agreement Version";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(URL; Rec.URL)
                {

                    ToolTip = 'Specifies the value of the URL field';
                    ApplicationArea = NPRRetail;
                }
                field("Activation Date"; Rec."Activation Date")
                {

                    ToolTip = 'Specifies the value of the Activation Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Anonymize After"; Rec."Anonymize After")
                {

                    ToolTip = 'Specifies the value of the Anonymize After field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

