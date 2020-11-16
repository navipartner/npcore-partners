page 6151221 "NPR PrintNode Printer List"
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created

    Caption = 'PrintNode Printer List';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR PrintNode Printer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Settings; Rec.Settings.HasValue)
                {
                    Caption = 'Settings Stored';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ChangeSettings)
            {
                Caption = 'Change Print Settings';
                ApplicationArea = All;

                Image = PrintAttachment;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
                begin
                    PrintNodeMgt.SetPrinterOptions(Rec);
                end;

            }
            action(PrinterInfo)
            {
                Caption = 'View Printer Info';
                ApplicationArea = All;
                Image = PrintCheck;
                trigger OnAction()
                var
                    PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
                begin
                    PrintNodeMgt.ViewPrinterInfo(Rec.Id);
                end;
            }
        }
        area(Navigation)
        {
            action(AccountSetup)
            {
                Caption = 'Setup Account';
                ApplicationArea = All;
                Image = PrintAcknowledgement;
                RunObject = Page "NPR PrintNode Setup";
            }

        }
    }
}

