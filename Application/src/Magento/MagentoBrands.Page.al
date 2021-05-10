page 6151420 "NPR Magento Brands"
{
    Caption = 'Brands';
    CardPageID = "NPR Magento Brand Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Brand";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Brands")
            {
                Caption = 'Setup Brands';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasSetupBrands;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Brands action';

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                begin
                    MagentoSetupMgt.TriggerSetupBrands();
                    Message(Text000);
                end;
            }
        }
        area(navigation)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                RunObject = Page "NPR Magento Brand Card";
                ShortCutKey = 'Shift+F5';
                ApplicationArea = All;
                ToolTip = 'Executes the Card action';
            }
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;
                ApplicationArea = All;
                ToolTip = 'Executes the Display Config action';

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                begin
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::Brand);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupBrands := MagentoSetupMgt.HasSetupBrands();

        SetDisplayConfigVisible();
    end;

    var
        DisplayConfigVisible: Boolean;
        HasSetupBrands: Boolean;
        Text000: Label 'Brand update initiated';

    procedure GetSelectionFilter(): Text
    var
        Brand: Record "NPR Magento Brand";
        MagentoSelectionFilterMgt: Codeunit "NPR Magento Select. Filt. Mgt.";
    begin
        CurrPage.SetSelectionFilter(Brand);
        exit(MagentoSelectionFilterMgt.GetSelectionFilterForBrand(Brand));
    end;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        DisplayConfigVisible := MagentoSetup.Get() and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}