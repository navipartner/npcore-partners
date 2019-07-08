page 6151435 "Magento Attribute Set Values"
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.18/TS  /20180910  CASE 323934 Added field Attribute Group ID

    Caption = 'Attribute Set Values';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Magento Attribute Set Value";
    SourceTableView = SORTING(Position);

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Attribute ID";"Attribute ID")
                {
                }
                field(Description;Description)
                {
                }
                field(Position;Position)
                {
                }
                field("Attribute Group ID";"Attribute Group ID")
                {
                }
            }
        }
    }

    actions
    {
    }
}

