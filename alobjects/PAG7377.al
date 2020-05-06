pageextension 6014475 pageextension6014475 extends "Inventory Pick" 
{
    // NPR5.33/TJ  /20170322 CASE 268412 New action Scan
    // NPR5.48/TS  /20181214  CASE 339845 Added Field Assigned User Id
    layout
    {
        addafter("External Document No.2")
        {
            field("Assigned User ID";"Assigned User ID")
            {
            }
        }
    }
    actions
    {
        addafter("Delete Qty. to Handle")
        {
            action(Scan)
            {
                Caption = 'Scan';
                Image = BarCode;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Inventory Pick Scan";
                RunPageLink = Type=FIELD(Type),
                              "No."=FIELD("No.");
            }
        }
    }
}

