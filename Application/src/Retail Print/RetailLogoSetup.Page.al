page 6014566 "NPR Retail Logo Setup"
{
    Extensible = False;

    Caption = 'Retail Logo Setup';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Retail Logo";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            usercontrol("NPR ResizeImage"; "NPR ResizeImage")
            {
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Sequence field';
                    ApplicationArea = NPRRetail;
                }
                field(Keyword; Rec.Keyword)
                {

                    ToolTip = 'Specifies the value of the Keyword field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {

                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; Rec."End Date")
                {

                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Boca Compatible"; Rec.OneBitLogo.HasValue())
                {

                    Caption = 'Boca Compatible';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Boca Compatible field';
                    ApplicationArea = NPRRetail;
                }
            }

        }
        area(factboxes)
        {
            part(Control6150624; "NPR Retail Logo Factbox")
            {
                SubPageLink = Sequence = FIELD(Sequence);
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Import Logo action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Export Logo action';
                ApplicationArea = NPRRetail;

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

