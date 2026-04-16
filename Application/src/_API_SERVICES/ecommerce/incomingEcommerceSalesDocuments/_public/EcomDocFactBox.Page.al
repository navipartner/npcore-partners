#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185130 "NPR Ecom Doc FactBox"
{
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Ecom Sales Header";
    Caption = 'Ecommerce Sales Document Factbox';

    layout
    {
        area(Content)
        {
            group(processingInformation)
            {
                ShowCaption = false;
                group(General)
                {
                    Caption = 'General';
                    field("Creation Status"; Rec."Creation Status")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Creation Status field.';
                        StyleExpr = _CreationStatusStyleText;

                    }
                    field("Created Doc No"; Rec."Created Doc No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Created Document No. field.';
                        trigger OnDrillDown()
                        var
                            EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                        begin
                            EcomSalesDocUtils.OpenCreatedDocumentFromEcomSalesHeader(Rec);
                        end;
                    }
                    field("Created Date"; Rec."Created Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Created Date field.';
                    }
                    field("Created Time"; Rec."Created Time")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Created Time field.';
                    }
                    field("Created By User Name"; Rec."Created By User Name")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Creted By User Name field.';
                    }
                    field("API Version Date"; Rec."API Version Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the API Version Date field.';
                    }
                    field("Requested API Version Date"; Rec."Requested API Version Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Requested API Version Date field.';
                    }
                    field("Bucket Id"; Rec."Bucket Id")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Bucket Id field.';
                    }

                }
                group("Virtual Items")
                {
                    Caption = 'Virtual Items';
                    field("Virtual Items Exist"; Rec."Virtual Items Exist")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies whether virtual items exist on this ecommerce document.';
                        trigger OnDrillDown()
                        begin
                            _EcomVirtualItemMgt.OpenEcomVirtualItemLines(Rec);
                        end;
                    }
                    field("Virtual Items Proccess Status"; Rec."Virtual Items Process Status")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Virtual Item Processing Status field.';
                        StyleExpr = _VirtualItemProcessingStatusStyleText;
                        trigger OnDrillDown()
                        begin
                            _EcomVirtualItemMgt.OpenEcomVirtualItemLines(Rec);
                        end;
                    }
                    field("Capture Processing Status"; Rec."Capture Processing Status")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Capture Processing Status field.';
                        StyleExpr = _CaptureProcessingStatusStyleText;
                        trigger OnDrillDown()
                        begin
                            _EcomVirtualItemMgt.OpenEcomCapturedLines(Rec);
                        end;
                    }
                    field("Last Capture Error Message"; Rec."Last Capture Error Message")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Last Capture Error Message field.';
                        StyleExpr = _CaptureErrorStyleText;
                        trigger OnDrillDown()
                        begin
                            Message(Rec."Last Capture Error Message");
                        end;
                    }
                    field("Capture Retry Count"; Rec."Capture Retry Count")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Capture Retry Count field.';
                    }

                    group(Tickets)
                    {
                        Caption = 'Tickets';

                        field("Ticket Exists"; Rec."Tickets Exist")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies whether tickets exist for this document.';
                            trigger OnDrillDown()
                            begin
                                _EcomVirtualItemMgt.OpenEcomTicketLines(Rec);
                            end;
                        }
                        field("Ticket Processing Status"; Rec."Ticket Processing Status")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Ticket Processing Status field.';
                            StyleExpr = _TicketProcessingStatusStyleText;
                            trigger OnDrillDown()
                            begin
                                _EcomVirtualItemMgt.OpenEcomTicketLines(Rec);
                            end;
                        }
                        field("Ticket Reservation Token"; Rec."Ticket Reservation Token")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the reservation token for virtual tickets.';
                        }
                    }

                    group(Vouchers)
                    {
                        Caption = 'Vouchers';

                        field("Voucher Exists"; Rec."Vouchers Exist")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies whether vouchers exist for this document.';
                            trigger OnDrillDown()
                            begin
                                _EcomVirtualItemMgt.OpenEcomVoucherLines(Rec);
                            end;
                        }
                        field("Voucher Processing Status"; Rec."Voucher Processing Status")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the voucher processing status.';
                            StyleExpr = _VoucherProcessingStatusStyleText;
                            trigger OnDrillDown()
                            begin
                                _EcomVirtualItemMgt.OpenEcomVoucherLines(Rec);
                            end;
                        }
                    }
                    group(Memberships)
                    {
                        Caption = 'Memberships';
                        field("Memberships Exist"; Rec."Memberships Exist")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Memberships Exist field.';
                            trigger OnDrillDown()
                            begin
                                _EcomVirtualItemMgt.OpenEcomMembershipLines(Rec);
                            end;
                        }
                        field("Membership Processing Status"; Rec."Membership Processing Status")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Membership Processing Status field.';
                            StyleExpr = _MembershipProcessingStatusStyleText;
                            trigger OnDrillDown()
                            begin
                                _EcomVirtualItemMgt.OpenEcomMembershipLines(Rec);
                            end;
                        }
                    }
                    group(Coupons)
                    {
                        Caption = 'Coupons';

                        field("Coupons Exist"; Rec."Coupons Exist")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies whether coupons exist for this document.';
                            trigger OnDrillDown()
                            var
                                EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
                            begin
                                EcomVirtualItemMgt.OpenEcomCouponLines(Rec);
                            end;
                        }
                        field("Coupon Processing Status"; Rec."Coupon Processing Status")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the coupon processing status.';
                            StyleExpr = _CouponProcessingStatusStyleText;
                            trigger OnDrillDown()
                            var
                                EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
                            begin
                                EcomVirtualItemMgt.OpenEcomCouponLines(Rec);
                            end;
                        }
                    }
                    group(Wallets)
                    {
                        Caption = 'Attraction Wallets';

                        field("Attraction Wallets Exist"; Rec."Attraction Wallets Exist")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies whether attraction wallets exist for this document.';
                            trigger OnDrillDown()
                            var
                                EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
                            begin
                                EcomVirtualItemMgt.OpenEcomWalletLines(Rec);
                            end;
                        }
                        field("Attr. Wallet Processing Status"; Rec."Attr. Wallet Processing Status")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the attraction wallet processing status.';
                            StyleExpr = _WalletProcessingStatusStyleText;
                            trigger OnDrillDown()
                            var
                                EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
                            begin
                                EcomVirtualItemMgt.OpenEcomWalletLines(Rec);
                            end;
                        }
                    }
                    group("Error")
                    {
                        Caption = 'Error';
                        field("Last Error Message"; Rec."Last Error Message")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Error Message field.';
                            StyleExpr = _ErrorInformationStyleText;
                            trigger OnDrillDown()
                            begin
                                Message(Rec."Last Error Message");
                            end;
                        }
                        field("Error Date"; Rec."Last Error Date")
                        {
                            ApplicationArea = NPRRetail;
                            StyleExpr = _ErrorInformationStyleText;
                            ToolTip = 'Specifies the value of the Last Error Date field.';
                        }
                        field("Error Time"; Rec."Last Error Time")
                        {
                            ApplicationArea = NPRRetail;
                            StyleExpr = _ErrorInformationStyleText;
                            ToolTip = 'Specifies the value of the Last Error Time field.';
                        }
                        field("Error Received By User Name"; Rec."Last Error Rcvd By User Name")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Error Received By User Name field.';
                            StyleExpr = _ErrorInformationStyleText;
                        }
                        field("Process Retry Count"; Rec."Process Retry Count")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Process Retry Count field.';
                            StyleExpr = _ErrorInformationStyleText;
                        }
                    }
                    group(Receive)
                    {
                        Caption = 'Receive';
                        field(ReceivedDate; Rec."Received Date")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Received Date field.';
                        }
                        field(ReceivedTime; Rec."Received Time")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Received Time field.';
                        }
                        field(ReceivedByUserName; GetSystemReceivedByUserName())
                        {
                            Caption = 'Received By User Name';
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Received By User Name field.';
                        }
                    }
                    group(Payment)
                    {
                        Caption = 'Payment';
                        field("Payment Amount"; Rec."Payment Amount")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Payment Amount field.';

                        }
                        field("Captured Payment Amount"; Rec."Captured Payment Amount")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Captured Payment Amount field.';
                        }
                        field("Invoiced Payment Amount"; Rec."Invoiced Payment Amount")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Captured Payment Amount field.';
                        }
                    }
                    group(Sale)
                    {
                        Caption = 'Sale';
                        field("Posting Status"; Rec."Posting Status")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Posting Status field.';
                        }
                        field(Amount; Rec.Amount)
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Amount field.';
                        }
                        field("Invoiced Amount"; Rec."Invoiced Amount")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the value of the Invoiced Amount field.';
                        }
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetStyles();
    end;

    local procedure GetSystemReceivedByUserName() UserName: Code[50]
    var
        User: Record User;
    begin
        User.SetLoadFields("User Name");
        if not User.Get(Rec.SystemCreatedBy) then
            exit;

        UserName := User."User Name";
    end;

    local procedure GetStyles()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        _CouponProcessingStatusStyleText := _EcomVirtualItemMgt.GetCouponProcessingStatusStyle(Rec);
        _CreationStatusStyleText := EcomSalesDocUtils.GetIncEcomSalesHeaderCreationStatusStyle(Rec);
        _ErrorInformationStyleText := EcomSalesDocUtils.GetIncEcomSalesHeaderErrorInformationStyle(Rec);
        _VoucherProcessingStatusStyleText := _EcomVirtualItemMgt.GetVoucherProcessingStatusStyle(Rec);
        _TicketProcessingStatusStyleText := _EcomVirtualItemMgt.GetTicketProcessingStatusStyle(Rec);
        _CaptureProcessingStatusStyleText := _EcomVirtualItemMgt.GetCaptureProcessingStatusStyle(Rec);
        _CaptureErrorStyleText := _EcomVirtualItemMgt.GetCaptureErrorStyle(Rec);
        _VirtualItemProcessingStatusStyleText := _EcomVirtualItemMgt.GetVirtualItemProcessingStatusStyle(Rec);
        _MembershipProcessingStatusStyleText := _EcomVirtualItemMgt.GetMembershipProcessingStatusStyle(Rec);
        _WalletProcessingStatusStyleText := _EcomVirtualItemMgt.GetWalletProcessingStatusStyle(Rec);
    end;

    var
        _EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        _CouponProcessingStatusStyleText: Text;
        _CreationStatusStyleText: Text;
        _ErrorInformationStyleText: Text;
        _VoucherProcessingStatusStyleText: Text;
        _TicketProcessingStatusStyleText: Text;
        _CaptureProcessingStatusStyleText: Text;
        _CaptureErrorStyleText: Text;
        _VirtualItemProcessingStatusStyleText: Text;
        _MembershipProcessingStatusStyleText: Text;
        _WalletProcessingStatusStyleText: Text;
}
#endIf