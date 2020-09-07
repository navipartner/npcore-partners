pageextension 6014480 "NPR Inventory Pick" extends "Inventory Pick"
{
    // NPR5.33/TJ  /20170322 CASE 268412 New action Scan
    // NPR5.48/TS  /20181214  CASE 339845 Added Field Assigned User Id
    layout
    {
        addafter("External Document No.2")
        {
            field("NPR Assigned User ID"; "Assigned User ID")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Delete Qty. to Handle")
        {
            action("NPR Scan")
            {
                Caption = 'Scan';
                Image = BarCode;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Inventory Pick Scan";
                RunPageLink = Type = FIELD(Type),
                              "No." = FIELD("No.");
                ApplicationArea=All;
            }
        }
    }
}

