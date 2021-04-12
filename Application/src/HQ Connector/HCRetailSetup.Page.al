page 6150902 "NPR HC Retail Setup"
{
    Caption = 'HC Retail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HC Retail Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Amount Rounding Precision"; Rec."Amount Rounding Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Rounding Precision field';
                }
                field("Posting Source Code"; Rec."Posting Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Source Code field';
                }
                field("Posting No. Management"; Rec."Posting No. Management")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting No. Management field';
                }
                field("Selection No. Series"; Rec."Selection No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selection nos. field';
                }
                field("Balancing Posting Type"; Rec."Balancing Posting Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing field';
                }
                field("Vat Bus. Posting Group"; Rec."Vat Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("Post registers compressed"; Rec."Post registers compressed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post registers compressed field';
                }
                field("Appendix no. eq Sales Ticket"; Rec."Appendix no. eq Sales Ticket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Appendix no. equals sales ticket no. field';
                }
                field("Compress G/L Entries"; Rec."Compress G/L Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Compress G/L Entries field';
                }
                field("Gen. Journal Template"; Rec."Gen. Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Journal Template field';
                }
                field("Gen. Journal Batch"; Rec."Gen. Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Journal Batch field';
                }
                field("Item Journal Template"; Rec."Item Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Template field';
                }
                field("Item Journal Batch"; Rec."Item Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Batch field';
                }
                field("Dimensions Posting Type"; Rec."Dimensions Posting Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimensions Posting Type field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

