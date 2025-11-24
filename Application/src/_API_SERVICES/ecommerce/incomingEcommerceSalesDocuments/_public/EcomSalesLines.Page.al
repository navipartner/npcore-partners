#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248186 "NPR Ecom Sales Lines"
{
    UsageCategory = None;
    AutoSplitKey = true;
    Caption = 'Ecommerce Sales Lines';
    LinksAllowed = false;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Ecom Sales Line";

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
                        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                    begin
                        EcomSalesDocUtils.OpenPostedSalesInvoiceLines(Rec);
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
                        EcomSalesDocUtils.OpenPostedSalesInvoiceLines(Rec);
                    end;
                }
                field("Virtual Item Process Status"; Rec."Virtual Item Process Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Virtual Item Process Status field.';
                    StyleExpr = _VirtualItemProcessingStatusStyle;
                }
                field("Virtual Item Process ErrMsg"; Rec."Virtual Item Process ErrMsg")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Virtual Item Process ErrMsg field.';
                    StyleExpr = _VirtualItemProcessingStatusStyle;
                }
                field(Captured; Rec.Captured)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Captured field.';
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
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenSalesDocumentCard(Rec);
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
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenPostedSalesInvoiceLines(Rec);
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

    trigger OnAfterGetRecord()
    begin
        GetStyles();
    end;

    var
        _VirtualItemProcessingStatusStyle: Text;

    local procedure GetStyles()
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        _VirtualItemProcessingStatusStyle := EcomVirtualItemMgt.GetVirtualItemProcessingStatusStyle(Rec);
    end;
}
#endIf