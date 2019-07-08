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
                field("Amount Rounding Precision";"Amount Rounding Precision")
                {
                }
                field("Posting Source Code";"Posting Source Code")
                {
                }
                field("Posting No. Management";"Posting No. Management")
                {
                }
                field("Selection No. Series";"Selection No. Series")
                {
                }
                field("Balancing Posting Type";"Balancing Posting Type")
                {
                }
                field("Vat Bus. Posting Group";"Vat Bus. Posting Group")
                {
                }
                field("Post registers compressed";"Post registers compressed")
                {
                }
                field("Appendix no. eq Sales Ticket";"Appendix no. eq Sales Ticket")
                {
                }
                field("Compress G/L Entries";"Compress G/L Entries")
                {
                }
                field("Gen. Journal Template";"Gen. Journal Template")
                {
                }
                field("Gen. Journal Batch";"Gen. Journal Batch")
                {
                }
                field("Item Journal Template";"Item Journal Template")
                {
                }
                field("Item Journal Batch";"Item Journal Batch")
                {
                }
                field("Dimensions Posting Type";"Dimensions Posting Type")
                {
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

