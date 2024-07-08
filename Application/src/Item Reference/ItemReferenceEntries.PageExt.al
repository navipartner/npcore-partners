pageextension 6014410 "NPR Item Reference Entries" extends "Item Reference Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Label Barcode"; Rec."NPR Label Barcode")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies that you want the program to use this barcode for label printing';
            }
            field("NPR Discontinued Barcode"; Rec."NPR Discontinued Barcode")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies that whether the barcode is marked for discontinuation or not.';
                Editable = false;
            }
            field("NPR Discontinued Reason"; Rec."NPR Discontinued Reason")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the reason that the barcode is marked for discontinuation or not.';
                Editable = false;
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("NPR Toggle Discontinuation")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Toggle Barcode Discontinuation';
                ToolTip = 'Executes the Toggle Discontinuation action';
                Promoted = true;
                PromotedCategory = Process;
                Image = Change;
                PromotedOnly = true;
                Visible = true;

                trigger OnAction()
                var
                    ItemReference: Record "Item Reference";
                begin
                    SetSelectionFilter(ItemReference);
                    if ItemReference.FindSet(true) then
                        repeat
                            if ItemReference."NPR Discontinued Barcode" then
                                ItemReference."NPR Discontinued Barcode" := false
                            else
                                ItemReference."NPR Discontinued Barcode" := true;

                            ItemReference."NPR Discontinued Reason" := Rec."NPR Discontinued Reason"::Manual;
                            ItemReference.Modify(true);
                        until ItemReference.Next() = 0;
                    Clear(ItemReference);
                end;
            }
        }
    }
}