page 6150902 "HC Retail Setup"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.48/TJ  /20181114 CASE 331992 New field "Dimensions Posting Type"

    Caption = 'HC Retail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "HC Retail Setup";
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
                }
                field("Posting Source Code"; "Posting Source Code")
                {
                    ApplicationArea = All;
                }
                field("Posting No. Management"; "Posting No. Management")
                {
                    ApplicationArea = All;
                }
                field("Selection No. Series"; "Selection No. Series")
                {
                    ApplicationArea = All;
                }
                field("Balancing Posting Type"; "Balancing Posting Type")
                {
                    ApplicationArea = All;
                }
                field("Vat Bus. Posting Group"; "Vat Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Post registers compressed"; "Post registers compressed")
                {
                    ApplicationArea = All;
                }
                field("Appendix no. eq Sales Ticket"; "Appendix no. eq Sales Ticket")
                {
                    ApplicationArea = All;
                }
                field("Compress G/L Entries"; "Compress G/L Entries")
                {
                    ApplicationArea = All;
                }
                field("Gen. Journal Template"; "Gen. Journal Template")
                {
                    ApplicationArea = All;
                }
                field("Gen. Journal Batch"; "Gen. Journal Batch")
                {
                    ApplicationArea = All;
                }
                field("Item Journal Template"; "Item Journal Template")
                {
                    ApplicationArea = All;
                }
                field("Item Journal Batch"; "Item Journal Batch")
                {
                    ApplicationArea = All;
                }
                field("Dimensions Posting Type"; "Dimensions Posting Type")
                {
                    ApplicationArea = All;
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

