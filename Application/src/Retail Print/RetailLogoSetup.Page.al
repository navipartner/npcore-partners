page 6014566 "NPR Retail Logo Setup"
{
    Extensible = False;

    Caption = 'Retail Logo Setup';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/retail_logo/';
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

                trigger returnImage(resizedImage: Text; escpos: Text; Hi: Integer; Lo: Integer; CmdHi: Integer; CmdLo: Integer)
                var
                    RetailLogo: Record "NPR Retail Logo";
                begin
                    RetailLogoMgtCtrl.CreateRecord(RetailLogo, resizedImage, escpos, Hi, Lo, CmdHi, CmdLo);
                end;
            }
            repeater(Group)
            {
                field(Sequence; Rec.Sequence)
                {

                    ToolTip = 'Specifies the order or priority of the retail logo';
                    ApplicationArea = NPRRetail;
                }
                field(Keyword; Rec.Keyword)
                {

                    ToolTip = 'Specifies the keyword used to display the logo in a Retail Print Template.';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the POS unit code associated with the retail logo.';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {

                    ToolTip = 'Specifies the first date on which the retail logo will be displayed.';
                    ApplicationArea = NPRRetail;
                }
                field("End Date"; Rec."End Date")
                {

                    ToolTip = 'Specifies the last date on which the retail logo will be displayed.';
                    ApplicationArea = NPRRetail;
                }
                field("Boca Compatible"; Rec.OneBitLogo.HasValue())
                {

                    Caption = 'Boca Compatible';
                    Editable = false;
                    ToolTip = 'Specifies if the logo is compatible with Boca printers.';
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

                ToolTip = 'Import an image file to use as a logo.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RetailLogoMgtCtrl.UploadLogo();
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

                ToolTip = 'Export the selected line as a bitmap image file (.bmp).';
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
}