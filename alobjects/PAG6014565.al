page 6014565 "Tax Free Voucher"
{
    // NPR4.18/JDH/20160209 CASE 224257 Object Created - Found duriong release - done by MMV
    // NPR5.30/MMV /20170131 CASE 261964 Refactored tax free.
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Voucher';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Tax Free Voucher";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Voucher No.";"External Voucher No.")
                {
                }
                field("External Voucher Barcode";"External Voucher Barcode")
                {
                }
                field("Issued Date";"Issued Date")
                {
                }
                field("Issued Time";"Issued Time")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Issued By User";"Issued By User")
                {
                }
                field("Total Amount Incl. VAT";"Total Amount Incl. VAT")
                {
                }
                field("Refund Amount";"Refund Amount")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Handler ID";"Handler ID")
                {
                }
                field("Service ID";"Service ID")
                {
                }
                field(Mode;Mode)
                {
                }
                field(Void;Void)
                {
                }
                field("Voided By User";"Voided By User")
                {
                }
                field("Voided Date";"Voided Date")
                {
                }
                field("Voided Time";"Voided Time")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(VoidVoucher)
            {
                Caption = 'Void Voucher';
                Image = VoidCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TFVoucher: Record "Tax Free Voucher";
                    TaxFree: Codeunit "Tax Free Handler Mgt.";
                begin
                    TFVoucher := Rec;
                    TFVoucher.SetRecFilter;
                    TaxFree.VoucherVoid(TFVoucher);
                end;
            }
            action(PrintVoucher)
            {
                Caption = 'Print Voucher';
                Image = PrintCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TFVoucher: Record "Tax Free Voucher";
                    TaxFree: Codeunit "Tax Free Handler Mgt.";
                begin
                    TFVoucher := Rec;
                    TFVoucher.SetRecFilter;
                    TaxFree.VoucherPrint(TFVoucher);
                end;
            }
            action(ReissueVoucher)
            {
                Caption = 'Reissue Voucher';
                Image = StaleCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TFVoucher: Record "Tax Free Voucher";
                    TaxFree: Codeunit "Tax Free Handler Mgt.";
                begin
                    TFVoucher := Rec;
                    TFVoucher.SetRecFilter;
                    TaxFree.VoucherReissue(TFVoucher);
                end;
            }
            action("Search Sale Links")
            {
                Caption = 'Search Sale Links';
                Image = SplitChecks;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TaxFreeVoucherSaleLink: Record "Tax Free Voucher Sale Link";
                    TaxFreeVoucherSaleLinks: Page "Tax Free Voucher Sale Links";
                begin
                    if PAGE.RunModal(PAGE::"Tax Free Voucher Sale Links", TaxFreeVoucherSaleLink) = ACTION::LookupOK then begin
                      Get(TaxFreeVoucherSaleLink."Voucher Entry No.");
                    end;
                end;
            }
        }
    }

    var
        Caption_ScanReceipt: Label 'Scan Sales Ticket';
        Caption_NoVoucherFound: Label 'No tax free voucher found for this sales ticket';
}

