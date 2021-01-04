page 6151408 "NPR Magento Store Subform"
{
    // MAG1.01/MH/20150201  CASE 199932 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/TS  /20170830  CASE 262530  Added Field 1024 Language Code

    Caption = 'Magento Store Subform';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR Magento Store";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
            }
        }
    }

    actions
    {
    }
}

