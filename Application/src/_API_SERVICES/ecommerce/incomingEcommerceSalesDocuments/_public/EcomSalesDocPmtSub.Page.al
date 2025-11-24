#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248181 "NPR Ecom Sales Doc Pmt Sub"
{
    AutoSplitKey = true;
    Caption = 'Payment Lines';
    PageType = ListPart;
    SourceTable = "NPR Ecom Sales Pmt. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payment Method Type"; Rec."Payment Method Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Method Type field.';
                }
                field("External Payment Type"; Rec."External Payment Type")
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
                field("Processing Payment Amount"; Rec."Processing Payment Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Processing Payment Amount field.';
                }
                field("Captured Amount"; Rec."Captured Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Captured Amount field.';
                    trigger OnDrillDown()
                    var
                        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                    begin
                        EcomSalesDocUtils.OpenPaymentLines(Rec);
                    end;
                }
                field("Invoiced Amount"; Rec."Invoiced Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Invoiced Amount field.';
                    trigger OnDrillDown()
                    var
                        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                    begin
                        EcomSalesDocUtils.OpenPaymentLines(Rec);
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
                    ToolTip = 'Specifies the value of the Masked Card Number field.';
                }
                field("Card Expiry Date"; Rec."Card Expiry Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Expiry Date field.';
                }
                field("Card Alias Token"; Rec."Card Alias Token")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Alias Token field.';
                }
            }
            group(Control28)
            {
                ShowCaption = false;
                field("Total Payment Amount"; EcomSalesHeader."Payment Amount")
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = Currency.Code;
                    AutoFormatType = 1;
                    CaptionClass = EcomSalesDocUtils.GetPaymentAmountCaption(Currency.Code);
                    Caption = 'Total Payment Amount';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Payment Amount field.';
                }
                field("Total Captured Payment Amount"; EcomSalesHeader."Captured Payment Amount")
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = Currency.Code;
                    AutoFormatType = 1;
                    CaptionClass = EcomSalesDocUtils.GetCapturedPaymentAmountCaption(Currency.Code);
                    Caption = 'Total Captured Payment Amount';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Captured Payment Amount field.';
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(PaymentLines)
            {
                Caption = 'Payment Lines';
                ApplicationArea = NPRRetail;
                Image = Line;
                ToolTip = 'Executes the Payment Lines action.';
                trigger OnAction()
                var
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenPaymentLines(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetGlobals();
    end;

    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Currency: Record Currency;

        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";


    local procedure GetGlobals()
    begin
        EcomSalesHeader.SetAutoCalcFields("Payment Amount");
        if not EcomSalesHeader.Get(Rec."Document Entry No.") then
            Clear(EcomSalesHeader);

        if not Currency.Get(EcomSalesHeader."Currency Code") then
            Clear(Currency);
    end;
}
#endif