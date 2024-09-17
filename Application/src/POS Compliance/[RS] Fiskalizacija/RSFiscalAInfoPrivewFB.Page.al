page 6150853 "NPR RS Fiscal A.Info Privew FB"
{
    Caption = 'RS Fiscal Bill Preview';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR RS POS Audit Log Aux. Info";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(FiscalBill)
            {
                ShowCaption = false;
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                usercontrol(FiscalBillPreview; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#ELSE
                usercontrol(FiscalBillPreview; WebPageViewer)
#ENDIF
                {
                    ApplicationArea = NPRRSFiscal;
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        FiscalBillPreviewReady := true;
                        if FiscalBillContent <> '' then
                            CurrPage.FiscalBillPreview.SetContent(FiscalBillContent);
                    end;
                }
            }
            group(Details)
            {
                Caption = 'Fiscal Bill Details';
                field("SDC DateTime"; Rec."SDC DateTime")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the SDC Date and Time - Date and Time of fiscalization.';
                }
                field("Invoice Counter"; Rec."Invoice Counter")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Invoice Counter.';
                }
                field("Invoice Number"; Rec."Invoice Number")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Invoice Number.';
                }
                field(Mrc; Rec.Mrc)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Mrc value.';
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Requested By user.';
                }
                field("Signed By"; Rec."Signed By")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Signed By user.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Total Amount of the transaction.';
                }
                field("Total Counter"; Rec."Total Counter")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the number of the Total Counter.';
                }
                field("Verification URL"; Rec."Verification URL")
                {
                    ApplicationArea = NPRRSFiscal;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the Verification URL.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RSFiscalPreviewMgt: Codeunit "NPR RS Fiscal Preview Mgt.";
    begin
        FiscalBillContent := RSFiscalPreviewMgt.SetContentOfFiscalBillPrivew(Rec."Audit Entry No.", Rec."Audit Entry Type", Rec."Payment Method Code", false);
        if FiscalBillPreviewReady then
            CurrPage.FiscalBillPreview.SetContent(FiscalBillContent);
    end;

    var
        FiscalBillContent: Text;
        FiscalBillPreviewReady: Boolean;
}