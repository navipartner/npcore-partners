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
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Voucher No."; "External Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Voucher No. field';
                }
                field("External Voucher Barcode"; "External Voucher Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Voucher Barcode field';
                }
                field("Issued Date"; "Issued Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Issued Time"; "Issued Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Time field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Issued By User"; "Issued By User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issued By User field';
                }
                field("Total Amount Incl. VAT"; "Total Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Refund Amount"; "Refund Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Refund Amount field';
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Handler ID"; "Handler ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handler ID field';
                }
                field("Service ID"; "Service ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service ID field';
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field(Void; Void)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voided field';
                }
                field("Voided By User"; "Voided By User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voided By User field';
                }
                field("Voided Date"; "Voided Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voided Date field';
                }
                field("Voided Time"; "Voided Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voided Time field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Void Voucher action';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Print Voucher action';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Reissue Voucher action';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Search Sale Links action';

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

