page 6059967 "NPR MPOS Nets Trans. Card"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.45/CLVA/20180828 CASE 324506 Added receipt data to page
    // NPR5.51/CLVA/20190819 CASE 364011 Added field "EFT Transaction Entry No."

    UsageCategory = None;
    Caption = 'MPOS Nets Transactions Card';
    SourceTable = "NPR MPOS Nets Transactions";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("Session Id"; "Session Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session Id field';
                }
                field("Merchant Reference"; "Merchant Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Reference field';
                }
                field("Payment Amount In Cents"; "Payment Amount In Cents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Amount In Cents field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Modify Date"; "Modify Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Date field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled field';
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type field';
                }
                field("Payment Gateway"; "Payment Gateway")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Gateway field';
                }
                field("Merchant Id"; "Merchant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                }
                field("EFT Transaction Entry No."; "EFT Transaction Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EFT Transaction Entry No. field';
                }
            }
            group("Callback Data")
            {
                Caption = 'Callback Data';
                field("Callback Result"; "Callback Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback Result field';
                }
                field("Callback AccumulatorUpdate"; "Callback AccumulatorUpdate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback AccumulatorUpdate field';
                }
                field("Callback IssuerId"; "Callback IssuerId")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback IssuerId field';
                }
                field("Callback TruncatedPan"; "Callback TruncatedPan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TruncatedPan field';
                }
                field("Callback EncryptedPan"; "Callback EncryptedPan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback EncryptedPan field';
                }
                field("Callback Timestamp"; "Callback Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback Timestamp field';
                }
                field("Callback VerificationMethod"; "Callback VerificationMethod")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback VerificationMethod field';
                }
                field("Callback SessionNumber"; "Callback SessionNumber")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback SessionNumber field';
                }
                field("Callback StanAuth"; "Callback StanAuth")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback StanAuth field';
                }
                field("Callback SequenceNumber"; "Callback SequenceNumber")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback SequenceNumber field';
                }
                field("Callback TotalAmount"; "Callback TotalAmount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TotalAmount field';
                }
                field("Callback TipAmount"; "Callback TipAmount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TipAmount field';
                }
                field("Callback SurchargeAmount"; "Callback SurchargeAmount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback SurchargeAmount field';
                }
                field("Callback TerminalID"; "Callback TerminalID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TerminalID field';
                }
                field("Callback AcquiereMerchantID"; "Callback AcquiereMerchantID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback AcquiereMerchantID field';
                }
                field("Callback CardIssuerName"; "Callback CardIssuerName")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback CardIssuerName field';
                }
                field("Callback TCC"; "Callback TCC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TCC field';
                }
                field("Callback AID"; "Callback AID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback AID field';
                }
                field("Callback TVR"; "Callback TVR")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TVR field';
                }
                field("Callback TSI"; "Callback TSI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback TSI field';
                }
                field("Callback ATC"; "Callback ATC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback ATC field';
                }
                field("Callback AED"; "Callback AED")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback AED field';
                }
                field("Callback IAC"; "Callback IAC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback IAC field';
                }
                field("Callback OrganisationNumber"; "Callback OrganisationNumber")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback OrganisationNumber field';
                }
                field("Callback BankAgent"; "Callback BankAgent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback BankAgent field';
                }
                field("Callback AccountType"; "Callback AccountType")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback AccountType field';
                }
                field("Callback OptionalData"; "Callback OptionalData")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback OptionalData field';
                }
                field("Callback ResponseCode"; "Callback ResponseCode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback ResponseCode field';
                }
                field("Callback RejectionSource"; "Callback RejectionSource")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback RejectionSource field';
                }
                field("Callback RejectionReason"; "Callback RejectionReason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback RejectionReason field';
                }
                field("Callback MerchantReference"; "Callback MerchantReference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback MerchantReference field';
                }
                field("Callback StatusDescription"; "Callback StatusDescription")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Callback StatusDescription field';
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
                    ToolTip = 'Specifies the value of the Request field';
                }
                field(ResponseData; ResponseData)
                {
                    ApplicationArea = All;
                    Caption = 'Response';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Response field';
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
                    ToolTip = 'Specifies the value of the ReceiptData1 field';
                }
                field(ReceiptData2; ReceiptData2)
                {
                    ApplicationArea = All;
                    Caption = 'ReceiptData2';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the ReceiptData2 field';
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

