page 6059768 "NPR NaviDocs Handling Profiles"
{
    Caption = 'NaviDocs Posting List';
    PageType = List;
    SourceTable = "NPR NaviDocs Handling Profile";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Handle by NAS"; Rec."Handle by NAS")
                {

                    ToolTip = 'Specifies the value of the Handle by NAS field';
                    ApplicationArea = NPRRetail;
                }
                field("Default for Print"; Rec."Default for Print")
                {

                    ToolTip = 'Specifies the value of the Print All Containing Entry field';
                    ApplicationArea = NPRRetail;
                }
                field("Default for E-Mail"; Rec."Default for E-Mail")
                {

                    ToolTip = 'Specifies the value of the Default for E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Electronic Document"; Rec."Default Electronic Document")
                {

                    ToolTip = 'Specifies the value of the Default for Electronic Document field';
                    ApplicationArea = NPRRetail;
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

