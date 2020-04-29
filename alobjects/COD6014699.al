codeunit 6014699 "NPR Doc. Localization Proxy"
{
    // 
    // NPRX.xx/TSA/2015073/CASE 216800 - Initial version of the proxy to separate DK and W1 NPR version
    // 
    // NOTE *** NOTE *** NOTE *** NOTE
    // This codeunit SHOULD NOT go into the any localized database.
    // This is a template proxy for accessning the localization on document tables
    // NPR5.38/MHA /20180105  CASE 301053 Removed unused Global Text Constant, -- Test Toolset


    trigger OnRun()
    begin

        TestFunctions ();
    end;

    var
        NOT_IMPLEMENTED: Label 'Translation for field %1 on table %2 has not been implemented.';
        NOT_LOCALIZED: Label 'The NPR Document Localization is not available in the W1 version of NPR';
        IsTrueFailedMsg: Label 'Assert.IsTrue failed. %1';
        IsFalseFailedMsg: Label 'Assert.IsFalse failed. %1';
        AreEqualFailedMsg: Label 'Assert.AreEqual failed. Expected:<%1>. Actual:<%2>. %3';
        AreNotEqualFailedMsg: Label 'Assert.AreNotEqual failed. Expected any value except:<%1>. Actual:<%2>. %3';
        AreNearlyEqualFailedMsg: Label 'Assert.AreNearlyEqual failed. Expected a difference no greater than <%1> between expected value <%2> and actual value <%3>. %4';
        AreNotNearlyEqualFailedMsg: Label 'Assert.AreNotNearlyEqual failed. Expected a difference greater than <%1> between expected value <%2> and actual value <%3>. %4';
        FailFailedMsg: Label 'Assert.Fail failed. %1';
        KnowFailureFailedMsg: Label 'Assert.KnownFailure failed. %1';
        KnownFailureMsg: Label 'Known failure: %1';
        UnsupportedTypeMsg: Label 'Equality assertions only support Boolean, Option, Integer, Decimal, Code, Text, Date, and Time values.';

    local procedure GetFieldNo(TableNo: Integer;FieldName: Text[100]): Integer
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin

        FieldName := UpperCase (DelChr (FieldName, '<=>', '._:;#%&/()- '));

        case TableNo of
          DATABASE::Customer :
            case FieldName of
              'EANNO'                     : exit (Customer.FieldNo ("No."));
            else exit (-1);
            end;
          DATABASE::"Sales Invoice Header" :
            case FieldName of
              'EANNO'                    : exit (SalesInvoiceHeader.FieldNo ("Bill-to Customer No."));
              else exit (-1);
            end;
          DATABASE::"Sales Cr.Memo Header" :
            case FieldName of
              'EANNO'                       : exit (SalesCrMemoHeader.FieldNo ("Bill-to Customer No."));
              else exit (-1);
            end;
          DATABASE::"Issued Reminder Header" :
            case FieldName of
              'EANNO'                     : exit (IssuedReminderHeader.FieldNo ("Customer No."));
              else exit (-1);
            end;
          DATABASE::"Issued Fin. Charge Memo Header" :
            case FieldName of
              'EANNO'                    : exit (IssuedFinChargeMemoHeader.FieldNo ("Customer No."));
              else exit (-1);
            end;
          else exit (-1);
        end;
    end;

    procedure T18_GetFieldValue(Customer: Record Customer;FieldName: Text[100];var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo (DATABASE::Customer, FieldName);

        Error (NOT_LOCALIZED);
    end;

    procedure T18_SetFieldEanNo(var Customer: Record Customer;EanNo: Text[30])
    begin

        Error (NOT_LOCALIZED);
    end;

    procedure T37_GetFieldValue(SalesLine: Record "Sales Line";FieldName: Text[100];var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo (DATABASE::"Sales Line", FieldName);

        Error (NOT_LOCALIZED);
    end;

    procedure T37_SetAccountCode(var SalesLine: Record "Sales Line";AccountCode: Text[30])
    begin

        Error (NOT_LOCALIZED);
    end;

    procedure T112_GetFieldValue(SalesInvoiceHeader: Record "Sales Invoice Header";FieldName: Text[100];var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo (DATABASE::"Sales Invoice Header", FieldName);

        Error (NOT_LOCALIZED);
    end;

    procedure T114_GetFieldValue(SalesCrMemoHeader: Record "Sales Cr.Memo Header";FieldName: Text[100];var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo (DATABASE::"Sales Cr.Memo Header", FieldName);

        Error (NOT_LOCALIZED);
    end;

    procedure T297_GetFieldValue(IssuedReminderHeader: Record "Issued Reminder Header";FieldName: Text[100];var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo (DATABASE::"Issued Reminder Header", FieldName);

        Error (NOT_LOCALIZED);
    end;

    procedure T304_GetFieldValue(IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";FieldName: Text[100];var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo (DATABASE::"Issued Fin. Charge Memo Header", FieldName);

        Error (NOT_LOCALIZED);
    end;

    procedure PrintXMLDocument(SalesHeader: Record "Sales Header")
    begin

        Error (NOT_LOCALIZED);

        //WITH SalesHeader DO BEGIN
        //  IF "EAN No." <> '' THEN BEGIN
        //    CASE "Document Type" OF
        //      "Document Type"::Order : SaveXMLDocument(0,"Last Posting No.");
        //      "Document Type"::Invoice:
        //        BEGIN
        //          IF "Last Posting No." = '' THEN
        //            SaveXMLDocument(1,"No.")
        //          ELSE
        //            SaveXMLDocument(1,"Last Posting No.");
        //        END;
        //      "Document Type"::"Return Order": SaveXMLDocument(2,"Last Posting No.");
        //      "Document Type"::"Credit Memo":
        //        BEGIN
        //          IF "Last Posting No." = '' THEN
        //            SaveXMLDocument(3,"No.")
        //          ELSE
        //            SaveXMLDocument(3,"Last Posting No.");
        //        END;
        //    END;
        //  END;
        //END;
    end;

    procedure SaveXMLDocument(Type: Option "Sales Order","Sales Invoice","Sales Return Order","Sales Credit Memo";DocumentNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        Error (NOT_LOCALIZED);

        //-PN1.03
        //CASE Type OF
        //  Type::"Sales Order",Type::"Sales Invoice":
        //    BEGIN
        //      IF SalesInvHeader.GET(DocumentNo) THEN
        //        OIOUBLExportSalesInvoice.RUN(SalesInvHeader);
        //    END;
        //  Type::"Sales Return Order", Type::"Sales Credit Memo":
        //    BEGIN
        //      IF SalesCrMemoHeader.GET(DocumentNo) THEN
        //        OIOUBLExportSalesCrMemo.RUN(SalesCrMemoHeader);
        //    END;
        //END;
        //+PN1.03
    end;

    procedure ValidateXMLDocumentCountryCode(NaviDocsEntry: Record "NaviDocs Entry";Country: Record "Country/Region"): Boolean
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
        Error010: Label 'The length on the associated OIOIXML Country Code %1 must be 2 for %2!';
    begin

        Error (NOT_LOCALIZED);

        //IF STRLEN(Country."OIOUBL Country/Region Code") <> 2 THEN BEGIN
        //  NaviDocsManagement.InsertComment (NaviDocsEntry,STRSUBSTNO(Error010,Country."OIOUBL Country/Region Code",Country.Code),TRUE);
        //  EXIT(FALSE);
        //END;

        //EXIT (TRUE);
    end;

    procedure ExportSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin

        // OIOUBLExportSalesInvoice.RUN (SalesInvoiceHeader);
    end;

    procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin

        // OIOUBLExportCrMemo.RUN(SalesCrMemoHeader);
    end;

    local procedure "--"()
    begin
    end;

    local procedure TestFunctions()
    begin

        // A test function to verify PROXY Implementation

        TestCustomerProxy ();
        TestSalesInvoiceHeaderProxy ();
        TestSalesCrMemoHeaderProxy ();
        TestIssuedReminderHeaderProxy ();
        TestIssuedFinChargeMemoHeaderProxy ();

        Message ('All PROXY tests passed OK');
    end;

    local procedure TestCustomerProxy()
    var
        testCode: Code[20];
        testBool: Boolean;
        Customer: Record Customer;
        ActualValue: Variant;
    begin

        Customer.Init;

        asserterror T18_GetFieldValue (Customer, testCode, ActualValue);
    end;

    local procedure TestSalesInvoiceHeaderProxy()
    var
        testCode: Code[20];
        testBool: Boolean;
        ActualValue: Variant;
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin

        SalesInvoiceHeader.Init ();

        asserterror T112_GetFieldValue (SalesInvoiceHeader, testCode, ActualValue);
    end;

    local procedure TestSalesCrMemoHeaderProxy()
    var
        testCode: Code[20];
        testBool: Boolean;
        ActualValue: Variant;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin

        SalesCrMemoHeader.Init ();

        asserterror T114_GetFieldValue (SalesCrMemoHeader, testCode, ActualValue);
    end;

    local procedure TestIssuedReminderHeaderProxy()
    var
        testCode: Code[20];
        testBool: Boolean;
        ActualValue: Variant;
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin

        IssuedReminderHeader.Init ();

        asserterror T297_GetFieldValue (IssuedReminderHeader, testCode, ActualValue);
    end;

    local procedure TestIssuedFinChargeMemoHeaderProxy()
    var
        testCode: Code[20];
        testBool: Boolean;
        ActualValue: Variant;
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin

        IssuedFinChargeMemoHeader.Init ();

        asserterror T304_GetFieldValue (IssuedFinChargeMemoHeader, testCode, ActualValue);
    end;

    local procedure "-- Test Toolset Asserts"()
    begin
    end;

    procedure IsTrue(Condition: Boolean;Msg: Text[1024])
    begin
        if not Condition then
          Error(IsTrueFailedMsg,Msg)
    end;

    procedure IsFalse(Condition: Boolean;Msg: Text[1024])
    begin
        if Condition then
          Error(IsFalseFailedMsg,Msg)
    end;

    procedure AreEqual(Expected: Variant;Actual: Variant;Msg: Text[1024])
    begin
        if not Equal(Expected,Actual) then
          Error(AreEqualFailedMsg,Expected,Actual,Msg)
    end;

    procedure AreNotEqual(Expected: Variant;Actual: Variant;Msg: Text[1024])
    begin
        if Equal(Expected,Actual) then
          Error(AreNotEqualFailedMsg,Expected,Actual,Msg)
    end;

    procedure AreNearlyEqual(Expected: Decimal;Actual: Decimal;Delta: Decimal;Msg: Text[1024])
    begin
        if Abs(Expected - Actual) > Abs(Delta) then
          Error(AreNearlyEqualFailedMsg,Delta,Expected,Actual,Msg)
    end;

    procedure AreNotNearlyEqual(Expected: Decimal;Actual: Decimal;Delta: Decimal;Msg: Text[1024])
    begin
        if Abs(Expected - Actual) <= Abs(Delta) then
          Error(AreNotNearlyEqualFailedMsg,Delta,Expected,Actual,Msg)
    end;

    procedure Fail(Msg: Text[1024])
    begin
        Error(FailFailedMsg,Msg)
    end;

    procedure KnownFailure(Expected: Text[1024];Msg: Text[1024])
    begin
        if StrPos(GetLastErrorText,Expected) = 0 then
          Error(KnowFailureFailedMsg,GetLastErrorText);

        Error(KnownFailureMsg,Msg)
    end;

    local procedure TypeOf(Value: Variant): Integer
    var
        "Field": Record "Field";
    begin
        case true of
          Value.IsBoolean:
            exit(Field.Type::Boolean);
          Value.IsOption or Value.IsInteger:
            exit(Field.Type::Integer);
          Value.IsDecimal:
            exit(Field.Type::Decimal);
          Value.IsText or Value.IsCode:
            exit(Field.Type::Text);
          Value.IsDate:
            exit(Field.Type::Date);
          Value.IsTime:
            exit(Field.Type::Time);
          else Error(UnsupportedTypeMsg)
        end
    end;

    local procedure Equal(Left: Variant;Right: Variant): Boolean
    begin
        if IsNumber(Left) and IsNumber(Right) then
          exit(EqualNumbers(Left,Right));

        exit((TypeOf(Left) = TypeOf(Right)) and (Format(Left,0,2) = Format(Right,0,2)))
    end;

    local procedure EqualNumbers(Left: Decimal;Right: Decimal): Boolean
    begin
        exit(Left = Right)
    end;

    local procedure IsNumber(Value: Variant): Boolean
    begin
        exit(Value.IsDecimal or Value.IsInteger or Value.IsChar)
    end;
}

