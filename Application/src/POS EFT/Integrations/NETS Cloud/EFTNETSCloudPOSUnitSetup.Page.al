page 6184515 "NPR EFT NETSCloud POSUnitSetup"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT NETS Cloud POS Unit Setup';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR EFT NETSCloud Unit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal ID"; "Terminal ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal ID field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
                        TerminalIDOut: Text;
                    begin
                        if EFTNETSCloudIntegration.LookupTerminal(GlobalEFTSetup, TerminalIDOut) then
                            Validate("Terminal ID", TerminalIDOut);
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Terminal Settings action';

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

