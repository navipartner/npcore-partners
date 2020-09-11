codeunit 6014699 "NPR Doc. Localization Proxy"
{
    // 
    // 
    // NOTE *** NOTE *** NOTE *** NOTE
    // This codeunit SHOULD NOT go into the any localized database.
    // This is a template proxy for accessning the localization on document tables



    trigger OnRun()
    begin

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

    local procedure GetFieldNo(TableNo: Integer; FieldName: Text[100]): Integer
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin

        FieldName := UpperCase(DelChr(FieldName, '<=>', '._:;#%&/()- '));

        case TableNo of
            DATABASE::Customer:
                case FieldName of
                    'EANNO':
                        exit(Customer.FieldNo("No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Sales Invoice Header":
                case FieldName of
                    'EANNO':
                        exit(SalesInvoiceHeader.FieldNo("Bill-to Customer No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Sales Cr.Memo Header":
                case FieldName of
                    'EANNO':
                        exit(SalesCrMemoHeader.FieldNo("Bill-to Customer No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Issued Reminder Header":
                case FieldName of
                    'EANNO':
                        exit(IssuedReminderHeader.FieldNo("Customer No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Issued Fin. Charge Memo Header":
                case FieldName of
                    'EANNO':
                        exit(IssuedFinChargeMemoHeader.FieldNo("Customer No."));
                    else
                        exit(-1);
                end;
            else
                exit(-1);
        end;
    end;

    procedure T18_GetFieldValue(Customer: Record Customer; FieldName: Text[100]; var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo(DATABASE::Customer, FieldName);

        Error(NOT_LOCALIZED);
    end;

    procedure T18_SetFieldEanNo(var Customer: Record Customer; EanNo: Text[30])
    begin

        Error(NOT_LOCALIZED);
    end;

    procedure T37_GetFieldValue(SalesLine: Record "Sales Line"; FieldName: Text[100]; var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo(DATABASE::"Sales Line", FieldName);

        Error(NOT_LOCALIZED);
    end;

    procedure T37_SetAccountCode(var SalesLine: Record "Sales Line"; AccountCode: Text[30])
    begin

        Error(NOT_LOCALIZED);
    end;

    procedure T112_GetFieldValue(SalesInvoiceHeader: Record "Sales Invoice Header"; FieldName: Text[100]; var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo(DATABASE::"Sales Invoice Header", FieldName);

        Error(NOT_LOCALIZED);
    end;

    procedure T114_GetFieldValue(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; FieldName: Text[100]; var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo(DATABASE::"Sales Cr.Memo Header", FieldName);

        Error(NOT_LOCALIZED);
    end;

    procedure T297_GetFieldValue(IssuedReminderHeader: Record "Issued Reminder Header"; FieldName: Text[100]; var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo(DATABASE::"Issued Reminder Header", FieldName);

        Error(NOT_LOCALIZED);
    end;

    procedure T304_GetFieldValue(IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; FieldName: Text[100]; var Value: Variant)
    var
        FieldNo: Integer;
    begin

        FieldNo := GetFieldNo(DATABASE::"Issued Fin. Charge Memo Header", FieldName);

        Error(NOT_LOCALIZED);
    end;

    procedure PrintXMLDocument(SalesHeader: Record "Sales Header")
    begin

        Error(NOT_LOCALIZED);

    end;

    procedure SaveXMLDocument(Type: Option "Sales Order","Sales Invoice","Sales Return Order","Sales Credit Memo"; DocumentNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        Error(NOT_LOCALIZED);

    end;

    procedure ValidateXMLDocumentCountryCode(NaviDocsEntry: Record "NPR NaviDocs Entry"; Country: Record "Country/Region"): Boolean
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        Error010: Label 'The length on the associated OIOIXML Country Code %1 must be 2 for %2!';
    begin

        Error(NOT_LOCALIZED);

    end;

    procedure ExportSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin

    end;

    procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin

    end;
}

