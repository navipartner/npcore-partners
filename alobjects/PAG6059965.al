page 6059965 "MPOS Proxy"
{
    // NPR5.31/CLVA/20161018 CASE 251922 Page created.
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = ' ';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            usercontrol(JSBridge;"NaviPartner.POS.JSBridge")
            {

                trigger ControlAddInReady()
                begin
                    mPOSAdyenTransactions.CalcFields("Request Json");
                    mPOSNetsTransactions.CalcFields("Request Json");

                    case Provider of
                      Provider::ADYEN : begin
                                          if mPOSAdyenTransactions."Request Json".HasValue then begin
                                            mPOSAdyenTransactions."Request Json".CreateInStream(IStream);
                                            IStream.Read(RequestData,MaxStrLen(RequestData));
                                          end;
                                        end;
                      Provider::NETS  : begin
                                          if mPOSNetsTransactions."Request Json".HasValue then begin
                                            mPOSNetsTransactions."Request Json".CreateInStream(IStream);
                                            IStream.Read(RequestData,MaxStrLen(RequestData));
                                          end;
                                        end;
                    end;


                    //CurrPage.JSBridge.StartDebugger();
                    CurrPage.JSBridge.CallAdyenFunction(RequestData);
                end;

                trigger ActionCompleted(jsonObject: Text)
                begin
                    BigTextVar.AddText(jsonObject);

                    case Provider of
                      Provider::ADYEN : begin
                                          mPOSAdyenTransactions."Response Json".CreateOutStream(Ostream);
                                          BigTextVar.Write(Ostream);
                                          mPOSAdyenTransactions.Modify(true);
                                          Commit;
                                        end;
                      Provider::NETS  : begin
                                          mPOSNetsTransactions."Response Json".CreateOutStream(Ostream);
                                          BigTextVar.Write(Ostream);
                                          mPOSNetsTransactions.Modify(true);
                                          Commit;
                                        end;
                    end;

                    CurrPage.Close;
                end;
            }
        }
    }

    actions
    {
    }

    var
        mPOSAdyenTransactions: Record "MPOS Adyen Transactions";
        NotImplementedError: Label 'Action %1 not implemented';
        BigTextVar: BigText;
        Ostream: OutStream;
        RequestData: Text;
        IStream: InStream;
        Provider: Option NETS,ADYEN;
        mPOSNetsTransactions: Record "MPOS Nets Transactions";

    procedure SetState(var mPOSAdyenTransactionsIn: Record "MPOS Adyen Transactions";var mPOSNetsTransactionsIn: Record "MPOS Nets Transactions")
    begin
        mPOSAdyenTransactions := mPOSAdyenTransactionsIn;
        mPOSNetsTransactions := mPOSNetsTransactionsIn;
    end;

    procedure SetProvider(ProviderIn: Option NETS,ADYEN)
    begin
        Provider := ProviderIn;
    end;
}

