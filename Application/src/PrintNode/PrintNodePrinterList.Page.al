﻿page 6151221 "NPR PrintNode Printer List"
{
    Extensible = False;
    Caption = 'PrintNode Printer List';
    PageType = List;
    UsageCategory = Administration;
    DelayedInsert = true;
    SourceTable = "NPR PrintNode Printer";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object ID"; Rec."Object ID")
                {

                    ToolTip = 'Specifies the value of the Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Settings; Rec.Settings.HasValue)
                {
                    Caption = 'Settings Stored';
                    ToolTip = 'Specifies the value of the Settings Stored field';
                    ApplicationArea = NPRRetail;
                }
                field("BC Paper Size"; Rec."BC Paper Size")
                {
                    Caption = 'BC Paper Size';
                    ToolTip = 'The paper size sent to the Business Central reporting engine';
                    ApplicationArea = NPRRetail;
                }
                field("BC Paper Height"; Rec."BC Paper Height")
                {
                    Caption = 'BC Paper Height';
                    ToolTip = 'The paper height sent to the Business Central reporting engine';
                    ApplicationArea = NPRRetail;
                }
                field("BC Paper Width"; Rec."BC Paper Width")
                {
                    Caption = 'BC Paper Width';
                    ToolTip = 'The paper width sent to the Business Central reporting engine';
                    ApplicationArea = NPRRetail;
                }
                field("BC Paper Unit"; Rec."BC Paper Unit")
                {
                    ToolTip = 'The paper unit sent to the Business Central reporting engine';
                    ApplicationArea = NPRRetail;
                }
                field("BC Paper Source"; Rec."BC Paper Source")
                {
                    Caption = 'BC Paper Source';
                    ToolTip = 'The paper source sent to the Business Central reporting engine';
                    ApplicationArea = NPRRetail;
                }
                field(Landscape; Rec."BC Landscape")
                {
                    Caption = 'BC Landscape';
                    ToolTip = 'Check if printer should print as landscape';
                    ApplicationArea = NPRRetail;
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


                Image = PrintAttachment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Change Print Settings action';
                ApplicationArea = NPRRetail;
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

                Image = PrintCheck;
                ToolTip = 'Executes the View Printer Info action';
                ApplicationArea = NPRRetail;
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

                Image = PrintAcknowledgement;
                RunObject = Page "NPR PrintNode Setup";
                ToolTip = 'Executes the Setup Account action';
                ApplicationArea = NPRRetail;
            }

        }
    }
}

