page 6014634 "NPR GCP Setup"
{
    // NPR5.26/MMV /20160826 CASE 246209 Created page.
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Caption

    Caption = 'Google Cloud Print Setup';
    PageType = List;
    SourceTable = "NPR GCP Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Printer ID"; "Printer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer ID field';
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object ID field';
                }
                field("""Cloud Job Ticket"".HASVALUE()"; "Cloud Job Ticket".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Settings Stored';
                    ToolTip = 'Specifies the value of the Settings Stored field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Change Print Settings")
            {
                Caption = 'Change Print Settings';
                Image = PrintAttachment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Change Print Settings action';

                trigger OnAction()
                var
                    GCPMgt: Codeunit "NPR GCP Mgt.";
                    GCPPrintSetting: Record "NPR GCP Setup";
                begin
                    CurrPage.SetSelectionFilter(GCPPrintSetting);
                    GCPMgt.SetTicketOptions(GCPPrintSetting);
                end;
            }
            action("Setup Account")
            {
                Caption = 'Setup Account';
                Image = PrintAcknowledgement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Account action';

                trigger OnAction()
                var
                    GCPAuthSetup: Page "NPR GCP Auth Setup";
                    GCPMgt: Codeunit "NPR GCP Mgt.";
                begin
                    if GCPAuthSetup.RunModal = ACTION::OK then begin
                        GCPMgt.CreateAccountTokens(GCPAuthSetup.GetAuthCode());
                    end;
                end;
            }
            action("View Printer Info")
            {
                Caption = 'View Printer Info';
                Image = PrintCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the View Printer Info action';

                trigger OnAction()
                var
                    GCPMgt: Codeunit "NPR GCP Mgt.";
                    GCPPrintSetting: Record "NPR GCP Setup";
                begin
                    CurrPage.SetSelectionFilter(GCPPrintSetting);
                    if not GCPPrintSetting.FindFirst then
                        exit;

                    GCPMgt.ViewPrinterInfo(GCPPrintSetting."Printer ID");
                end;
            }
        }
    }
}

