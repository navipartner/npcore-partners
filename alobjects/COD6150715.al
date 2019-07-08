codeunit 6150715 "POS Data Driver - Exch. Rate"
{
    // NPR5.39/TSA /20180131 CASE 303052 Completely refactored to use data driver extensions


    trigger OnRun()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin

        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin

        exit('FC');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text;Extensions: DotNet List_Of_T)
    var
        MemberCommunity: Record "MM Member Community";
    begin

        if ThisDataSource <> DataSourceName then
          exit;

        Extensions.Add(ThisExtension);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet DataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        DataType: DotNet DataType;
        PaymentType: Record "Payment Type POS";
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        PaymentType.SetFilter ("Processing Type", '=%1', PaymentType."Processing Type"::"Foreign Currency");
        PaymentType.SetFilter (Status, '=%1', PaymentType.Status::Active);
        PaymentType.SetFilter ("Register No.", '=%1', '');
        if (PaymentType.FindSet ()) then begin
          repeat
            DataSource.AddColumn (PaymentType."No.", PaymentType.Description, DataType.String, false);
          until (PaymentType.Next () = 0);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet DataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        DataType: DotNet DataType;
        POSSale: Codeunit "POS Sale";
        POSPaymentLine: Codeunit "POS Payment Line";
        Setup: Codeunit "POS Setup";
        PaymentType: Record "Payment Type POS";
        PaymentType2: Record "Payment Type POS";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;
        Handled := true;

        POSSession.GetSetup (Setup);
        POSSession.GetPaymentLine (POSPaymentLine);

        POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        PaymentType.SetFilter ("Processing Type", '=%1', PaymentType."Processing Type"::"Foreign Currency");
        PaymentType.SetFilter (Status, '=%1', PaymentType.Status::Active);
        PaymentType.SetFilter ("Register No.", '=%1', '');
        if (PaymentType.FindSet ()) then begin
          repeat
            POSPaymentLine.GetPaymentType (PaymentType2, PaymentType."No.", Setup.Register);
            DataRow.Add (PaymentType2."No.", Format (POSPaymentLine.RoundAmount (PaymentType2, POSPaymentLine.CalculateForeignAmount (PaymentType2, SubTotal))));
          until (PaymentType.Next () = 0);
        end;
    end;
}

