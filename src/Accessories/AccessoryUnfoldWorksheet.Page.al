page 6014502 "NPR Accessory Unfold Worksheet"
{
    // NPR5.40/MHA /20180214  CASE 288039 Object created - unfold Accessory Items

    Caption = 'Accessory Unfold Worksheet';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "NPR Accessory Unfold Worksheet";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Accessory Item No."; "Accessory Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Ledger Entry No."; "Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Cash Register No."; "Cash Register No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Document Time"; "Document Time")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
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
                    AccessoryUnfoldMgt: Codeunit "NPR Accessory Unfold Mgt.";
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
                    AccessoryUnfoldMgt: Codeunit "NPR Accessory Unfold Mgt.";
                begin
                    if not Confirm(Text000, true) then
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
                RunObject = Page "NPR Accessory Unfold Entries";
                RunPageLink = "Accessory Item No." = FIELD("Accessory Item No.");
            }
        }
    }

    var
        Text000: Label 'Post Accessory Unfold Worksheet?';
        Text001: Label 'There is nothing to post.';
        Text002: Label 'Accessory Unfold Worksheet Posted';
}

