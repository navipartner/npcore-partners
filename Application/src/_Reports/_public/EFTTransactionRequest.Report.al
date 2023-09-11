report 6014493 "NPR EFT Transaction Request"
{
#if (BC17 or BC18 or BC19)
    UsageCategory = None;
#else
    Extensible = true;
    ApplicationArea = NPRRetail;
    Caption = 'EFT Transaction Request Excel';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "Excel Layout";

    dataset
    {
        dataitem(NPREFTTransactionRequest; "NPR EFT Transaction Request")
        {
            column(Entry_No; "Entry No.")
            {
            }
            column(Token_; Token)
            {
            }
            column(Integration_Type; "Integration Type")
            {
            }
            column(Pepper_Terminal_Code; "Pepper Terminal Code")
            {
            }
            column(Pepper_Transaction_Type_Code; "Pepper Transaction Type Code")
            {
            }
            column(Pepper_Trans_Subtype_Code; "Pepper Trans. Subtype Code")
            {
            }
            column(Started_; Started)
            {
            }
            column(Finished_; Finished)
            {
            }
            column(User_ID; "User ID")
            {
            }
            column(Integration_Version_Code; "Integration Version Code")
            {
            }
            column(Sales_Ticket_No; "Sales Ticket No.")
            {
            }
            column(Sales_ID; "Sales ID")
            {
            }
            column(Sales_Line_No; "Sales Line No.")
            {
            }
            column(Sales_Line_ID; "Sales Line ID")
            {
            }
            column(POS_Description; "POS Description")
            {
            }
            column(Register_No; "Register No.")
            {
            }
            column(POS_Payment_Type_Code; "POS Payment Type Code")
            {
            }
            column(Original_POS_Payment_Type_Code; "Original POS Payment Type Code")
            {
            }
            column(Result_Code; "Result Code")
            {
            }
            column(Card_Type; "Card Type")
            {
            }
            column(Card_Name; "Card Name")
            {
            }
            column(Card_Issuer_ID; "Card Issuer ID")
            {
            }
            column(Card_Application_ID; "Card Application ID")
            {
            }
            column(Track_Presence_Input; "Track Presence Input")
            {
            }
            column(Card_Information_Input; "Card Information Input")
            {
            }
            column(Card_Expiry_Date; "Card Expiry Date")
            {
            }
            column(Reference_Number_Input; "Reference Number Input")
            {
            }
            column(Reference_Number_Output; "Reference Number Output")
            {
            }
            column(Acquirer_ID; "Acquirer ID")
            {
            }
            column(Reconciliation_ID; "Reconciliation ID")
            {
            }
            column(Authorisation_Number; "Authorisation Number")
            {
            }
            column(Hardware_ID; "Hardware ID")
            {
            }
            column(Transaction_Date; "Transaction Date")
            {
            }
            column(Transaction_Time; "Transaction Time")
            {
            }
            column(Payment_Instrument_Type; "Payment Instrument Type")
            {
            }
            column(Authentication_Method; "Authentication Method")
            {
            }
            column(Signature_Type; "Signature Type")
            {
            }
            column(Financial_Impact; "Financial Impact")
            {
            }
            column(Mode_; Mode)
            {
            }
            column(Successful_; Successful)
            {
            }
            column(Result_Description; "Result Description")
            {
            }
            column(Bookkeeping_Period; "Bookkeeping Period")
            {
            }
            column(Result_Display_Text; "Result Display Text")
            {
            }
            column(Amount_Input; "Amount Input")
            {
            }
            column(Amount_Output; "Amount Output")
            {
            }
            column(Result_Amount; "Result Amount")
            {
            }
            column(Currency_Code; "Currency Code")
            {
            }
            column(Cashback_Amount; "Cashback Amount")
            {
            }
            column(Fee_Amount; "Fee Amount")
            {
            }
            column(Fee_Line_ID; "Fee Line ID")
            {
            }
            column(Tip_Amount; "Tip Amount")
            {
            }
            column(Tip_Line_ID; "Tip Line ID")
            {
            }
            column(Offline_mode; "Offline mode")
            {
            }
            column(Client_Assembly_Version; "Client Assembly Version")
            {
            }
            column(No_of_Reprints; "No. of Reprints")
            {
            }
            column(Receipt_1; "Receipt 1")
            {
            }
            column(Receipt_2; "Receipt 2")
            {
            }
            column(Logs_; Logs)
            {
            }
            column(Processing_Type; "Processing Type")
            {
            }
            column(Processed_Entry_No; "Processed Entry No.")
            {
            }
            column(NST_Error; "NST Error")
            {
            }
            column(Client_Error; "Client Error")
            {
            }
            column(Force_Closed; "Force Closed")
            {
            }
            column(Reversed_; Reversed)
            {
            }
            column(Reversed_by_Entry_No; "Reversed by Entry No.")
            {
            }
            column(Number_of_Attempts; "Number of Attempts")
            {
            }
            column(Initiated_from_Entry_No; "Initiated from Entry No.")
            {
            }
            column(External_Result_Known; "External Result Known")
            {
            }
            column(Auto_Voidable; "Auto Voidable")
            {
            }
            column(Manual_Voidable; "Manual Voidable")
            {
            }
            column(Recoverable_; Recoverable)
            {
            }
            column(Recovered_; Recovered)
            {
            }
            column(Recovered_by_Entry_No; "Recovered by Entry No.")
            {
            }
            column(Auxiliary_Operation_ID; "Auxiliary Operation ID")
            {
            }
            column(Auxiliary_Operation_Desc; "Auxiliary Operation Desc.")
            {
            }
            column(External_Transaction_ID; "External Transaction ID")
            {
            }
            column(External_Customer_ID; "External Customer ID")
            {
            }
            column(External_Customer_ID_Provider; "External Customer ID Provider")
            {
            }
            column(External_Payment_Token; "External Payment Token")
            {
            }
            column(Additional_Info; "Additional Info")
            {
            }
            column(DCC_Used; "DCC Used")
            {
            }
            column(DCC_Currency_Code; "DCC Currency Code")
            {
            }
            column(DCC_Amount; "DCC Amount")
            {
            }
            column(Self_Service; "Self Service")
            {
            }
            column(Stored_Value_Account_Type; "Stored Value Account Type")
            {
            }
            column(Stored_Value_Provider; "Stored Value Provider")
            {
            }
            column(Stored_Value_ID; "Stored Value ID")
            {
            }
            column(Internal_Customer_ID; "Internal Customer ID")
            {
            }
            column(Result_Processed; "Result Processed")
            {
            }
            column(Matched_in_Reconciliation; "Matched in Reconciliation")
            {
            }
            column(FF_Moved_to_POS_Entry; "FF Moved to POS Entry")
            {
            }
            column(Duration_; DurationOfTransaction)
            {
            }
            column(CountOfFailedTransaction_; CountOfFailedTransaction)
            {
            }
            column(CountOfSuccessfulTransaction_; CountOfSuccessfulTransaction)
            {
            }
            column(PercentageSuccess_; PercentageSuccess)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Clear(CountOfFailedTransaction);
                Clear(CountOfSuccessfulTransaction);

                DurationOfTransaction := Finished - Started;

                if Successful then
                    CountOfSuccessfulTransaction := 1
                else
                    CountOfFailedTransaction := 1;

                PercentageSuccess := CountOfSuccessfulTransaction / (CountOfSuccessfulTransaction + CountOfFailedTransaction);
            end;
        }
    }
    rendering
    {
        layout("Excel Layout")
        {
            Caption = 'Excel layout to display and work with data from table NPR EFT Transaction Request';
            LayoutFile = './src/_Reports/layouts/EFT Transaction Request.xlsx';
            Type = Excel;
        }
    }
    var
        DurationOfTransaction: Duration;
        CountOfFailedTransaction: Integer;
        CountOfSuccessfulTransaction: Integer;
        PercentageSuccess: Decimal;
#endif
}