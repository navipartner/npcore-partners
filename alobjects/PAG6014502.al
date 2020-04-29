page 6014502 "Accessory Unfold Worksheet"
{
    // NPR5.40/MHA /20180214  CASE 288039 Object created - unfold Accessory Items

    Caption = 'Accessory Unfold Worksheet';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Accessory Unfold Worksheet";
    UsageCategory = Tasks;

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
                field("Entry Type";"Entry Type")
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Generate Unfold Lines")
            {
                Caption = 'Generate Unfold Lines';
                Image = CalculatePlan;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AccessoryUnfoldMgt: Codeunit "Accessory Unfold Mgt.";
                begin
                    AccessoryUnfoldMgt.GenerateWorksheet(Rec);
                end;
            }
            action(Post)
            {
                Caption = 'Post';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';

                trigger OnAction()
                var
                    AccessoryUnfoldMgt: Codeunit "Accessory Unfold Mgt.";
                begin
                    if not Confirm(Text000,true) then
                      exit;

                    if not AccessoryUnfoldMgt.PostWorksheet(Rec) then begin
                      Message(Text001);
                      exit;
                    end;

                    CurrPage.Update(false);
                    Message(Text002);
                end;
            }
        }
        area(navigation)
        {
            action("Accessory Unfold Entries")
            {
                Caption = 'Accessory Unfold Entries';
                Image = Line;
                RunObject = Page "Accessory Unfold Entries";
                RunPageLink = "Accessory Item No."=FIELD("Accessory Item No.");
            }
        }
    }

    var
        Text000: Label 'Post Accessory Unfold Worksheet?';
        Text001: Label 'There is nothing to post.';
        Text002: Label 'Accessory Unfold Worksheet Posted';
}

