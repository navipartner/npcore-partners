page 6151380 "CS Stock-Take Handling"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Stock-Take Handling';
    PageType = List;
    SourceTable = "CS Stock-Take Handling";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field(Barcode;Barcode)
                {
                }
                field(Qty;Qty)
                {
                }
                field("Stock-Take Config Code";"Stock-Take Config Code")
                {
                }
                field("Worksheet Name";"Worksheet Name")
                {
                }
                field("Shelf  No.";"Shelf  No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Handled;Handled)
                {
                }
                field("Transferred to Worksheet";"Transferred to Worksheet")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
            }
        }
    }

    actions
    {
    }
}

