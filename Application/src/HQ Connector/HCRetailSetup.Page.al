page 6150902 "NPR HC Retail Setup"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.48/TJ  /20181114 CASE 331992 New field "Dimensions Posting Type"

    Caption = 'HC Retail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HC Retail Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Amount Rounding Precision"; "Amount Rounding Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Rounding Precision field';
                }
                field("Posting Source Code"; "Posting Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Source Code field';
                }
                field("Posting No. Management"; "Posting No. Management")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting No. Management field';
                }
                field("Selection No. Series"; "Selection No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selection nos. field';
                }
                field("Balancing Posting Type"; "Balancing Posting Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing field';
                }
                field("Vat Bus. Posting Group"; "Vat Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("Post registers compressed"; "Post registers compressed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post registers compressed field';
                }
                field("Appendix no. eq Sales Ticket"; "Appendix no. eq Sales Ticket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Appendix no. equals sales ticket no. field';
                }
                field("Compress G/L Entries"; "Compress G/L Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Compress G/L Entries field';
                }
                field("Gen. Journal Template"; "Gen. Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Journal Template field';
                }
                field("Gen. Journal Batch"; "Gen. Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Journal Batch field';
                }
                field("Item Journal Template"; "Item Journal Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Template field';
                }
                field("Item Journal Batch"; "Item Journal Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Batch field';
                }
                field("Dimensions Posting Type"; "Dimensions Posting Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimensions Posting Type field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

