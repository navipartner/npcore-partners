page 6151420 "NPR Magento Brands"
{
    Caption = 'Brands';
    CardPageID = "NPR Magento Brand Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Brand";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Picture; Rec.Picture)
                {

                    ToolTip = 'Specifies the value of the Picture field';
                    ApplicationArea = NPRRetail;
                }
                field("Sorting"; Rec.Sorting)
                {

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Setup Brands action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
                    Window: Dialog;
                begin
                    Window.Open(Text000);
                    MagentoSetupMgt.TriggerSetupBrands(true);
                    Window.Close();
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

                ToolTip = 'Executes the Card action';
                ApplicationArea = NPRRetail;
            }
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;

                ToolTip = 'Executes the Display Config action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MagentoDisplayConfig: Record "NPR Magento Display Config";
                    MagentoDisplayConfigPage: Page "NPR Magento Display Config";
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
        Text000: Label 'Downloading...';

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