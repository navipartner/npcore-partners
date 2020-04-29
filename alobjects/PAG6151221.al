page 6151221 "PrintNode Printer List"
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created

    Caption = 'PrintNode Printer List';
    PageType = List;
    SourceTable = "PrintNode Printer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshPrinters)
            {
                Caption = 'Refresh Printers';
                Image = PrintInstallment;
                Promoted = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    PrintNodeMgt: Codeunit "PrintNode Mgt.";
                begin
                    PrintNodeMgt.RefreshPrinters();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

