page 6151239 "NPR BinTransferProfile"
{
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR Bin Transfer Profile";
    Caption = 'Bin Transfer Profile';
    Extensible = false;

    layout
    {
        area(Content)
        {
            field(SetupCode; Rec.ProfileCode)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Profile Code field.';
                Visible = false;
            }
            field(DocumentNoSeries; Rec.DocumentNoSeries)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Document No. Series field.';
            }
            field(PrintOnRelease; Rec.PrintOnRelease)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Print On Release field.';
            }
            field(ReleasePrintTemplateCode; Rec.ReleasePrintTemplateCode)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Release Print Template Code field.';
            }
            field(PrintOnReceive; Rec.PrintOnReceive)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Print On Receive field.';
            }
            field(ReceivePrintTemplateCode; Rec.ReceivePrintTemplateCode)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Receive Print Template Code field.';
            }
            field(PostToGeneralLedgerOnReceive; Rec.PostToGeneralLedgerOnReceive)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if posting to general ledger occurs when status is changed to receive.';
            }
            field(ReasonCode; Rec.ReasonCode)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the reason code that will be entered on the journal lines.';
            }

        }
    }
}