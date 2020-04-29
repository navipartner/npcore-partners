page 6060060 "Item Worksheet Variety Mapping"
{
    // NPR5.37/BR  /20170922  CASE 268786 Added Mapping option to import
    // NPR5.43/JKL /20180525 CASE 314287  Added worksheet filter fields
    // NPR5.46/JKL /20180927 CASE 314287  rearranged fields + removed page update

    Caption = 'Item Worksheet Variety Mapping';
    PageType = List;
    SourceTable = "Item Worksheet Variety Mapping";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name";"Worksheet Template Name")
                {
                    Visible = false;
                }
                field("Worksheet Name";"Worksheet Name")
                {
                    Visible = false;
                }
                field("Vendor No.";"Vendor No.")
                {
                }
                field("Item Wksh. Maping Field";"Item Wksh. Maping Field")
                {
                    LookupPageID = "Item Worksheet Field Setup";
                }
                field("Item Wksh. Maping Field Name";"Item Wksh. Maping Field Name")
                {
                }
                field("Item Wksh. Maping Field Value";"Item Wksh. Maping Field Value")
                {
                }
                field("Vendor Variety Value";"Vendor Variety Value")
                {
                }
                field(Variety;Variety)
                {
                }
                field("Variety Table";"Variety Table")
                {
                }
                field("Variety Value";"Variety Value")
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.46 [314287]
                        //CurrPage.UPDATE(FALSE);
                        //+NPR5.46 [314287]
                    end;
                }
                field("Variety Value Description";"Variety Value Description")
                {
                }
            }
        }
    }

    actions
    {
    }
}

