xmlport 6151010 "NPR NpRv Global Vouchers"
{
    Caption = 'Global Vouchers';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/global_voucher_service';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    XMLVersionNo = V11;

    schema
    {
        textelement(vouchers)
        {
            MaxOccurs = Once;
            tableelement(nprvvoucherbuffer; "NPR NpRv Voucher Buffer")
            {
                MinOccurs = Zero;
                XmlName = 'voucher';
                UseTemporary = true;
                fieldattribute(reference_no; NpRvVoucherBuffer."Reference No.")
                {
                }
                fieldattribute(voucher_type; NpRvVoucherBuffer."Voucher Type")
                {
                }
                fieldelement(description; NpRvVoucherBuffer.Description)
                {
                    MinOccurs = Zero;
                }
                fieldelement(starting_date; NpRvVoucherBuffer."Starting Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ending_date; NpRvVoucherBuffer."Ending Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(account_no; NpRvVoucherBuffer."Account No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(amount; NpRvVoucherBuffer.Amount)
                {
                    MinOccurs = Zero;
                }
                fieldelement(reserved_amount; NpRvVoucherBuffer."Reserved Amount")
                {
                    MinOccurs = Zero;
                }
                fieldelement(name; NpRvVoucherBuffer.Name)
                {
                    MinOccurs = Zero;
                }
                fieldelement(name_2; NpRvVoucherBuffer."Name 2")
                {
                    MinOccurs = Zero;
                }
                fieldelement(address; NpRvVoucherBuffer.Address)
                {
                    MinOccurs = Zero;
                }
                fieldelement(address_2; NpRvVoucherBuffer."Address 2")
                {
                    MinOccurs = Zero;
                }
                fieldelement(post_code; NpRvVoucherBuffer."Post Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(city; NpRvVoucherBuffer.City)
                {
                    MinOccurs = Zero;
                }
                fieldelement(county; NpRvVoucherBuffer.County)
                {
                    MinOccurs = Zero;
                }
                fieldelement(country_code; NpRvVoucherBuffer."Country/Region Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(email; NpRvVoucherBuffer."E-mail")
                {
                    MinOccurs = Zero;
                }
                fieldelement(phone_no; NpRvVoucherBuffer."Phone No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(voucher_message; NpRvVoucherBuffer."Voucher Message")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_date; NpRvVoucherBuffer."Issue Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_register_no; NpRvVoucherBuffer."Issue Register No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_sales_ticket_no; NpRvVoucherBuffer."Issue Sales Ticket No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_user_id; NpRvVoucherBuffer."Issue User ID")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_partner_code; NpRvVoucherBuffer."Issue Partner Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_date; NpRvVoucherBuffer."Redeem Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_register_no; NpRvVoucherBuffer."Redeem Register No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_sales_ticket_no; NpRvVoucherBuffer."Redeem Sales Ticket No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_user_id; NpRvVoucherBuffer."Redeem User ID")
                {
                    MinOccurs = Zero;
                }
                fieldelement(redeem_partner_code; NpRvVoucherBuffer."Redeem Partner Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(amount_to_reserve; NpRvVoucherBuffer."Amount to Reserve")
                {
                    MinOccurs = Zero;
                }
                fieldelement(reservation_line_id; NpRvVoucherBuffer."Reservation Line ID")
                {
                    MinOccurs = Zero;
                }
                fieldelement(global_reservation_id; NprvVoucherBuffer."Global Reservation Id")
                {
                    MinOccurs = Zero;
                }

                fieldelement(global_voucher_amt_available; NpRvVoucherBuffer."Global Voucher Amt Available")
                {
                    MinOccurs = Zero;
                }
                fieldelement(issue_posstore_code; NpRvVoucherBuffer."POS Store Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(company; NpRvVoucherBuffer.Company)
                {
                    MinOccurs = Zero;
                }
                fieldelement(global_redeem_checked; NpRvVoucherBuffer."Global Redeem Checked")
                {
                    MinOccurs = Zero;
                }
                textelement(reservation_lines)
                {
                    MinOccurs = Zero;

                    tableelement(tempNpRvSalesLine; "NPR NpRv Sales Line Buffer")
                    {
                        MinOccurs = Zero;
                        XmlName = 'reservation_line';
                        UseTemporary = true;

                        fieldelement(id_; tempNpRvSalesLine.Id)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(reservation_line_id; tempNpRvSalesLine."Reservation Line Id")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(voucher_type; tempNpRvSalesLine."Voucher Type")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(voucher_no; tempNpRvSalesLine."Voucher No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(reference_no; tempNpRvSalesLine."Reference No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amount_; tempNpRvSalesLine.Amount)
                        {
                            MinOccurs = Zero;
                        }
                    }
                }
            }
        }
    }

    procedure GetSourceTables(var TempNpRvVoucherBuffer2: Record "NPR NpRv Voucher Buffer" temporary; var TempNpRvSalesLineBuffer: Record "NPR NpRv Sales Line Buffer" temporary)
    begin
        TempNpRvVoucherBuffer2.Copy(NpRvVoucherBuffer, true);
        TempNpRvSalesLineBuffer.Copy(tempNpRvSalesLine, true);
    end;

    procedure GetSourceTable(var TempNpRvVoucherBuffer2: Record "NPR NpRv Voucher Buffer" temporary)
    begin
        TempNpRvVoucherBuffer2.Copy(NpRvVoucherBuffer, true);
    end;

    internal procedure SetSourceTable(var TempNpRvVoucherBuffer2: Record "NPR NpRv Voucher Buffer" temporary)
    begin
        NpRvVoucherBuffer.Copy(TempNpRvVoucherBuffer2, true);
    end;
}
