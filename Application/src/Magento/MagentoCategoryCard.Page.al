page 6151414 "NPR Magento Category Card"
{
    UsageCategory = None;
    Caption = 'Magento Category Card';
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "NPR Magento Category";

    layout
    {
        area(content)
        {
            group("Item Group")
            {
                Caption = 'Item Group';
                group(Control6150614)
                {
                    Enabled = (NOT Rec.Root);
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

                        trigger OnValidate()
                        begin
                            if not Confirm(Text001, false) then
                                exit;
                            Rec.Validate("Seo Link", Rec.Name);
                            CurrPage.Update(true);
                        end;
                    }
                    field("Description"; Format(Rec.Description.HasValue))
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Caption = 'Description';
                        ToolTip = 'Specifies the value of the Description field';

                        trigger OnAssistEdit()
                        var
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(Rec.FieldNo(Description));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field("Short Description"; Format(Rec."Short Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Short Description';
                        ToolTip = 'Specifies the value of the Short Description field';

                        trigger OnAssistEdit()
                        var
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(Rec.FieldNo("Short Description"));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field(Picture; Rec.Picture)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Picture field';
                    }
                }
                group(Control6150620)
                {
                    Editable = (NOT Rec.Root);
                    ShowCaption = false;
                    field("Is Active"; Rec."Is Active")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Is Active field';
                    }
                    field("Is Anchor"; Rec."Is Anchor")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Is Anchor field';
                    }
                    field("Show In Navigation Menu"; Rec."Show In Navigation Menu")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show In Navigation Menu field';
                    }
                    field("Seo Link"; Rec."Seo Link")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Seo Link field';
                    }
                    field("Meta Title"; Rec."Meta Title")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Meta Title field';
                    }
                    field("Meta Keywords"; Rec."Meta Keywords")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Meta Keywords field';
                    }
                    field("Meta Description"; Rec."Meta Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Meta Description field';
                    }
                    field("Sorting"; Rec.Sorting)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sorting field';
                    }
                    field(Icon; Rec.Icon)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Icon field';
                    }
                }
            }
            part(MagentoChildCategories; "NPR Magento Child Categories")
            {
                Caption = 'Child Categories';
                ShowFilter = false;
                SubPageLink = "Parent Category Id" = FIELD(FILTER(Id));
                Visible = MagentoItemGroupSubformVisible;
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(PictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                SubPageLink = Type = CONST("Item Group"),
                              Name = FIELD(Picture);
                Visible = (NOT HasSetupCategories);
                ApplicationArea = All;
            }
            part(IconPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Icon';
                Editable = false;
                ShowFilter = false;
                SubPageLink = Type = CONST("Item Group"),
                              Name = FIELD(Icon);
                Visible = (NOT HasSetupCategories);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
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
                    MagentoDisplayConfig.SetRange(Type, MagentoDisplayConfig.Type::"Item Group");
                    MagentoDisplayConfig.SetRange("No.", Rec.Id);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        MagentoItemGroupSubformVisible := Rec.Find();
        CurrPage.MagentoChildCategories.PAGE.SetParentItemGroup(Rec);
        CurrPage.PictureDragDropAddin.PAGE.SetItemGroupNo(Rec.Id, false);
        CurrPage.IconPictureDragDropAddin.PAGE.SetItemGroupNo(Rec.Id, true);
    end;

    trigger OnOpenPage()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        HasSetupCategories := MagentoSetupMgt.HasSetupCategories();
        CurrPage.Editable(not HasSetupCategories);
        SetDisplayConfigVisible();
    end;

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
        Text001: Label 'Update Seo Link?';
        DisplayConfigVisible: Boolean;
        MagentoItemGroupSubformVisible: Boolean;
        HasSetupCategories: Boolean;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        DisplayConfigVisible := MagentoSetup.Get() and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
    end;
}