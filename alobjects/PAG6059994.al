page 6059994 "MPOS Payment Gateway"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS Payment Gateway';
    PageType = List;
    SourceTable = "MPOS Payment Gateway";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                }
                field(Decription; Decription)
                {
                    ApplicationArea = All;
                }
                field("Merchant Id"; "Merchant Id")
                {
                    ApplicationArea = All;
                }
                field(User; User)
                {
                    ApplicationArea = All;
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Transactions)
            {
                Caption = 'Transactions';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    case Provider of
                        Provider::ADYEN:
                            Error(NotImplimentedYetError);
                        Provider::NETS:
                            PAGE.Run(PAGE::"MPOS Nets Transactions List");
                    end;
                end;
            }
        }
    }

    var
        NotImplimentedYetError: Label 'Not implimented yet';
}

