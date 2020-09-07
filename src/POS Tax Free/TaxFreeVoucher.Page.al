page 6014565 "NPR Tax Free Voucher"
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
    SourceTable = "NPR Tax Free Voucher";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Voucher No."; "External Voucher No.")
                {
                    ApplicationArea = All;
                }
                field("External Voucher Barcode"; "External Voucher Barcode")
                {
                    ApplicationArea = All;
                }
                field("Issued Date"; "Issued Date")
                {
                    ApplicationArea = All;
                }
                field("Issued Time"; "Issued Time")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Issued By User"; "Issued By User")
                {
                    ApplicationArea = All;
                }
                field("Total Amount Incl. VAT"; "Total Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Refund Amount"; "Refund Amount")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Handler ID"; "Handler ID")
                {
                    ApplicationArea = All;
                }
                field("Service ID"; "Service ID")
                {
                    ApplicationArea = All;
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                }
                field(Void; Void)
                {
                    ApplicationArea = All;
                }
                field("Voided By User"; "Voided By User")
                {
                    ApplicationArea = All;
                }
                field("Voided Date"; "Voided Date")
                {
                    ApplicationArea = All;
                }
                field("Voided Time"; "Voided Time")
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
            action(VoidVoucher)
            {
                Caption = 'Void Voucher';
                Image = VoidCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    TFVoucher: Record "NPR Tax Free Voucher";
                    TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    TFVoucher: Record "NPR Tax Free Voucher";
                    TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    TFVoucher: Record "NPR Tax Free Voucher";
                    TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
                    TaxFreeVoucherSaleLinks: Page "NPR Tax Free Vouch. Sale Links";
                begin
                    if PAGE.RunModal(PAGE::"NPR Tax Free Vouch. Sale Links", TaxFreeVoucherSaleLink) = ACTION::LookupOK then begin
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

