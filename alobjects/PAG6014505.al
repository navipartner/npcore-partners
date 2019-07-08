page 6014505 "Accessory Unfold Entries"
{
    // NPR5.40/MHA /20180214  CASE 288039 Object created - unfold Accessory Items

    Caption = 'Accessory Unfold Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Accessory Unfold Entry";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Accessory Item No.";"Accessory Item No.")
                {
                }
                field("Item Ledger Entry No.";"Item Ledger Entry No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Source Type";"Source Type")
                {
                }
                field("Source No.";"Source No.")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Document Line No.";"Document Line No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field("Cash Register No.";"Cash Register No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Document Time";"Document Time")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Unfold Item Ledger Entry No.";"Unfold Item Ledger Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc("Posting Date","Document No.");
                    Navigate.Run;
                end;
            }
        }
    }

    var
        Text000: Label 'Post Accessory Unfold Worksheet?';
}

