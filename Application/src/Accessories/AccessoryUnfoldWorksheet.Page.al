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
                    ToolTip = 'Specifies the value of the Accessory Item No. field';
                }
                field("Item Ledger Entry No."; "Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Ledger Entry No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Type field';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source No. field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Line No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Cash Register No."; "Cash Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Document Time"; "Document Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Time field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Generate Unfold Lines action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Post action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Accessory Unfold Entries action';
            }
        }
    }

    var
        Text000: Label 'Post Accessory Unfold Worksheet?';
        Text001: Label 'There is nothing to post.';
        Text002: Label 'Accessory Unfold Worksheet Posted';
}

