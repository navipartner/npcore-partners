codeunit 6014699 "NPR Doc. Localization Proxy"
{
    // NOTE *** NOTE *** NOTE *** NOTE
    // This codeunit SHOULD NOT go into the any localized database.
    // This is a template proxy for accessning the localization on document tables

    var
        NotLocalizedErr: Label 'The NPR Document Localization is not available in the W1 version of NPR';

    local procedure GetFieldNo(TableNo: Integer; FieldName: Text[100]): Integer
    var
        Customer: Record Customer;
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedReminderHeader: Record "Issued Reminder Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EANNOLbl: Label 'EANNO', Locked = true;
    begin
        FieldName := UpperCase(DelChr(FieldName, '<=>', '._:;#%&/()- '));

        case TableNo of
            DATABASE::Customer:
                case FieldName of
                    EANNOLbl:
                        exit(Customer.FieldNo("No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Sales Invoice Header":
                case FieldName of
                    EANNOLbl:
                        exit(SalesInvoiceHeader.FieldNo("Bill-to Customer No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Sales Cr.Memo Header":
                case FieldName of
                    EANNOLbl:
                        exit(SalesCrMemoHeader.FieldNo("Bill-to Customer No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Issued Reminder Header":
                case FieldName of
                    EANNOLbl:
                        exit(IssuedReminderHeader.FieldNo("Customer No."));
                    else
                        exit(-1);
                end;
            DATABASE::"Issued Fin. Charge Memo Header":
                case FieldName of
                    EANNOLbl:
                        exit(IssuedFinChargeMemoHeader.FieldNo("Customer No."));
                    else
                        exit(-1);
                end;
            else
                exit(-1);
        end;
    end;

    procedure T18_GetFieldValue(Customer: Record Customer; FieldName: Text[100]; var Value: Variant)
    begin
        GetFieldNo(DATABASE::Customer, FieldName);
        Error(NotLocalizedErr);
    end;

    procedure T18_SetFieldEanNo(var Customer: Record Customer; EanNo: Text[30])
    begin
        Error(NotLocalizedErr);
    end;

    procedure T37_GetFieldValue(SalesLine: Record "Sales Line"; FieldName: Text[100]; var Value: Variant)
    begin
        GetFieldNo(DATABASE::"Sales Line", FieldName);
        Error(NotLocalizedErr);
    end;

    procedure T37_SetAccountCode(var SalesLine: Record "Sales Line"; AccountCode: Text[30])
    begin
        Error(NotLocalizedErr);
    end;

    procedure T112_GetFieldValue(SalesInvoiceHeader: Record "Sales Invoice Header"; FieldName: Text[100]; var Value: Variant)
    begin
        GetFieldNo(DATABASE::"Sales Invoice Header", FieldName);
        Error(NotLocalizedErr);
    end;

    procedure T114_GetFieldValue(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; FieldName: Text[100]; var Value: Variant)
    begin
        GetFieldNo(DATABASE::"Sales Cr.Memo Header", FieldName);
        Error(NotLocalizedErr);
    end;

    procedure T297_GetFieldValue(IssuedReminderHeader: Record "Issued Reminder Header"; FieldName: Text[100]; var Value: Variant)
    begin
        GetFieldNo(DATABASE::"Issued Reminder Header", FieldName);
        Error(NotLocalizedErr);
    end;

    procedure T304_GetFieldValue(IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; FieldName: Text[100]; var Value: Variant)
    begin
        GetFieldNo(DATABASE::"Issued Fin. Charge Memo Header", FieldName);
        Error(NotLocalizedErr);
    end;

    procedure PrintXMLDocument(SalesHeader: Record "Sales Header")
    begin
        Error(NotLocalizedErr);
    end;

    procedure SaveXMLDocument(Type: Option "Sales Order","Sales Invoice","Sales Return Order","Sales Credit Memo"; DocumentNo: Code[20])
    begin
        Error(NotLocalizedErr);
    end;

    procedure ValidateXMLDocumentCountryCode(NaviDocsEntry: Record "NPR NaviDocs Entry"; Country: Record "Country/Region"): Boolean
    begin
        Error(NotLocalizedErr);
    end;

    procedure ExportSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    procedure ExportCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;
}

