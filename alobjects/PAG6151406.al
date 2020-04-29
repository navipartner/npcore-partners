page 6151406 "Magento Stores"
{
    // MAG1.01/MH/20150201  CASE 199932 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/TS  /20170830  CASE 262530  Added Field 1024 Language Code

    Caption = 'Stores';
    Editable = false;
    PageType = List;
    SourceTable = "Magento Store";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Language Code";"Language Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

