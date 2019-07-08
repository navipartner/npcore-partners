pageextension 70000598 pageextension70000598 extends "Item Warehouse FactBox" 
{
    // NPR4.15/MMV/20150904 Added field 'Inventory'.
    layout
    {
        addafter("Warehouse Class Code")
        {
            field(Inventory;Inventory)
            {
            }
        }
    }
}

