page 6150902 "NPR HC Retail Setup"
{
    Caption = 'HC Retail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HC Retail Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Amount Rounding Precision"; Rec."Amount Rounding Precision")
                {

                    ToolTip = 'Specifies the value of the Amount Rounding Precision field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Source Code"; Rec."Posting Source Code")
                {

                    ToolTip = 'Specifies the value of the Posting Source Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting No. Management"; Rec."Posting No. Management")
                {

                    ToolTip = 'Specifies the value of the Posting No. Management field';
                    ApplicationArea = NPRRetail;
                }
                field("Selection No. Series"; Rec."Selection No. Series")
                {

                    ToolTip = 'Specifies the value of the Selection nos. field';
                    ApplicationArea = NPRRetail;
                }
                field("Balancing Posting Type"; Rec."Balancing Posting Type")
                {

                    ToolTip = 'Specifies the value of the Balancing field';
                    ApplicationArea = NPRRetail;
                }
                field("Vat Bus. Posting Group"; Rec."Vat Bus. Posting Group")
                {

                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Post registers compressed"; Rec."Post registers compressed")
                {

                    ToolTip = 'Specifies the value of the Post registers compressed field';
                    ApplicationArea = NPRRetail;
                }
                field("Appendix no. eq Sales Ticket"; Rec."Appendix no. eq Sales Ticket")
                {

                    ToolTip = 'Specifies the value of the Appendix no. equals sales ticket no. field';
                    ApplicationArea = NPRRetail;
                }
                field("Compress G/L Entries"; Rec."Compress G/L Entries")
                {

                    ToolTip = 'Specifies the value of the Compress G/L Entries field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Journal Template"; Rec."Gen. Journal Template")
                {

                    ToolTip = 'Specifies the value of the Gen. Journal Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Journal Batch"; Rec."Gen. Journal Batch")
                {

                    ToolTip = 'Specifies the value of the Gen. Journal Batch field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Journal Template"; Rec."Item Journal Template")
                {

                    ToolTip = 'Specifies the value of the Item Journal Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Journal Batch"; Rec."Item Journal Batch")
                {

                    ToolTip = 'Specifies the value of the Item Journal Batch field';
                    ApplicationArea = NPRRetail;
                }
                field("Dimensions Posting Type"; Rec."Dimensions Posting Type")
                {

                    ToolTip = 'Specifies the value of the Dimensions Posting Type field';
                    ApplicationArea = NPRRetail;
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

