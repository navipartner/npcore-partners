page 6184515 "EFT NETS Cloud POS Unit Setup"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT NETS Cloud POS Unit Setup';
    PageType = Card;
    SourceTable = "EFT NETS Cloud POS Unit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal ID"; "Terminal ID")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        EFTNETSCloudIntegration: Codeunit "EFT NETSCloud Integration";
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

                trigger OnAction()
                var
                    EFTNETSCloudIntegration: Codeunit "EFT NETSCloud Integration";
                begin
                    EFTNETSCloudIntegration.ShowTerminalSettings(GlobalEFTSetup);
                end;
            }
        }
    }

    var
        GlobalEFTSetup: Record "EFT Setup";

    procedure SetEFTSetup(EFTSetup: Record "EFT Setup")
    begin
        GlobalEFTSetup := EFTSetup;
    end;
}

