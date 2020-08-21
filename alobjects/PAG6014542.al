page 6014542 "Touch Screen - Layout List"
{
    // NPR4.11/JDH/20150619  CASE 210070 Changed CardPageID

    Caption = 'Touch Screen - Layout List';
    CardPageID = "Touch Screen - Layout Card";
    PageType = List;
    SourceTable = "Touch Screen - Layout";

    layout
    {
        area(content)
        {
            repeater(Control6150620)
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
                field("Resolution Width"; "Resolution Width")
                {
                    ApplicationArea = All;
                }
                field("Resolution Height"; "Resolution Height")
                {
                    ApplicationArea = All;
                }
                field("Button Count Vertical"; "Button Count Vertical")
                {
                    ApplicationArea = All;
                }
                field("Button Count Horizontal"; "Button Count Horizontal")
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

