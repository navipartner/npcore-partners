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
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("Session Id"; "Session Id")
                {
                    ApplicationArea = All;
                }
                field("Merchant Reference"; "Merchant Reference")
                {
                    ApplicationArea = All;
                }
                field("Payment Amount In Cents"; "Payment Amount In Cents")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                }
                field("Modify Date"; "Modify Date")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Gateway"; "Payment Gateway")
                {
                    ApplicationArea = All;
                }
                field("Merchant Id"; "Merchant Id")
                {
                    ApplicationArea = All;
                }
                field("EFT Transaction Entry No."; "EFT Transaction Entry No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Callback Data")
            {
                Caption = 'Callback Data';
                field("Callback Result"; "Callback Result")
                {
                    ApplicationArea = All;
                }
                field("Callback AccumulatorUpdate"; "Callback AccumulatorUpdate")
                {
                    ApplicationArea = All;
                }
                field("Callback IssuerId"; "Callback IssuerId")
                {
                    ApplicationArea = All;
                }
                field("Callback TruncatedPan"; "Callback TruncatedPan")
                {
                    ApplicationArea = All;
                }
                field("Callback EncryptedPan"; "Callback EncryptedPan")
                {
                    ApplicationArea = All;
                }
                field("Callback Timestamp"; "Callback Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Callback VerificationMethod"; "Callback VerificationMethod")
                {
                    ApplicationArea = All;
                }
                field("Callback SessionNumber"; "Callback SessionNumber")
                {
                    ApplicationArea = All;
                }
                field("Callback StanAuth"; "Callback StanAuth")
                {
                    ApplicationArea = All;
                }
                field("Callback SequenceNumber"; "Callback SequenceNumber")
                {
                    ApplicationArea = All;
                }
                field("Callback TotalAmount"; "Callback TotalAmount")
                {
                    ApplicationArea = All;
                }
                field("Callback TipAmount"; "Callback TipAmount")
                {
                    ApplicationArea = All;
                }
                field("Callback SurchargeAmount"; "Callback SurchargeAmount")
                {
                    ApplicationArea = All;
                }
                field("Callback TerminalID"; "Callback TerminalID")
                {
                    ApplicationArea = All;
                }
                field("Callback AcquiereMerchantID"; "Callback AcquiereMerchantID")
                {
                    ApplicationArea = All;
                }
                field("Callback CardIssuerName"; "Callback CardIssuerName")
                {
                    ApplicationArea = All;
                }
                field("Callback TCC"; "Callback TCC")
                {
                    ApplicationArea = All;
                }
                field("Callback AID"; "Callback AID")
                {
                    ApplicationArea = All;
                }
                field("Callback TVR"; "Callback TVR")
                {
                    ApplicationArea = All;
                }
                field("Callback TSI"; "Callback TSI")
                {
                    ApplicationArea = All;
                }
                field("Callback ATC"; "Callback ATC")
                {
                    ApplicationArea = All;
                }
                field("Callback AED"; "Callback AED")
                {
                    ApplicationArea = All;
                }
                field("Callback IAC"; "Callback IAC")
                {
                    ApplicationArea = All;
                }
                field("Callback OrganisationNumber"; "Callback OrganisationNumber")
                {
                    ApplicationArea = All;
                }
                field("Callback BankAgent"; "Callback BankAgent")
                {
                    ApplicationArea = All;
                }
                field("Callback AccountType"; "Callback AccountType")
                {
                    ApplicationArea = All;
                }
                field("Callback OptionalData"; "Callback OptionalData")
                {
                    ApplicationArea = All;
                }
                field("Callback ResponseCode"; "Callback ResponseCode")
                {
                    ApplicationArea = All;
                }
                field("Callback RejectionSource"; "Callback RejectionSource")
                {
                    ApplicationArea = All;
                }
                field("Callback RejectionReason"; "Callback RejectionReason")
                {
                    ApplicationArea = All;
                }
                field("Callback MerchantReference"; "Callback MerchantReference")
                {
                    ApplicationArea = All;
                }
                field("Callback StatusDescription"; "Callback StatusDescription")
                {
                    ApplicationArea = All;
                }
            }
            group(Data)
            {
                Caption = 'Data';
                field(RequestData; RequestData)
                {
                    ApplicationArea = All;
                    Caption = 'Request';
                    Editable = false;
                    MultiLine = true;
                }
                field(ResponseData; ResponseData)
                {
                    ApplicationArea = All;
                    Caption = 'Response';
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(Receipt)
            {
                Caption = 'Receipt';
                field(ReceiptData1; ReceiptData1)
                {
                    ApplicationArea = All;
                    Caption = 'ReceiptData1';
                    Editable = false;
                    MultiLine = true;
                }
                field(ReceiptData2; ReceiptData2)
                {
                    ApplicationArea = All;
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
        CalcFields("Request Json", "Response Json", "Callback Receipt 1", "Callback Receipt 2");

        if not "Request Json".HasValue then
            RequestData := ''
        else begin
            "Request Json".CreateInStream(IStream);
            IStream.Read(RequestData, MaxStrLen(RequestData));
        end;

        if not "Response Json".HasValue then
            ResponseData := ''
        else begin
            "Response Json".CreateInStream(IStream);
            IStream.Read(ResponseData, MaxStrLen(ResponseData));
        end;

        if not "Callback Receipt 1".HasValue then
            ReceiptData1 := ''
        else begin
            "Callback Receipt 1".CreateInStream(IStream);
            IStream.Read(ReceiptData1, MaxStrLen(ReceiptData1));
        end;

        if not "Callback Receipt 2".HasValue then
            ReceiptData2 := ''
        else begin
            "Callback Receipt 2".CreateInStream(IStream);
            IStream.Read(ReceiptData2, MaxStrLen(ReceiptData2));
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

