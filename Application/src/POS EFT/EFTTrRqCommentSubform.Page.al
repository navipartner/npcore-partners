page 6184499 "NPR EFT Tr.Rq.Comment Subform"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT
    // NPR5.46/MMV /20181003 CASE 290734 EFT Framework refactored.
    // NPR5.53/MMV /20191206 CASE 377533 Changed caption

    Caption = 'EFT Tr. Rq. Comment Subform';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR EFT Transact. Req. Comment";

    layout
    {
        area(content)
        {
            field(Receipt1Text; Receipt1Text)
            {
                ApplicationArea = All;
                DrillDown = true;
                Editable = false;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Receipt1Text field';

                trigger OnDrillDown()
                var
                    EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
                begin
                    //-NPR5.46 [290734]
                    //MESSAGE(PepperConfigMan.GetReceiptText(PepperTransactionRequest,1,TRUE));
                    EFTFrameworkMgt.DisplayReceipt(EFTTransactionRequest, 1);
                    //+NPR5.46 [290734]
                end;
            }
            field(Receipt2Text; Receipt2Text)
            {
                ApplicationArea = All;
                DrillDown = true;
                Editable = false;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Receipt2Text field';

                trigger OnDrillDown()
                var
                    EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
                begin
                    //-NPR5.46 [290734]
                    //MESSAGE(PepperConfigMan.GetReceiptText(PepperTransactionRequest,2,TRUE));
                    EFTFrameworkMgt.DisplayReceipt(EFTTransactionRequest, 2);
                    //+NPR5.46 [290734]
                end;
            }
            repeater(Group)
            {
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not EFTTransactionRequest.Get("Entry No.") then
            EFTTransactionRequest.Init;
        if EFTTransactionRequest."Receipt 1".HasValue then
            Receipt1Text := StrSubstNo(TxtClickReceipt, '1')
        else
            Receipt1Text := '';
        if EFTTransactionRequest."Receipt 2".HasValue then
            Receipt2Text := StrSubstNo(TxtClickReceipt, '2')
        else
            Receipt2Text := '';
    end;

    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Receipt1Text: Text[50];
        Receipt2Text: Text[50];
        TxtClickReceipt: Label 'Show receipt';
}

