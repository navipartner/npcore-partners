page 6059965 "NPR MPOS Proxy"
{
    // NPR5.31/CLVA/20161018 CASE 251922 Page created.
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    UsageCategory = None;
    Caption = ' ';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            // AL-Conversion: TODO #361608 - AL: Problems with NaviPartner.POS.JSBridge addin.
        }
    }

    actions
    {
    }

    var
        mPOSAdyenTransactions: Record "NPR MPOS Adyen Transactions";
        NotImplementedError: Label 'Action %1 not implemented';
        BigTextVar: BigText;
        Ostream: OutStream;
        RequestData: Text;
        IStream: InStream;
        Provider: Option NETS,ADYEN;
        mPOSNetsTransactions: Record "NPR MPOS Nets Transactions";

    procedure SetState(var mPOSAdyenTransactionsIn: Record "NPR MPOS Adyen Transactions"; var mPOSNetsTransactionsIn: Record "NPR MPOS Nets Transactions")
    begin
        mPOSAdyenTransactions := mPOSAdyenTransactionsIn;
        mPOSNetsTransactions := mPOSNetsTransactionsIn;
    end;

    procedure SetProvider(ProviderIn: Option NETS,ADYEN)
    begin
        Provider := ProviderIn;
    end;
}

