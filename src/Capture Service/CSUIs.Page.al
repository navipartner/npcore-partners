page 6151377 "NPR CS UIs"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS UIs';
    CardPageID = "NPR CS UI";
    Editable = false;
    PageType = List;
    SourceTable = "NPR CS UI Header";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("No. of Records in List"; "No. of Records in List")
                {
                    ApplicationArea = All;
                }
                field("Handling Codeunit"; "Handling Codeunit")
                {
                    ApplicationArea = All;
                }
                field("Next UI"; "Next UI")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea=All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea=All;
            }
        }
    }

    actions
    {
    }
}

