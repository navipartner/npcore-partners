page 6059768 "NPR NaviDocs Handling Profiles"
{
    // NPR5.26/THRO/20160808 CASE 248662 : Page changed to show NaviDocs Handling Profiles

    Caption = 'NaviDocs Posting List';
    PageType = List;
    SourceTable = "NPR NaviDocs Handling Profile";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Handle by NAS"; "Handle by NAS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handle by NAS field';
                }
                field("Default for Print"; "Default for Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print All Containing Entry field';
                }
                field("Default for E-Mail"; "Default for E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default for E-Mail field';
                }
                field("Default Electronic Document"; "Default Electronic Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default for Electronic Document field';
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

