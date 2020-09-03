xmlport 6151010 "NPR NpRv Global Vouchers"
{
    // NPR5.42/MHA /20180521  CASE 307022 Object created - Global Retail Voucher for tenant; guldsmeddirks
    // NPR5.49/MHA /20190228  CASE 342811 Added elements <issue_partner_code>, <redeem_partner_code>

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
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    procedure GetSourceTable(var NpRvVoucherBuffer2: Record "NPR NpRv Voucher Buffer" temporary)
    begin
        NpRvVoucherBuffer2.Copy(NpRvVoucherBuffer, true);
    end;

    procedure SetSourceTable(var NpRvVoucherBuffer2: Record "NPR NpRv Voucher Buffer" temporary)
    begin
        NpRvVoucherBuffer.Copy(NpRvVoucherBuffer2, true);
    end;
}

