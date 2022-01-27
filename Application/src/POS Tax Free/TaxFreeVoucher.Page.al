page 6014565 "NPR Tax Free Voucher"
{
    Extensible = False;
    Caption = 'Tax Free Voucher';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free Voucher";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Voucher No."; Rec."External Voucher No.")
                {

                    ToolTip = 'Specifies the value of the External Voucher No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Voucher Barcode"; Rec."External Voucher Barcode")
                {

                    ToolTip = 'Specifies the value of the External Voucher Barcode field';
                    ApplicationArea = NPRRetail;
                }
                field("Issued Date"; Rec."Issued Date")
                {

                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Issued Time"; Rec."Issued Time")
                {

                    ToolTip = 'Specifies the value of the Created Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Issued By User"; Rec."Issued By User")
                {

                    ToolTip = 'Specifies the value of the Issued By User field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount Incl. VAT"; Rec."Total Amount Incl. VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Refund Amount"; Rec."Refund Amount")
                {

                    ToolTip = 'Specifies the value of the Refund Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Handler ID Enum"; Rec."Handler ID Enum")
                {

                    ToolTip = 'Specifies the value of the Handler ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Service ID"; Rec."Service ID")
                {

                    ToolTip = 'Specifies the value of the Service ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the value of the Mode field';
                    ApplicationArea = NPRRetail;
                }
                field(Void; Rec.Void)
                {

                    ToolTip = 'Specifies the value of the Voided field';
                    ApplicationArea = NPRRetail;
                }
                field("Voided By User"; Rec."Voided By User")
                {

                    ToolTip = 'Specifies the value of the Voided By User field';
                    ApplicationArea = NPRRetail;
                }
                field("Voided Date"; Rec."Voided Date")
                {

                    ToolTip = 'Specifies the value of the Voided Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Voided Time"; Rec."Voided Time")
                {

                    ToolTip = 'Specifies the value of the Voided Time field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Void Voucher action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TFVoucher: Record "NPR Tax Free Voucher";
                    TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    TFVoucher := Rec;
                    TFVoucher.SetRecFilter();
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

                ToolTip = 'Executes the Print Voucher action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TFVoucher: Record "NPR Tax Free Voucher";
                    TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    TFVoucher := Rec;
                    TFVoucher.SetRecFilter();
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

                ToolTip = 'Executes the Reissue Voucher action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TFVoucher: Record "NPR Tax Free Voucher";
                    TaxFree: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    TFVoucher := Rec;
                    TFVoucher.SetRecFilter();
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

                ToolTip = 'Executes the Search Sale Links action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
                begin
                    if PAGE.RunModal(PAGE::"NPR Tax Free Vouch. Sale Links", TaxFreeVoucherSaleLink) = ACTION::LookupOK then begin
                        Rec.Get(TaxFreeVoucherSaleLink."Voucher Entry No.");
                    end;
                end;
            }
        }
    }

}

