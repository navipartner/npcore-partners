﻿page 6151220 "NPR PrintNode Setup"
{
    Extensible = False;
    Caption = 'PrintNode Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR PrintNode Setup";
    InsertAllowed = false;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Key"; Rec."API Key")
                {

                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                Image = Confirm;

                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Test Connection action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
                begin
                    PrintNodeAPIMgt.TestConnection(true);
                end;
            }
            action(PrinterList)
            {
                Caption = 'Printer List';
                Image = PrintInstallment;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Specification of available printers';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PrintNodePrinterList: Page "NPR PrintNode Printer List";
                begin
                    PrintNodePrinterList.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}

