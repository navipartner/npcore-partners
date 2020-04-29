report 6014463 "Document Processing Status"
{
    // NPR5.39/THRO/20180222 CASE 302597 Report created
    DefaultLayout = RDLC;
    RDLCLayout = './Document Processing Status.rdlc';

    Caption = 'Document Processing Status';

    dataset
    {
        dataitem(SalesInvoiceHeader;"Sales Invoice Header")
        {
            RequestFilterFields = "No.","Posting Date","Document Processing";
            column(IncludeCrMemo;IncludeCrMemo)
            {
            }
            column(ShowOnlyNotSent;ShowOnlyNotSent)
            {
            }
            column(InvoiceNo;SalesInvoiceHeader."No.")
            {
                IncludeCaption = true;
            }
            column(InvoiceBillToNo;SalesInvoiceHeader."Bill-to Customer No.")
            {
                IncludeCaption = true;
            }
            column(InvoiceBillToName;SalesInvoiceHeader."Bill-to Name")
            {
                IncludeCaption = true;
            }
            column(InvoiceDocumentProcessing;SalesInvoiceHeader."Document Processing")
            {
                IncludeCaption = true;
            }
            column(InvoiceStatusMsg;StatusMsg)
            {
            }
            column(StatusMsgCaption;StatusMsgCaptionTxt)
            {
            }
            column(InvoiceIsSent;IsSent)
            {
            }
            column(IsSentCaption;IsSentCaptionTxt)
            {
            }

            trigger OnAfterGetRecord()
            begin
                StatusMsg := '';
                IsSent := false;

                case SalesInvoiceHeader."Document Processing" of
                  0 : begin //Print
                        StatusMsg := StrSubstNo(PrintedStatusTxt,SalesInvoiceHeader."No. Printed");
                        IsSent := SalesInvoiceHeader."No. Printed" > 0;
                      end;
                  1 : begin  //Email,OIO,PrintAndEmail
                        Clear(EmailLog);
                        EmailLog.SetRange("Table No.",112);
                        EmailLog.SetRange("Primary Key",SalesInvoiceHeader.GetPosition(false));
                        IsSent := EmailLog.FindLast;
                        if IsSent then
                          StatusMsg := StrSubstNo(EmailStatusTxt,EmailLog."Sent Date",EmailLog."Recipient E-mail")
                        else
                          StatusMsg := NoEmailSentTxt;
                      end;
                  2 : begin
                        NPRDocLocalizationProxy.T112_GetFieldValue (SalesInvoiceHeader, 'Electronic Invoice Created', VariantVal);
                        if VariantVal.IsBoolean then
                          IsSent := VariantVal;
                      end;
                  3 : begin
                        Clear(EmailLog);
                        EmailLog.SetRange("Table No.",112);
                        EmailLog.SetRange("Primary Key",SalesInvoiceHeader.GetPosition(false));
                        IsSent := EmailLog.FindLast;
                        if IsSent then
                          StatusMsg := StrSubstNo(EmailStatusTxt,EmailLog."Sent Date",EmailLog."Recipient E-mail") + ' '
                        else
                          StatusMsg := NoEmailSentTxt + ' ';
                        StatusMsg += StrSubstNo(PrintedStatusTxt,SalesInvoiceHeader."No. Printed");
                        IsSent := IsSent and (SalesInvoiceHeader."No. Printed" > 0);
                      end;
                end;

                if not IsSent then begin
                  SalesInvoiceHeader.CalcFields(Amount);
                  if SalesInvoiceHeader.Amount = 0 then begin
                    if StatusMsg <> '' then
                      StatusMsg += ' ';
                    StatusMsg += TotalIsZeroTxt;
                  end;
                end;

                if IsSent and ShowOnlyNotSent then
                  CurrReport.Skip;
            end;
        }
        dataitem("Sales Cr.Memo Header";"Sales Cr.Memo Header")
        {
            column(CrMemoNo;"Sales Cr.Memo Header"."No.")
            {
            }
            column(CrMemoBillToNo;"Sales Cr.Memo Header"."Bill-to Customer No.")
            {
            }
            column(CrMemoBillToName;"Sales Cr.Memo Header"."Bill-to Name")
            {
            }
            column(CrMemoDocumentProcessing;"Sales Cr.Memo Header"."Document Processing")
            {
            }
            column(CrMemoStatusMsg;StatusMsg)
            {
            }
            column(CrMemoIsSent;IsSent)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if not IncludeCrMemo then
                  CurrReport.Break;
                StatusMsg := '';
                IsSent := false;

                case "Sales Cr.Memo Header"."Document Processing" of
                  0 : begin //Print
                        StatusMsg := StrSubstNo(PrintedStatusTxt,"Sales Cr.Memo Header"."No. Printed");
                        IsSent := "Sales Cr.Memo Header"."No. Printed" > 0;
                      end;
                  1 : begin  //Email,OIO,PrintAndEmail
                        Clear(EmailLog);
                        EmailLog.SetRange("Table No.",114);
                        EmailLog.SetRange("Primary Key","Sales Cr.Memo Header".GetPosition(false));
                        IsSent := EmailLog.FindLast;
                        if IsSent then
                          StatusMsg := StrSubstNo(EmailStatusTxt,EmailLog."Sent Date",EmailLog."Recipient E-mail")
                        else
                          StatusMsg := NoEmailSentTxt;
                      end;
                  2 : begin
                        NPRDocLocalizationProxy.T114_GetFieldValue ("Sales Cr.Memo Header", 'Electronic Invoice Created', VariantVal);
                        if VariantVal.IsBoolean then
                          IsSent := VariantVal;
                      end;
                  3 : begin
                        Clear(EmailLog);
                        EmailLog.SetRange("Table No.",114);
                        EmailLog.SetRange("Primary Key","Sales Cr.Memo Header".GetPosition(false));
                        IsSent := EmailLog.FindLast;
                        if IsSent then
                          StatusMsg := StrSubstNo(EmailStatusTxt,EmailLog."Sent Date",EmailLog."Recipient E-mail") + ' '
                        else
                          StatusMsg := NoEmailSentTxt + ' ';
                        StatusMsg += StrSubstNo(PrintedStatusTxt,"Sales Cr.Memo Header"."No. Printed");
                        IsSent := IsSent and ("Sales Cr.Memo Header"."No. Printed" > 0);
                      end;
                end;

                if not IsSent then begin
                  "Sales Cr.Memo Header".CalcFields(Amount);
                  if "Sales Cr.Memo Header".Amount = 0 then begin
                    if StatusMsg <> '' then
                      StatusMsg += ' ';
                    StatusMsg += TotalIsZeroTxt;
                  end;
                end;

                if IsSent and ShowOnlyNotSent then
                  CurrReport.Skip;
            end;

            trigger OnPreDataItem()
            begin
                if not IncludeCrMemo then
                  CurrReport.Break;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowOnlyNotSent;ShowOnlyNotSent)
                    {
                        Caption = 'Show Only Not Sent Documents';
                    }
                    field(DocType;IncludeCrMemo)
                    {
                        Caption = 'Include Credit Memos';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        ReportCaption = 'Document Processing Status';
        PageNoCaption = 'Page';
        IncoiceLbl = 'Invoices';
        CrMemoLbl = 'Credit Memos';
    }

    var
        EmailLog: Record "E-mail Log";
        NPRDocLocalizationProxy: Codeunit "NPR Doc. Localization Proxy";
        ShowOnlyNotSent: Boolean;
        IncludeCrMemo: Boolean;
        StatusMsg: Text;
        IsSent: Boolean;
        PrintedStatusTxt: Label 'Printed %1 times.';
        EmailStatusTxt: Label 'Mail sent %1 to %2.';
        NoEmailSentTxt: Label 'No Mail sent.';
        TotalIsZeroTxt: Label 'Total Amount is 0. Deleted document?';
        VariantVal: Variant;
        StatusMsgCaptionTxt: Label 'Status';
        IsSentCaptionTxt: Label 'Document is sent';
}

