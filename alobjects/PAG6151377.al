page 6151377 "CS UIs"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS UIs';
    CardPageID = "CS UI";
    Editable = false;
    PageType = List;
    SourceTable = "CS UI Header";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("No. of Records in List";"No. of Records in List")
                {
                }
                field("Handling Codeunit";"Handling Codeunit")
                {
                }
                field("Next UI";"Next UI")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

