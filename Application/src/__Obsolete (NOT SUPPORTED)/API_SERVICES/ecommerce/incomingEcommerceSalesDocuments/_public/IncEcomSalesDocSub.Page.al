#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185065 "NPR Inc Ecom Sales Doc Sub"
{
    AutoSplitKey = true;
    Caption = 'Sales Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "NPR Inc Ecom Sales Line";
    ObsoleteState = Pending;
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with Ecom Sales Doc Sub';
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field("Barcode No."; Rec."Barcode No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Barcode No. field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Unit Price field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Unit Of Measure Code"; Rec."Unit Of Measure Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Unit Of Measure Code field.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line Amount field.';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the VAT % field.';
                }
                field("Invoiced Qty."; Rec."Invoiced Qty.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Invoiced Qty. field.';
                    trigger OnDrillDown()
                    var
                        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                    begin
                        IncEcomSalesDocUtils.OpenPostedSalesInvoiceLines(Rec);
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
                        IncEcomSalesDocUtils.OpenPostedSalesInvoiceLines(Rec);
                    end;
                }
            }
            group(Control28)
            {
                ShowCaption = false;
                field("Total Amount"; IncEcomSalesHeader."Amount")
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = Currency.Code;
                    AutoFormatType = 1;
                    CaptionClass = IncEcomSalesDocUtils.GetTotalAmountCaption(Currency.Code);
                    Caption = 'Total Amount';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Amount field.';

                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetGlobals();
    end;

    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        Currency: Record Currency;

        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";

    local procedure GetGlobals()
    begin
        IncEcomSalesHeader.SetAutoCalcFields("Amount");
        if not IncEcomSalesHeader.Get(Rec."Document Type", Rec."External Document No.") then
            Clear(IncEcomSalesHeader);

        if not Currency.Get(IncEcomSalesHeader."Currency Code") then
            Clear(Currency);
    end;
}
#endif