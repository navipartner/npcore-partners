page 6059837 "NPR EFT Recon. Provider List"
{
    Caption = 'EFT Recon. Provider List';
    CardPageID = "NPR EFT Recon. Provider Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR EFT Recon. Provider";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Handlers)
            {
                Caption = 'Handlers';
                action(ImportHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Import Handlers';
                    Image = Import;
                    RunObject = Page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Import));
                    ToolTip = 'Executes the Import Handlers action';
                }
                action(MatchingHandlers)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Matching Handlers';
                    Image = Reconcile;
                    RunObject = Page "NPR EFT Recon. Subscribers";
                    RunPageLink = "Provider Code" = field(Code);
                    RunPageView = sorting("Provider Code", Type, "Subscriber Codeunit ID", "Subscriber Function")
                                  where(Type = const(Matching));
                    ToolTip = 'Executes the Matching Handlers action';
                }
            }
        }
    }
}

