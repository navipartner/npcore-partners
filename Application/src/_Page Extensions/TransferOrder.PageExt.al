pageextension 6014462 "NPR Transfer Order" extends "Transfer Order"
{
    actions
    {
        modify(PostAndPrint)
        {
            Visible = PostingVisibility;
        }
        addafter("&Print")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Retail Print action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.ChooseLabel(Rec);
                end;

            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Price Label action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelLibrary: Codeunit "NPR Label Library";
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                begin
                    LabelLibrary.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                end;
            }
        }
        addfirst("F&unctions")
        {
            action("NPR Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;

                ToolTip = 'Executes the Import From Scanner File action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ImportfromScannerFileTO: XMLport "NPR ImportFromScannerFile TO";
                begin
                    ImportfromScannerFileTO.SelectTable(Rec);
                    ImportfromScannerFileTO.SetTableView(Rec);
                    ImportfromScannerFileTO.Run();
                end;
            }
        }
        addafter("Get Bin Content")
        {
            action("NPR &Read from scanner")
            {
                Caption = '&Read from scanner';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the &Read from scanner action';
                Image = Add;
                ApplicationArea = NPRRetail;
            }
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

                ToolTip = 'Executes the POS Post and &Print action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    CodeunitTransferOrderPP: Codeunit "NPR TransferOrder-Post + Print";
                begin
                    ReportSelectionRetail.Reset();
                    ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Transfer Order");
                    if ReportSelectionRetail.FindFirst() then
                        TemplateN := ReportSelectionRetail."Print Template";
                    if TemplateN <> '' then begin
                        CodeunitTransferOrderPP.SetParameter(TemplateN, Rec);
                        CodeunitTransferOrderPP.Run(Rec);
                    end;
                end;
            }
        }
    }

    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
        PostingVisibility: Boolean;
        PostingVisibilityPOS: Boolean;
        Visiblitycheck: Boolean;
        TemplateN: Text[20];

    trigger OnOpenPage()
    begin
        Visiblitycheck := Codeunit6059823.GetValues();
        if Visiblitycheck then begin
            PostingVisibility := false;
            PostingVisibilityPOS := true;
        end else begin
            PostingVisibility := true;
            PostingVisibilityPOS := false;
        end;
    end;
}