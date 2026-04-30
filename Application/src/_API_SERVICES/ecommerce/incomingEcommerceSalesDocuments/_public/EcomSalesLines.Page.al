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
                field("External Line ID"; Rec."External Line ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Line ID field.';
                }
                field("Parent Ext. Line ID"; Rec."Parent Ext. Line ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Parent Ext. Line ID field.';
                }
                field(Subtype; Rec.Subtype)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the business domain of the item line. Ticket indicates the line contains a ticket item as configured in BC item setup.';
                }
                field("Virtual Item Process Status"; Rec."Virtual Item Process Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Virtual Item Process Status field.';
                    StyleExpr = _VirtualItemProcessingStatusStyle;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        EcomCreateCouponProcess: Codeunit "NPR EcomCreateCouponProcess";
                        EcomCreateTicketProcess: Codeunit "NPR EcomCreateTicketProcess";
                        EcomCreateVchrProcess: Codeunit "NPR EcomCreateVchrProcess";
                        NoErrorMsg: Label 'No virtual item processing error message was recorded for the document line.';
                    begin
                        case Rec."Virtual Item Process Status" of
                            Rec."Virtual Item Process Status"::Error:
                                if Rec."Virtual Item Process ErrMsg" <> '' then
                                    Message(Rec."Virtual Item Process ErrMsg")
                                else
                                    Message(NoErrorMsg);

                            Rec."Virtual Item Process Status"::Processed:
                                case Rec.Subtype of
                                    Rec.Subtype::Coupon:
                                        EcomCreateCouponProcess.ShowRelatedCouponsAction(Rec);
                                    Rec.Subtype::Ticket:
                                        EcomCreateTicketProcess.ShowRelatedTicketsAction(Rec);
                                    Rec.Subtype::Voucher:
                                        EcomCreateVchrProcess.ShowRelatedVouchersAction(Rec);
                                end;
                        end;
                    end;
                }
                field("Virtual Item Process ErrMsg"; Rec."Virtual Item Process ErrMsg")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Virtual Item Process ErrMsg field.';
                    StyleExpr = _VirtualItemProcessingStatusStyle;
                }
                field("Is Attraction Wallet"; Rec."Is Attraction Wallet")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Indicates whether the line represents an attraction wallet parent line.';
                }
                field("Attr. Wallets Processing Status"; Rec."Attr. Wallet Processing Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the attraction wallet processing status.';
                    StyleExpr = _WalletProcessingStatusStyleText;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
                    begin
                        case Rec."Attr. Wallet Processing Status" of
                            Rec."Attr. Wallet Processing Status"::Error:
                                ShowWalletErrorMessage();
                            Rec."Attr. Wallet Processing Status"::Processed:
                                EcomCreateWalletMgt.ShowRelatedWallets(Database::"NPR Ecom Sales Line", Rec.SystemId);
                        end;
                    end;
                }
                field("Attr. Wallet Retry Count"; Rec."Attr. Wallet Retry Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of times processing has been retried for this attraction wallet line.';
                    Visible = false;
                }
                field("Attr. Wallet Process ErrMsg"; Rec."Attr. Wallet Process ErrMsg")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Attr. Wallet Process Error Message';
                    ToolTip = 'Specifies the error message if there was an error when processing this attraction wallet line.';
                    AssistEdit = true;
                    Visible = false;
                    StyleExpr = _WalletProcessingStatusStyleText;

                    trigger OnAssistEdit()
                    begin
                        ShowWalletErrorMessage();
                    end;
                }
                field("Membership Operation"; Rec."Membership Operation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Membership Operation field.';
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
        _HideNullGuid := IsNullGuid(Rec."Membership Id");
    end;

    var
        _VirtualItemProcessingStatusStyle: Text;
        _WalletProcessingStatusStyleText: Text;
        _HideNullGuid: Boolean;

    local procedure GetStyles()
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        _VirtualItemProcessingStatusStyle := EcomVirtualItemMgt.GetVirtualItemProcessingStatusStyle(Rec);
        _WalletProcessingStatusStyleText := EcomVirtualItemMgt.GetWalletProcessingStatusStyle(Rec);
    end;

    local procedure ShowWalletErrorMessage()
    var
        NoErrorMsg: Label 'No wallet processing error message was recorded for the document line.';
    begin
        if Rec."Attr. Wallet Process ErrMsg" <> '' then
            Message(Rec."Attr. Wallet Process ErrMsg")
        else
            Message(NoErrorMsg);
    end;
}
#endIf