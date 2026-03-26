#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248182 "NPR Ecom Sales Doc Sub"
{
    AutoSplitKey = true;
    Caption = 'Sales Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "NPR Ecom Sales Line";

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
                field(Captured; Rec.Captured)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Captured field.';
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
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = NPRShopifyEcommerce;
                    ToolTip = 'Specifies the value of the Line Disocount Amount field.';
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
                    StyleExpr = _VirtualItemErrorTextStyle;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Voucher Type field.';
                }
                field(Subtype; Rec.Subtype)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the business domain of the item line. Ticket indicates the line contains a ticket item as configured in BC item setup.';
                }
                field("Membership Id"; Rec."Membership Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the membership id linked to this line.';
                    HideValue = _HideNullGuid;
                }
                field("Member First Name"; Rec."Member First Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member First Name field.';
                }
                field("Member Last Name"; Rec."Member Last Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Last Name field.';
                }
                field("Member Middle Name"; Rec."Member Middle Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Middle Name field.';
                }
                field("Member Email"; Rec."Member Email")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Email field.';
                }
                field("Member Phone No."; Rec."Member Phone No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Phone No. field.';
                }
                field("Member Birthday"; Rec."Member Birthday")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Birthday field.';
                }
                field("Member Gender"; Rec."Member Gender")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Gender field.';
                }
                field("Member Address"; Rec."Member Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Address field.';
                }
                field("Member City"; Rec."Member City")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member City field.';
                }
                field("Member Country"; Rec."Member Country")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Country field.';
                }
                field("Member Post Code"; Rec."Member Post Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Post Code field.';
                }
                field("Member Newsletter"; Rec."Member Newsletter")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Newsletter field.';
                }
                field("Member GDPR Approval"; Rec."Member GDPR Approval")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member GDPR Approval field.';
                }
                field("Membership Activation Date"; Rec."Membership Activation Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Membership Activation Date field.';
                }
            }
            group(Control28)
            {
                ShowCaption = false;
                field("Total Amount"; _EcomSalesHeader."Amount")
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = _Currency.Code;
                    AutoFormatType = 1;
                    CaptionClass = _EcomSalesDocUtils.GetTotalAmountCaption(_Currency.Code);
                    Caption = 'Total Amount';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Total Amount field.';

                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ProcessVoucher)
            {
                Caption = 'Process Virtual Item';
                ApplicationArea = NPRRetail;
                Image = NewItem;
                ToolTip = 'Process Virtual Item';
                Visible = _VirtualItemActionVisibility;
                trigger OnAction()
                var
                    EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
                begin
                    EcomVirtualItemMgt.ProcessVirtualItemLineWithConfirmation(Rec);
                end;
            }
        }
    }



    trigger OnAfterGetCurrRecord()
    begin
        GetGlobals();
        _VirtualItemActionVisibility := Rec."Document Type" = Rec."Document Type"::Order;
    end;

    trigger OnAfterGetRecord()
    begin
        GetStyles();
        _HideNullGuid := IsNullGuid(Rec."Membership Id");
    end;

    var
        _EcomSalesHeader: Record "NPR Ecom Sales Header";
        _Currency: Record Currency;

        _EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        _VirtualItemActionVisibility: Boolean;
        _HideNullGuid: Boolean;
        _VirtualItemProcessingStatusStyle: Text;
        _VirtualItemErrorTextStyle: Text;

    local procedure GetGlobals()
    begin
        _EcomSalesHeader.SetAutoCalcFields("Amount");
        if not _EcomSalesHeader.Get(Rec."Document Entry No.") then
            Clear(_EcomSalesHeader);

        if not _Currency.Get(_EcomSalesHeader."Currency Code") then
            Clear(_Currency);
    end;

    local procedure GetStyles()
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        _VirtualItemProcessingStatusStyle := EcomVirtualItemMgt.GetVirtualItemProcessingStatusStyle(Rec);
        _VirtualItemErrorTextStyle := EcomVirtualItemMgt.GetVirtualItemErrorTextStyle(Rec);
    end;
}
#endif