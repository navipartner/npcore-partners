pageextension 6014464 "NPR Transfer Orders" extends "Transfer Orders"
{
    actions
    {
        modify(PostAndPrint)
        {
            Visible = PostingVisibility;
        }
        addafter(PostAndPrint)
        {
            action("NPR PostAndPrint")
            {
                Caption = 'POS Post and &Print';
                Image = PostPrint;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F9';
                Visible = PostingVisibilityPOS;
                ApplicationArea = All;
                ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    CodeunitTransferOrderPP: Codeunit "NPR TransferOrder-Post + Print";
                begin
                    if TemplateN <> '' then begin
                        CodeunitTransferOrderPP.SetParameter(TemplateN, Rec);
                        CodeunitTransferOrderPP.Run(Rec);
                    end;
                end;
            }
        }
    }

    var
        TemplateN: Text;
        PostingVisibility: Boolean;
        PostingVisibilityPOS: Boolean;
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
        Visiblitycheck: Boolean;

    procedure NPRSetValues(TemplateName: Text)
    begin
        TemplateN := TemplateName;
    end;
}

