enum 6014405 "NPR CleanCash Request Type" implements "NPR CleanCash XCCSP Interface"
{
    Extensible = true;

    value(0; NotSelected)
    {
        Caption = 'Not selected';
        Implementation = "NPR CleanCash XCCSP Interface" = "NPR CleanCash XCCSP Protocol";
    }

    value(1; IdentityRequest)
    {
        Caption = 'Identity Request';
        Implementation = "NPR CleanCash XCCSP Interface" = "NPR CleanCash Identity Msg.";
    }

    value(2; StatusRequest)
    {
        Caption = 'Status Request';
        Implementation = "NPR CleanCash XCCSP Interface" = "NPR CleanCash Status Msg.";
    }

    // SKVFS 2009:1 Sales and Return Sales can not be mixed on same receipt
    value(3; RegisterSalesReceipt)
    {
        Caption = 'Register Sales Receipt';
        Implementation = "NPR CleanCash XCCSP Interface" = "NPR CleanCash Receipt Msg.";
    }
    value(4; RegisterReturnReceipt)
    {
        Caption = 'Register Return Receipt';
        Implementation = "NPR CleanCash XCCSP Interface" = "NPR CleanCash Receipt Msg.";
    }
}