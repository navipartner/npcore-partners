/// <summary>
/// POS Lookup Types map logical lookup data sets (typically tables, or filtered tables) and provide
/// implementation of that logic through the IPOSLookupType interface.
/// </summary>
enum 6014470 "NPR POS Lookup Type" implements "NPR IPOSLookupType"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Caption = 'POS Lookup Type';

    /// <summary>
    /// Bank Deposit Bin Code (in Balancing Screen)
    /// </summary>
    value(0; BankDepositBinCode)
    {
        Caption = 'Bank Deposit Bin Code';
        Implementation = "NPR IPOSLookupType" = "NPR Lookup: BankDepositBinCode";
    }

    /// <summary>
    /// Item (for lookup dialogs)
    /// </summary>
    value(1; Item)
    {
        Caption = 'Item';
        Implementation = "NPR IPOSLookupType" = "NPR Lookup: Item";
    }

    /// <summary>
    /// Customer (for lookup dialogs)
    /// </summary>
    value(2; Customer)
    {
        Caption = 'Customer';
        Implementation = "NPR IPOSLookupType" = "NPR Lookup: Customer";
    }
}
