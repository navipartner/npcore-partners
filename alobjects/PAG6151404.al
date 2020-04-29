page 6151404 "Magento Website List"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.22/TS/20150107  CASE 228446 Added Global Dimension 1 Code and Global Dimension 2 Code
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Websites';
    CardPageID = "Magento Websites";
    Editable = false;
    PageType = List;
    SourceTable = "Magento Website";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Default Website";"Default Website")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

