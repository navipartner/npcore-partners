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
                usercontrol(FiscalBillPreview; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
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
                    ToolTip = 'Specifies the value of the SDC DateTime field.';
                }
                field("Invoice Counter"; Rec."Invoice Counter")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Invoice Counter field.';
                }
                field("Invoice Number"; Rec."Invoice Number")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Invoice Number field.';
                }
                field(Mrc; Rec.Mrc)
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Mrc field.';
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Requested By field.';
                }
                field("Signed By"; Rec."Signed By")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Signed By field.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
                field("Total Counter"; Rec."Total Counter")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Total Counter field.';
                }
                field("Verification URL"; Rec."Verification URL")
                {
                    ApplicationArea = NPRRSFiscal;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the Verification URL field.';
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