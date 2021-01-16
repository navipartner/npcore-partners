page 6059994 "NPR MPOS Payment Gateway"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS Payment Gateway';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MPOS Payment Gateway";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field(Decription; Decription)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Decription field';
                }
                field("Merchant Id"; "Merchant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                }
                field(User; User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User field';
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Password field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Transactions action';

                trigger OnAction()
                begin
                    case Provider of
                        Provider::ADYEN:
                            Error(NotImplimentedYetError);
                        Provider::NETS:
                            PAGE.Run(PAGE::"NPR MPOS Nets Trx List");
                    end;
                end;
            }
        }
    }

    var
        NotImplimentedYetError: Label 'Not implimented yet';
}

