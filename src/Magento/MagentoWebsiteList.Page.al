page 6151404 "NPR Magento Website List"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.22/TS/20150107  CASE 228446 Added Global Dimension 1 Code and Global Dimension 2 Code
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Websites';
    CardPageID = "NPR Magento Websites";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Website";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Default Website"; "Default Website")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

