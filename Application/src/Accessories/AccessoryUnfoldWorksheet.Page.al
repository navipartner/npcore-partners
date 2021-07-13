page 6014502 "NPR Accessory Unfold Worksheet"
{
    // NPR5.40/MHA /20180214  CASE 288039 Object created - unfold Accessory Items

    Caption = 'Accessory Unfold Worksheet';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "NPR Accessory Unfold Worksheet";
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Accessory Item No."; Rec."Accessory Item No.")
                {

                    ToolTip = 'Specifies the value of the Accessory Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {

                    ToolTip = 'Specifies the value of the Item Ledger Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Type"; Rec."Source Type")
                {

                    ToolTip = 'Specifies the value of the Source Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Source No."; Rec."Source No.")
                {

                    ToolTip = 'Specifies the value of the Source No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Line No."; Rec."Document Line No.")
                {

                    ToolTip = 'Specifies the value of the Document Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Register No."; Rec."Cash Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Time"; Rec."Document Time")
                {

                    ToolTip = 'Specifies the value of the Document Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Generate Unfold Lines action';
                ApplicationArea = NPRRetail;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';

                ToolTip = 'Executes the Post action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Accessory Unfold Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        Text000: Label 'Post Accessory Unfold Worksheet?';
        Text001: Label 'There is nothing to post.';
        Text002: Label 'Accessory Unfold Worksheet Posted';
}

