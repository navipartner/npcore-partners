page 6151122 "GDPR Agreement Versions"
{
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018

    Caption = 'GDPR Agreement Versions';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "GDPR Agreement Version";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Version;Version)
                {
                }
                field(Description;Description)
                {
                }
                field(URL;URL)
                {
                }
                field("Activation Date";"Activation Date")
                {
                }
                field("Anonymize After";"Anonymize After")
                {
                }
            }
        }
    }

    actions
    {
    }
}

