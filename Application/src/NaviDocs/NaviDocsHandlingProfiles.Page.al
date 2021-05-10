page 6059768 "NPR NaviDocs Handling Profiles"
{
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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Handle by NAS"; Rec."Handle by NAS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handle by NAS field';
                }
                field("Default for Print"; Rec."Default for Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print All Containing Entry field';
                }
                field("Default for E-Mail"; Rec."Default for E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default for E-Mail field';
                }
                field("Default Electronic Document"; Rec."Default Electronic Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default for Electronic Document field';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        NaviDocsManagement.CreateHandlingProfileLibrary();
    end;
}

