xmlport 6151080 "ExRv Vouchers"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher

    Caption = 'Vouchers';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/voucher_service';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;
    XMLVersionNo = V11;

    schema
    {
        textelement(vouchers)
        {
            MaxOccurs = Once;
            tableelement(tempexrvvoucher; "ExRv Voucher")
            {
                MinOccurs = Zero;
                XmlName = 'voucher';
                UseTemporary = true;
                fieldattribute(voucher_type; TempExRvVoucher."Voucher Type")
                {
                }
                fieldattribute(voucher_no; TempExRvVoucher."No.")
                {
                }
                fieldelement(amount; TempExRvVoucher.Amount)
                {
                    MinOccurs = Zero;
                }
                fieldelement(issued_at; TempExRvVoucher."Issued at")
                {
                    MinOccurs = Zero;
                }
                fieldelement(reference_no; TempExRvVoucher."Reference No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(online_reference_no; TempExRvVoucher."Online Reference No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(open; TempExRvVoucher.Open)
                {
                    MinOccurs = Zero;
                }
                fieldelement(remaining_amount; TempExRvVoucher."Remaining Amount")
                {
                    MinOccurs = Zero;
                }
                fieldelement(closed_at; TempExRvVoucher."Closed at")
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

    procedure GetSourceTable(var TempExRvVoucherCopy: Record "ExRv Voucher" temporary)
    begin
        TempExRvVoucherCopy.Copy(TempExRvVoucher, true);
    end;

    procedure SetSourceTable(var NewTempExRvVoucher: Record "ExRv Voucher" temporary)
    begin
        TempExRvVoucher.Copy(NewTempExRvVoucher, true);
    end;
}

