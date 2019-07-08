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
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Resolution Width";"Resolution Width")
                {
                }
                field("Resolution Height";"Resolution Height")
                {
                }
                field("Button Count Vertical";"Button Count Vertical")
                {
                }
                field("Button Count Horizontal";"Button Count Horizontal")
                {
                }
            }
        }
    }

    actions
    {
    }
}

