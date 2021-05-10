/// <summary>
/// POS Lookup Types map logical lookup data sets (typically tables, or filtered tables) and provide
/// implementation of that logic through the IPOSLookupType interface.
/// </summary>
enum 6014470 "NPR POS Lookup Type" implements "NPR IPOSLookupType"
{
    Caption = 'POS Lookup Type';

    /// <summary>
    /// Bank Deposit Bin Code (in Balancing Screen)
    /// </summary>
    value(0; BankDepositBinCode)
    {
        Caption = 'Bank Deposit Bin Code';
        Implementation = "NPR IPOSLookupType" = "NPR Lookup: BankDepositBinCode";
    }
}
