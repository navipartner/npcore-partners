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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Sequence; Sequence)
                {
                    ApplicationArea = All;
                }
                field(Keyword; Keyword)
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                }
                field("OneBitLogo.HASVALUE"; OneBitLogo.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Boca Compatible';
                    Editable = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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

