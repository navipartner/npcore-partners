page 6151221 "NPR PrintNode Printer List"
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created

    Caption = 'PrintNode Printer List';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Id field';
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object ID field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Settings; Rec.Settings.HasValue)
                {
                    Caption = 'Settings Stored';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Settings Stored field';
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
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Change Print Settings action';
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
                ToolTip = 'Executes the View Printer Info action';
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
                ToolTip = 'Executes the Setup Account action';
            }

        }
    }
}

