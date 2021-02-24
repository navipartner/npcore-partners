page 6014566 "NPR Retail Logo Setup"
{
    // NPR4.21/MMV/20160223 CASE 223223 Created page
    // NPR5.46/BHR /20180906 CASE 327525 Export Logo
    // NPR5.55/MITH/20200619  CASE 404276 Added visual indicator of whether or not a logo is compatible with the Boca printer (it will be compatible after reupload)

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
            repeater(Group)
            {
                field(Sequence; Sequence)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence field';
                }
                field(Keyword; Keyword)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keyword field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field';
                }
                field("OneBitLogo.HASVALUE"; OneBitLogo.HasValue)
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
                var
                    RetailLogoMgt: Codeunit "NPR Retail Logo Mgt.";
                begin
                    if RetailLogoMgt.UploadLogoFromFile('') then
                        FindLast;
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
                    //-NPR5.46 [327525]
                    RetailLogoMgt.ExportImageBMP(Rec);
                    //+NPR5.46 [327525]
                end;
            }
        }
    }
}

