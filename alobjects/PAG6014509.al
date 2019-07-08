page 6014509 "Accessory List - Register"
{
    Caption = 'Accessories List Register';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Accessory/Spare Part";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Quantity;Quantity)
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Inventory;Inventory)
                {
                }
                field(Vendor;Vendor)
                {
                }
                field("Buy-from Vendor Name";"Buy-from Vendor Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

