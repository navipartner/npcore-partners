#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185058 "NPR Inc Ecom Sales Lines"
{
    UsageCategory = None;
    AutoSplitKey = true;
    Caption = 'Incoming Ecommerce Sales Lines';
    LinksAllowed = false;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Inc Ecom Sales Line";
    ObsoleteState = Pending;
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with Inc Ecom Sales Lines';
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
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
        }
    }

    actions
    {
        area(Processing)
        {
            action(Card)
            {
                Caption = 'Card';
                ToolTip = 'Executes the Card action.';
                ApplicationArea = NPRRetail;
                Image = Document;
                trigger OnAction()
                var
                    IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                begin
                    IncEcomSalesDocUtils.OpenSalesDocumentCard(Rec);
                end;
            }
            action(SalesInvoiceLines)
            {
                Caption = 'Sales Invoice Lines';
                ApplicationArea = NPRRetail;
                Image = Line;
                ToolTip = 'Executes the Sales Invoice Lines action.';
                trigger OnAction()
                var
                    IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                begin
                    IncEcomSalesDocUtils.OpenPostedSalesInvoiceLines(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Home)
            {
                actionref(Card_Promoted; Card) { }
                actionref(SalesInvoiceLines_Promoted; SalesInvoiceLines) { }
            }
        }
    }
}
#endIf