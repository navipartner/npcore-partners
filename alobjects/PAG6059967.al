page 6059967 "MPOS Nets Transactions Card"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.45/CLVA/20180828 CASE 324506 Added receipt data to page
    // NPR5.51/CLVA/20190819 CASE 364011 Added field "EFT Transaction Entry No."

    Caption = 'MPOS Nets Transactions Card';
    SourceTable = "MPOS Nets Transactions";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Transaction No.";"Transaction No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sales Line No.";"Sales Line No.")
                {
                }
                field("Session Id";"Session Id")
                {
                }
                field("Merchant Reference";"Merchant Reference")
                {
                }
                field("Payment Amount In Cents";"Payment Amount In Cents")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Created Date";"Created Date")
                {
                }
                field("Modify Date";"Modify Date")
                {
                }
                field(Amount;Amount)
                {
                }
                field(Handled;Handled)
                {
                }
                field("Transaction Type";"Transaction Type")
                {
                }
                field("Payment Gateway";"Payment Gateway")
                {
                }
                field("Merchant Id";"Merchant Id")
                {
                }
                field("EFT Transaction Entry No.";"EFT Transaction Entry No.")
                {
                }
            }
            group("Callback Data")
            {
                Caption = 'Callback Data';
                field("Callback Result";"Callback Result")
                {
                }
                field("Callback AccumulatorUpdate";"Callback AccumulatorUpdate")
                {
                }
                field("Callback IssuerId";"Callback IssuerId")
                {
                }
                field("Callback TruncatedPan";"Callback TruncatedPan")
                {
                }
                field("Callback EncryptedPan";"Callback EncryptedPan")
                {
                }
                field("Callback Timestamp";"Callback Timestamp")
                {
                }
                field("Callback VerificationMethod";"Callback VerificationMethod")
                {
                }
                field("Callback SessionNumber";"Callback SessionNumber")
                {
                }
                field("Callback StanAuth";"Callback StanAuth")
                {
                }
                field("Callback SequenceNumber";"Callback SequenceNumber")
                {
                }
                field("Callback TotalAmount";"Callback TotalAmount")
                {
                }
                field("Callback TipAmount";"Callback TipAmount")
                {
                }
                field("Callback SurchargeAmount";"Callback SurchargeAmount")
                {
                }
                field("Callback TerminalID";"Callback TerminalID")
                {
                }
                field("Callback AcquiereMerchantID";"Callback AcquiereMerchantID")
                {
                }
                field("Callback CardIssuerName";"Callback CardIssuerName")
                {
                }
                field("Callback TCC";"Callback TCC")
                {
                }
                field("Callback AID";"Callback AID")
                {
                }
                field("Callback TVR";"Callback TVR")
                {
                }
                field("Callback TSI";"Callback TSI")
                {
                }
                field("Callback ATC";"Callback ATC")
                {
                }
                field("Callback AED";"Callback AED")
                {
                }
                field("Callback IAC";"Callback IAC")
                {
                }
                field("Callback OrganisationNumber";"Callback OrganisationNumber")
                {
                }
                field("Callback BankAgent";"Callback BankAgent")
                {
                }
                field("Callback AccountType";"Callback AccountType")
                {
                }
                field("Callback OptionalData";"Callback OptionalData")
                {
                }
                field("Callback ResponseCode";"Callback ResponseCode")
                {
                }
                field("Callback RejectionSource";"Callback RejectionSource")
                {
                }
                field("Callback RejectionReason";"Callback RejectionReason")
                {
                }
                field("Callback MerchantReference";"Callback MerchantReference")
                {
                }
                field("Callback StatusDescription";"Callback StatusDescription")
                {
                }
            }
            group(Data)
            {
                Caption = 'Data';
                field(RequestData;RequestData)
                {
                    Caption = 'Request';
                    Editable = false;
                    MultiLine = true;
                }
                field(ResponseData;ResponseData)
                {
                    Caption = 'Response';
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(Receipt)
            {
                Caption = 'Receipt';
                field(ReceiptData1;ReceiptData1)
                {
                    Caption = 'ReceiptData1';
                    Editable = false;
                    MultiLine = true;
                }
                field(ReceiptData2;ReceiptData2)
                {
                    Caption = 'ReceiptData2';
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Request Json","Response Json","Callback Receipt 1","Callback Receipt 2");

        if not "Request Json".HasValue then
          RequestData := ''
        else begin
          "Request Json".CreateInStream(IStream);
          IStream.Read(RequestData,MaxStrLen(RequestData));
        end;

        if not "Response Json".HasValue then
          ResponseData := ''
        else begin
          "Response Json".CreateInStream(IStream);
          IStream.Read(ResponseData,MaxStrLen(ResponseData));
        end;

        if not "Callback Receipt 1".HasValue then
          ReceiptData1 := ''
        else begin
          "Callback Receipt 1".CreateInStream(IStream);
          IStream.Read(ReceiptData1,MaxStrLen(ReceiptData1));
        end;

        if not "Callback Receipt 2".HasValue then
          ReceiptData2 := ''
        else begin
          "Callback Receipt 2".CreateInStream(IStream);
          IStream.Read(ReceiptData2,MaxStrLen(ReceiptData2));
        end;
    end;

    var
        RequestData: Text;
        IStream: InStream;
        OStream: OutStream;
        ResponseData: Text;
        ReceiptData1: Text;
        ReceiptData2: Text;
}

