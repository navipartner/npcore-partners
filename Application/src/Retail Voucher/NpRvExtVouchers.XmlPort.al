xmlport 6151011 "NPR NpRv Ext. Vouchers"
{
    Caption = 'Global Vouchers';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/external_voucher_service';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(vouchers)
        {
            MaxOccurs = Once;
            tableelement(nprvextvoucherbuffer; "NPR NpRv Ext. Voucher Buffer")
            {
                MinOccurs = Zero;
                XmlName = 'voucher';
                UseTemporary = true;
                fieldattribute(document_no; NpRvExtVoucherBuffer."Document No.")
                {
                }
                fieldattribute(reference_no; NpRvExtVoucherBuffer."Reference No.")
                {
                }
                fieldelement(voucher_type; NpRvExtVoucherBuffer."Voucher Type")
                {
                    MinOccurs = Zero;
                }
                fieldelement(description; NpRvExtVoucherBuffer.Description)
                {
                    MinOccurs = Zero;
                }
                fieldelement(starting_date; NpRvExtVoucherBuffer."Starting Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ending_date; NpRvExtVoucherBuffer."Ending Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(account_no; NpRvExtVoucherBuffer."Account No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(allow_topup; NpRvExtVoucherBuffer."Allow Top-up")
                {
                    MinOccurs = Zero;
                }
                fieldelement(open; NpRvExtVoucherBuffer.Open)
                {
                    MinOccurs = Zero;
                }
                fieldelement(amount; NpRvExtVoucherBuffer.Amount)
                {
                    MinOccurs = Zero;
                }
                fieldelement("in-use_quantity"; NpRvExtVoucherBuffer."In-use Quantity")
                {
                    MinOccurs = Zero;
                }
                fieldelement(name; NpRvExtVoucherBuffer.Name)
                {
                    MinOccurs = Zero;
                }
                fieldelement(name_2; NpRvExtVoucherBuffer."Name 2")
                {
                    MinOccurs = Zero;
                }
                fieldelement(address; NpRvExtVoucherBuffer.Address)
                {
                    MinOccurs = Zero;
                }
                fieldelement(address_2; NpRvExtVoucherBuffer."Address 2")
                {
                    MinOccurs = Zero;
                }
                fieldelement(post_code; NpRvExtVoucherBuffer."Post Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(city; NpRvExtVoucherBuffer.City)
                {
                    MinOccurs = Zero;
                }
                fieldelement(county; NpRvExtVoucherBuffer.County)
                {
                    MinOccurs = Zero;
                }
                fieldelement(country_code; NpRvExtVoucherBuffer."Country/Region Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(send_via_print; NpRvExtVoucherBuffer."Send via Print")
                {
                    MinOccurs = Zero;
                }
                fieldelement(email; NpRvExtVoucherBuffer."E-mail")
                {
                    MinOccurs = Zero;
                }
                fieldelement(send_via_email; NpRvExtVoucherBuffer."Send via E-mail")
                {
                    MinOccurs = Zero;
                }
                fieldelement(phone_no; NpRvExtVoucherBuffer."Phone No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(send_via_sms; NpRvExtVoucherBuffer."Send via SMS")
                {
                    MinOccurs = Zero;
                }
                fieldelement(voucher_message; NpRvExtVoucherBuffer."Voucher Message")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_date; NpRvExtVoucherBuffer."Issue Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_register_no; NpRvExtVoucherBuffer."Issue Register No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_sales_ticket_no; NpRvExtVoucherBuffer."Issue Sales Ticket No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_user_id; NpRvExtVoucherBuffer."Issue User ID")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_date; NpRvExtVoucherBuffer."Redeem Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_register_no; NpRvExtVoucherBuffer."Redeem Register No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_sales_ticket_no; NpRvExtVoucherBuffer."Redeem Sales Ticket No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_user_id; NpRvExtVoucherBuffer."Redeem User ID")
                {
                    MinOccurs = Zero;
                }
                textelement(voucheritems)
                {
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                    tableelement(voucheritem; "NPR NpRv ExtVoucherItem Buffer")
                    {
                        UseTemporary = true;
                        MinOccurs = Zero;
                        LinkTable = nprvextvoucherbuffer;
                        LinkFields = "Voucher Reference No." = field("Reference No.");
                        fieldattribute(voucheritem_no; voucheritem."No.")
                        {
                        }
                        trigger OnBeforeInsertRecord()
                        begin
                            EntryNo += 1;
                            voucheritem."Entry No." := EntryNo;
                            voucheritem."Voucher Reference No." := NpRvExtVoucherBuffer."Reference No.";
                            if (not CheckItemCanBeUsedWithVoucher(voucheritem."No.", NpRvExtVoucherBuffer."Reference No.")) or (not NpRvExtVoucherBuffer."Voucher Has Item Limitations") then
                                currXMLport.Skip();
                        end;
                    }
                    trigger OnBeforePassVariable()
                    begin
                        if not NpRvExtVoucherBuffer."Voucher Has Item Limitations" then
                            currXMLport.Skip();
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin
                    LineNo += 1000;
                    NpRvExtVoucherBuffer."Line No." := LineNo;
                    if CheckIfPaymentMethodItemsExistVoucher(NpRvExtVoucherBuffer."Reference No.") then
                        NpRvExtVoucherBuffer."Voucher Has Item Limitations" := true;
                end;
            }
        }
    }

    var
        LineNo: Integer;
        EntryNo: Integer;

    internal procedure GetSourceTable(var NpRvExtVoucherBuffer2: Record "NPR NpRv Ext. Voucher Buffer" temporary; var TempNPRNpRvExtVoucherItemBuffer: Record "NPR NpRv ExtVoucherItem Buffer" temporary)
    begin
        GetSourceTable(NpRvExtVoucherBuffer2);
        TempNPRNpRvExtVoucherItemBuffer.Copy(voucheritem, true);
    end;

    internal procedure GetSourceTable(var NpRvExtVoucherBuffer2: Record "NPR NpRv Ext. Voucher Buffer" temporary)
    begin
        NpRvExtVoucherBuffer2.Copy(NpRvExtVoucherBuffer, true);
    end;

    internal procedure SetSourceTable(var NpRvExtVoucherBuffer2: Record "NPR NpRv Ext. Voucher Buffer" temporary)
    begin
        NpRvExtVoucherBuffer.Copy(NpRvExtVoucherBuffer2, true);
    end;

    local procedure CheckItemCanBeUsedWithVoucher(ItemNo: Code[20]; ReferenceNo: Text[50]): Boolean
    var
        Item: Record Item;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSPaymentMethodCode: Code[10];
    begin
        if not Item.Get(ItemNo) then
            exit(false);
        POSPaymentMethodCode := NpRvVoucherMgt.GetVoucherPaymentMethod(ReferenceNo);
        if POSPaymentMethodCode = '' then
            exit(false);
        if NpRvVoucherMgt.CheckVoucherCanBeUsedWithItem(POSPaymentMethodCode, Item."No.", Item."Item Category Code") then
            exit(true);
    end;

    local procedure CheckIfPaymentMethodItemsExistVoucher(ReferenceNo: Text[50]) HasItemFilter: Boolean
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        PaymentMethodCode: Code[10];
    begin
        PaymentMethodCode := NpRvVoucherMgt.GetVoucherPaymentMethod(ReferenceNo);
        if PaymentMethodCode = '' then
            exit;

        HasItemFilter := POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(PaymentMethodCode);
    end;
}