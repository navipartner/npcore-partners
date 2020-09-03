pageextension 6014464 "NPR Transfer Orders" extends "Transfer Orders"
{
    // NPR5.55/YAHA/20191127 CASE 362312 added Functionality to use template for printing
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F9';
                Visible = PostingVisibilityPOS;

                trigger OnAction()
                var
                    CodeunitTransferOrderPP: Codeunit "NPR TransferOrder-Post + Print";
                begin
                    //-NPR5.55 [362312]
                    if TemplateN <> '' then begin
                        CodeunitTransferOrderPP.SetParameter(TemplateN, Rec);
                        CodeunitTransferOrderPP.Run(Rec);
                    end;
                    //+NPR5.55 [362312]
                end;
            }
        }
    }

    var
        TemplateN: Text;
        TransferHdr: Record "Transfer Header";
        PostingVisibility: Boolean;
        PostingVisibilityPOS: Boolean;
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
        Visiblitycheck: Boolean;


    //Unsupported feature: Code Insertion on "OnOpenPage".

    //trigger OnOpenPage()
    //begin
    /*
    //-NPR5.55 [362312]
    Visiblitycheck := Codeunit6059823.GetValues;
    if Visiblitycheck then begin
      PostingVisibility := false;
      PostingVisibilityPOS := true;
    end else begin
      PostingVisibility := true;
      PostingVisibilityPOS := false;
    end;
    //+NPR5.55 [362312]
    */
    //end;

    procedure SetValues(TemplateName: Text; TransferHeader: Record "Transfer Header")
    begin
        //-NPR5.55 [362312]
        TemplateN := TemplateName;
        TransferHdr := TransferHeader;
        //+NPR5.55 [362312]
    end;
}

