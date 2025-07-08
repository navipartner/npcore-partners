#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185059 "NPR Inc Ecom Sales Pmt Lines"
{
    UsageCategory = None;
    AutoSplitKey = true;
    Caption = 'Payment Lines';
    PageType = List;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    SourceTable = "NPR Inc Ecom Sales Pmt. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Document No. field.';
                }
                field("Payment Method Type"; Rec."Payment Method Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Method Type field.';
                }
                field("External Payment Type"; Rec."External Paymment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Payment Type field.';
                }
                field("External Payment Method Code"; Rec."External Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Payment Method Code field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Reference"; Rec."Payment Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Reference field.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Captured Amount"; Rec."Captured Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Captured Amount field.';
                    trigger OnDrillDown()
                    var
                        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                    begin
                        IncEcomSalesDocUtils.OpenPaymentLines(Rec);
                    end;
                }
                field("Invoiced Amount"; Rec."Invoiced Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Invoiced Amount field.';
                    trigger OnDrillDown()
                    var
                        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                    begin
                        IncEcomSalesDocUtils.OpenPaymentLines(Rec);
                    end;
                }
                field("PAR Token"; Rec."PAR Token")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the PAR Token field.';
                }
                field("PSP Token"; Rec."PSP Token")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the PSP Token field.';
                }
                field("Card Brand"; Rec."Card Brand")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Brand field.';
                }
                field("Masked Card Number"; Rec."Masked Card Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Summary field.';
                }
                field("Card Expiry Date"; Rec."Card Expiry Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Expiry Date field.';
                }
            }
        }

    }

    actions
    {
        area(Navigation)
        {
            action(PaymentLines)
            {
                Caption = 'Payment Lines';
                ApplicationArea = NPRRetail;
                Image = Line;
                ToolTip = 'Executes the Payment Lines action.';
                trigger OnAction()
                var
                    IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                begin
                    IncEcomSalesDocUtils.OpenPaymentLines(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Home)
            {
                actionref(PaymentLines_Promoted; PaymentLines) { }
            }
        }
    }
}
#endIf
