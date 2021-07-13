page 6184515 "NPR EFT NETSCloud POSUnitSetup"
{
    Caption = 'EFT NETS Cloud POS Unit Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR EFT NETSCloud Unit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal ID"; Rec."Terminal ID")
                {

                    ToolTip = 'Specifies the value of the Terminal ID field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
                        TerminalIDOut: Text;
                    begin
                        if EFTNETSCloudIntegration.LookupTerminal(GlobalEFTSetup, TerminalIDOut) then
                            Rec.Validate("Terminal ID", TerminalIDOut);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowTerminalSettings)
            {
                Caption = 'Show Terminal Settings';
                Image = Setup;

                ToolTip = 'Executes the Show Terminal Settings action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
                begin
                    EFTNETSCloudIntegration.ShowTerminalSettings(GlobalEFTSetup);
                end;
            }
        }
    }

    var
        GlobalEFTSetup: Record "NPR EFT Setup";

    procedure SetEFTSetup(EFTSetup: Record "NPR EFT Setup")
    begin
        GlobalEFTSetup := EFTSetup;
    end;
}

