page 6151122 "NPR GDPR Agreement Versions"
{
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018

    Caption = 'GDPR Agreement Versions';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR GDPR Agreement Version";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the URL field';
                }
                field("Activation Date"; Rec."Activation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activation Date field';
                }
                field("Anonymize After"; Rec."Anonymize After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Anonymize After field';
                }
            }
        }
    }

    actions
    {
    }
}

