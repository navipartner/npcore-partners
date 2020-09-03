page 6059768 "NPR NaviDocs Handling Profiles"
{
    // NPR5.26/THRO/20160808 CASE 248662 : Page changed to show NaviDocs Handling Profiles

    Caption = 'NaviDocs Posting List';
    PageType = List;
    SourceTable = "NPR NaviDocs Handling Profile";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Handle by NAS"; "Handle by NAS")
                {
                    ApplicationArea = All;
                }
                field("Default for Print"; "Default for Print")
                {
                    ApplicationArea = All;
                }
                field("Default for E-Mail"; "Default for E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Default Electronic Document"; "Default Electronic Document")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        NaviDocsManagement.CreateHandlingProfileLibrary;
    end;
}

