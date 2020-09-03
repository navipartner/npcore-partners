page 6151405 "NPR Magento Website Links"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150113  CASE 199932 Changed Table Structure
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Website Links';
    DelayedInsert = true;
    Editable = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NPR Magento Website Link";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Website Code"; "Website Code")
                {
                    ApplicationArea = All;
                }
                field("Website Name"; "Website Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        Websites: Record "NPR Magento Website";
}

