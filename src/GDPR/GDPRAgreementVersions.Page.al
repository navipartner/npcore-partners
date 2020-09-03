page 6151122 "NPR GDPR Agreement Versions"
{
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018

    Caption = 'GDPR Agreement Versions';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR GDPR Agreement Version";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(URL; URL)
                {
                    ApplicationArea = All;
                }
                field("Activation Date"; "Activation Date")
                {
                    ApplicationArea = All;
                }
                field("Anonymize After"; "Anonymize After")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

