page 6014566 "NPR Retail Logo Setup"
{

    Caption = 'Retail Logo Setup';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Retail Logo";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            usercontrol("NPR ResizeImage"; "NPR ResizeImage")
            {
                ApplicationArea = All;
                trigger OnCtrlReady()
                begin
                    RetailLogoMgtCtrl.InitializeResizeImage(CurrPage."NPR ResizeImage");
                end;

                trigger returnImage(resizedImage: Text; escpos: Text)
                begin
                    RetailLogoMgtCtrl.CreateRecord(RetailLogo, resizedImage, escpos);
                end;

                trigger returnESCPOSBytes(Hi: Integer; Lo: Integer; CmdHi: Integer; CmdLo: Integer)
                begin
                    RetailLogo."ESCPOS Height Low Byte" := Lo;
                    RetailLogo."ESCPOS Height High Byte" := Hi;
                    RetailLogo."ESCPOS Cmd Low Byte" := CmdLo;
                    RetailLogo."ESCPOS Cmd High Byte" := CmdHi;
                    RetailLogo.Modify();
                end;
            }
            repeater(Group)
            {
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence field';
                }
                field(Keyword; Rec.Keyword)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keyword field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field';
                }
                field("Boca Compatible"; Rec.OneBitLogo.HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Boca Compatible';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Boca Compatible field';
                }
            }

        }
        area(factboxes)
        {
            part(Control6150624; "NPR Retail Logo Factbox")
            {
                SubPageLink = Sequence = FIELD(Sequence);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import Logo")
            {
                Caption = 'Import Logo';
                Image = Picture;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import Logo action';

                trigger OnAction()
                begin
                    RetailLogoMgtCtrl.UploadLogo();
                    CurrPage.Update();
                    if Rec.FindLast() then;
                end;
            }

            action("Export Logo")
            {
                Caption = 'Export Logo';
                Image = ExportToDo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Export Logo action';

                trigger OnAction()
                var
                    RetailLogoMgt: Codeunit "NPR Retail Logo Mgt.";
                begin
                    RetailLogoMgt.ExportImageBMP(Rec);
                end;
            }
        }
    }
    var
        RetailLogoMgtCtrl: Codeunit "NPR Retail Logo Mgt.";

        RetailLogo: Record "NPR Retail Logo";
}

