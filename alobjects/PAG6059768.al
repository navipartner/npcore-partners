page 6059768 "NaviDocs Handling Profiles"
{
    // NPR5.26/THRO/20160808 CASE 248662 : Page changed to show NaviDocs Handling Profiles

    Caption = 'NaviDocs Posting List';
    PageType = List;
    SourceTable = "NaviDocs Handling Profile";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Handle by NAS";"Handle by NAS")
                {
                }
                field("Default for Print";"Default for Print")
                {
                }
                field("Default for E-Mail";"Default for E-Mail")
                {
                }
                field("Default Electronic Document";"Default Electronic Document")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
    begin
        NaviDocsManagement.CreateHandlingProfileLibrary;
    end;
}

