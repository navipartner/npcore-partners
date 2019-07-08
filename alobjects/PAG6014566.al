page 6014566 "Retail Logo Setup"
{
    // NPR4.21/MMV/20160223 CASE 223223 Created page
    // NPR5.46/BHR /20180906 CASE 327525 Export Logo

    Caption = 'Retail Logo Setup';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Retail Logo";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Sequence;Sequence)
                {
                }
                field(Keyword;Keyword)
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Start Date";"Start Date")
                {
                }
                field("End Date";"End Date")
                {
                }
            }
        }
        area(factboxes)
        {
            part(Control6150624;"Retail Logo Factbox")
            {
                SubPageLink = Sequence=FIELD(Sequence);
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

                trigger OnAction()
                var
                    RetailLogoMgt: Codeunit "Retail Logo Mgt.";
                begin
                    if RetailLogoMgt.UploadLogoFromFile('') then
                      FindLast;
                end;
            }
            action("Print Logo")
            {
                Caption = 'Print Logo';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RetailLogoMgt: Codeunit "Retail Logo Mgt.";
                begin
                    RetailLogoMgt.TestPrintESCPOS(Rec);
                end;
            }
            action("Export Logo")
            {
                Caption = 'Export Logo';
                Image = ExportToDo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RetailLogoMgt: Codeunit "Retail Logo Mgt.";
                begin
                    //-NPR5.46 [327525]
                    RetailLogoMgt.ExportImageBMP(Rec);
                    //+NPR5.46 [327525]
                end;
            }
        }
    }
}

